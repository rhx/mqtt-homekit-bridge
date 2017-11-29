import Foundation
import Dispatch
import Mosquitto
import HAP

let args = CommandLine.arguments
let cmd = args[0]                   ///< command name
var name = convert(cmd, using: basename)
var verbosity = 1                   ///< verbosity level
var port = 1883                     ///< MQTT port
var host = "192.168.1.3"            ///< Controller host
var pin = "123-45-678"
var vendor = "Space Age Technologies"
var type = "SC3D-UD"
var serial = "0c:82:68:d3:4c:3c"
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
let db: FileStorage
do {
    db = try FileStorage(path: dbPath)
} catch {
    fputs("Cannot open file storage at \(dbPath)\n", stderr)
    exit(EXIT_FAILURE)
}
RunLoop.main.run(until: Date(timeIntervalSinceNow: dbExists ? 1 : 5))

let (accessories, accessoryIndexes) = devices.enumerated().reduce(([Accessory](), [Int]())) {
    let (index, dev) = $1
    let (entry, mqttDevice) = dev
    let deviceName = mqttDevice.name ?? entry
    let deviceInfo = Service.Info(name: deviceName, manufacturer: mqttDevice.manufacturer ?? vendor, model: mqttDevice.model ?? type, serialNumber: mqttDevice.serial ?? entry)
    guard let accessory = mqtt2hap(mqttDevice, info: deviceInfo) else {
        print("\(entry): ignoring unknown service \(mqttDevice.service) for \(mqttDevice.name ?? "<unnamed device>")")
        return $0
    }
    accessory.onControlValueChange(for: mqttDevice) {
        guard let topic = $0, let value = $1 else { return }
        do {
            _ = try mosquitto.publish(topic: topic, payload: value)
        } catch {
            print("Error \(error) attempting to publish \(topic): '\(value)'")
        }
    }
    return ($0.0 + [accessory], $0.1 + [index])
}
let info = Service.Info(name: name, manufacturer: vendor, model: type, serialNumber: serial, firmwareRevision: version)
let device = Device(bridgeInfo: info, setupCode: pin, storage: db, accessories: accessories)

let server = try Server(device: device, port: 0)
server.start()

try! mosquitto.loopStart()

while active {
    RunLoop.current.run(until: Date().addingTimeInterval(2))
}

try! mosquitto.loopStop()
