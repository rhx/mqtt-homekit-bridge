import Foundation
import Dispatch
import Mosquitto
import HAP

let args = CommandLine.arguments
let cmd = args[0]                   ///< command name
var name: String = convert(cmd, using: basename)
var verbosity = 1                   ///< verbosity level
var port = 1883                     ///< MQTT port
var host = "192.168.1.3"            ///< Controller host
var pin = "123-45-678"
var vendor = "Mosquitto"
var type = "MQTT"
var serial = "12345"
var version = "1.0.0"
var configuration = "/usr/local/etc/\(name).conf"
var active = true

fileprivate func usage() -> Never {
    print("Usage: \(cmd) <options>")
    print("Options:")
    print("  -c <configuration> JSON configuration [\(configuration)]")
    print("  -d                 print debug output")
    print("  -f <version>       firmware version [\(version)]")
    print("  -h <host>          MQTT broker host [\(host)]")
    print("  -m <manufacturer>  name of the manufacturer [\(vendor)]")
    print("  -n <name>          name of the HomeKit bridge [\(name)]")
    print("  -p <port>          connect to MQTT <port> instead of \(port)")
    print("  -q                 turn off all non-critical logging output")
    print("  -s <SECRET_PIN>    HomeKit PIN for authentication [\(pin)]")
    print("  -S <serial>        Device serial number [\(serial)]")
    print("  -t <type>          name of the model/type [\(type)]")
    print("  -v                 increase logging verbosity\n")
    exit(EXIT_FAILURE)
}

while let result = get(options: "c:df:h:m:n:p:qs:S:t:v") {
    let option = result.0
    let arg = result.1
    switch option {
    case "c": configuration = arg!
    case "d": verbosity = 9
    case "f": version = arg!
    case "h": host = arg!
    case "m": vendor = arg!
    case "n": name = arg!
    case "p": if let p = Int(arg!) {
        port = p
    } else { usage() }
    case "q": verbosity  = 0
    case "s": pin = arg!
    case "S": serial = arg!
    case "t": type = arg!
    case "v": verbosity += 1
    default:
        print("Unknown option \(option)!")
        usage()
    }
}

let fm = FileManager.default
let configURL = URL(fileURLWithPath: configuration)
guard let jsonData = try? Data(contentsOf: configURL) else {
    print("Error: cannot read JSON configuration '\(configuration)'")
    usage()
}
let decoder = JSONDecoder()
guard let devices = try? decoder.decode([String:MQTTDevice].self, from: jsonData) else {
    print("Error: cannot decode JSON configuration '\(configuration)'")
    exit(EXIT_FAILURE)
}

let mosquitto = Mosquitto(id: name)
if verbosity > 0 {
    mosquitto.logCallback = { logLevel, logMessage in
        guard logLevel >= verbosity else { return }
        print("\(logLevel): \(String(cString: logMessage))")
    }
}
if verbosity > 8 {
    mosquitto.subscribeCallback = { msgID, subscriptions in
        var qos: [String] = []
        for i in 0..<subscriptions.count {
            qos.append("QoS: \(subscriptions[i])")
        }
        print("Got subscription \(msgID): \(qos)")
    }
}
do {
    try mosquitto.connect(to: host, port: port)
    try mosquitto.unsubscribe(from: "#")
} catch {
    print("Cannot subscribe to MQTT server \(host):\(port): \(error)")
    exit(EXIT_FAILURE)
}

let dbPath = try! fm.url(for: .applicationSupportDirectory, in: .userDomainMask, appropriateFor: nil, create: true).appendingPathComponent(name).path
let dbExists = fm.fileExists(atPath: dbPath)
let db = FileStorage(filename: dbPath)

RunLoop.main.run(until: Date(timeIntervalSinceNow: dbExists ? 1 : 5))

let (accessories, accessoryIDs) = devices.reduce(([Accessory](), [String]())) {
    let (entry, mqttDevice) = $1
    let deviceName = mqttDevice.name ?? entry
    let deviceInfo = Service.Info(name: deviceName, serialNumber: mqttDevice.serial ?? entry, manufacturer: mqttDevice.manufacturer ?? vendor, model: mqttDevice.model ?? type)
    guard let accessory = mqtt2hap(mqttDevice, info: deviceInfo) else {
        print("\(entry): ignoring unknown service \(mqttDevice.service) for \(mqttDevice.name ?? "<unnamed device>")")
        return $0
    }
    accessory.onControlValueChange(for: mqttDevice) {
        guard let topic = $0, let value = $1 else { return }
        do {
            if verbosity > 2 { print("Publishing '\(topic)': '\(value)'") }
            _ = try mosquitto.publish(topic: topic, payload: value)
        } catch {
            print("Error \(error) attempting to publish \(topic): '\(value)'")
        }
    }
    return ($0.0 + [accessory], $0.1 + [entry])
}
var mqttSubscriptions = [String:(String) -> Void]()
mosquitto.messageCallback = { msg in
    guard let subscriptionCallback = mqttSubscriptions[msg.topic] else { return }
    let content = msg.content
    guard !content.isEmpty else { return }
    DispatchQueue.main.async {
        subscriptionCallback(content)
    }
}

let info = Service.Info(name: name, serialNumber: serial, manufacturer: vendor, model: type, firmwareRevision: version)
let device = Device(bridgeInfo: info, setupCode: Device.SetupCode(stringLiteral: pin), storage: db, accessories: accessories)
device.delegate = HAPDeviceDelegate.shared

let server = try Server(device: device, port: 0)
server.start()

try! mosquitto.loopStart()

for (i, accessory) in accessories.enumerated() {
    let id = accessoryIDs[i]
    guard let mqttDevice = devices[id],
          let topic = accessory.valueCharacteristic.flatMap({ mqttDevice.statusTopic(for: $0) }) else {
        continue
    }
    if verbosity > 0 { print("Subscribing to '\(topic)' for '\(id)'") }
    mqttSubscriptions[topic] = {
        if !accessory.update(value: $0) {
            print("Cannot update '\(topic)' to '$0' for '\(id)'")
        }
    }
    do {
        _ = try mosquitto.subscribe(to: topic)
    } catch {
        print("Error \(error) attempting to subscribe to \(topic) for '\(id)'")
    }
}

while active {
    RunLoop.current.run(until: Date().addingTimeInterval(2))
}

print("Unsubscribing ...")

for (i, accessory) in accessories.enumerated() {
    let id = accessoryIDs[i]
    guard let mqttDevice = devices[id],
        let topic = accessory.valueCharacteristic.flatMap({ mqttDevice.statusTopic(for: $0) }) else {
            continue
    }
    do {
        _ = try mosquitto.unsubscribe(from: topic)
    } catch {
        print("Error \(error) attempting to unsubscribe from \(topic) for '\(id)'")
    }
}

RunLoop.current.run(until: Date().addingTimeInterval(2))

try! mosquitto.loopStop()
