//
//  mqtt2hap.swift
//  mqtt-homekit-bridge
//
//  Created by Rene Hexel on 29/11/17.
//
import Foundation
import HAP

enum AccessoryType: String {
    case airQualitySensor = "AirQualitySensor"
    case batteryService = "BatteryService"
    case bridgeConfiguration = "BridgeConfiguration"
    case bridgingState = "BridgingState"
    case contactSensor = "ContactSensor"
    case door = "Door"
    case fan = "Fan"
    case garageDoorOpener = "GarageDoorOpener"
    case humiditySensor = "HumiditySensor"
    case lightbulb = "Lightbulb"
    case lightSensor = "LightSensor"
    case lockMechanism = "LockMechanism"
    case outlet = "Outlet"
    case securitySystem = "SecuritySystem"
    case smokeDetector = "SmokeDetector"
    case smokeSensor = "SmokeSensor"
    case `switch` = "Switch"
    case temperatureSensor = "TemperatureSensor"
    case thermometer = "Thermometer"
    case thermostat = "Thermostat"
    case window = "Window"
    case windowCovering = "WindowCovering"
}

func mqtt2hap(_ mqttDevice: MQTTDevice, info deviceInfo: Service.Info) -> Accessory? {
    guard let type = AccessoryType(rawValue: mqttDevice.service) else { return nil }
    switch type {
    case .airQualitySensor: return .AirQualitySensor(info: deviceInfo)
    case .batteryService: return .BatteryService(info: deviceInfo)
    case .bridgeConfiguration: return .BridgeConfiguration(info: deviceInfo)
    case .bridgingState: return .BridgingState(info: deviceInfo)
    case .contactSensor: fallthrough
    case .door: return .Door(info: deviceInfo)
    case .fan: return .Fan(info: deviceInfo)
    case .garageDoorOpener: return .GarageDoorOpener(info: deviceInfo)
    case .humiditySensor: return .Hygrometer(info: deviceInfo)
    case .lightbulb: return .Lightbulb(info: deviceInfo)
    case .lightSensor: return .LightSensor(info: deviceInfo)
    case .lockMechanism: return .LockMechanism(info: deviceInfo)
    case .outlet: return .Outlet(info: deviceInfo)
    case .securitySystem: return .SecuritySystem(info: deviceInfo)
    case .smokeDetector: fallthrough
    case .smokeSensor: return .SmokeSensor(info: deviceInfo)
    case .switch: return .Switch(info: deviceInfo)
    case .temperatureSensor: fallthrough
    case .thermometer: return .Thermometer(info: deviceInfo)
    case .thermostat: return .Thermostat(info: deviceInfo)
    case .window: return .Window(info: deviceInfo)
    case .windowCovering: return .WindowCovering(info: deviceInfo)
    }
}

extension Accessory {
    var valueCharacteristic: String? {
        switch self {
        case (_ as AirQualitySensor): return "AirQuality"
        case (_ as BatteryService): return "BatteryLevel"
        case (_ as BridgeConfiguration): return "ConfigureBridgedAccessory"
        case (_ as BridgingState): return "LinkQuality"
        case (_ as Door): return "Position"
        case (_ as Fan): return "On"
        case (_ as GarageDoorOpener): return "DoorState"
        case (_ as Hygrometer): return "Humidity"
        case (_ as Lightbulb): return "On"
        case (_ as LightSensor): return "Light"
        case (_ as LockMechanism): return "LockState"
        case (_ as Outlet): return "On"
        case (_ as SecuritySystem): return "SecuritySystemState"
        case (_ as SmokeSensor): return "SmokeDetected"
        case (_ as Switch): return "On"
        case (_ as Thermometer): return "Temperature"
        case (_ as Thermostat): return "Temperature"
        case (_ as Window): return "Position"
        case (_ as WindowCovering): return "Position"
        default: return nil
        }
    }

    @discardableResult
    func onControlValueChange(for mqttDevice: MQTTDevice, call: @escaping (String?, String?) -> Void) -> Bool {
        let topic = valueCharacteristic.flatMap { mqttDevice.controlTopic(for: $0) }
        switch self {
        case let (acc as AirQualitySensor): acc.airQualitySensor.airQuality.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as BatteryService): acc.batteryService.batteryLevel.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as BridgeConfiguration): acc.bridgeConfiguration.configureBridgedAccessoryStatus.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as BridgingState): acc.bridgingState.linkQuality.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Door): acc.door.currentPosition.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Fan): acc.fan.on.onValueChange.append { call(topic, $0.map { "\($0 ? 1 : 0)" }) }
        case let (acc as GarageDoorOpener): acc.garageDoorOpener.currentDoorState.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Hygrometer): acc.humiditySensor.currentRelativeHumidity.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Lightbulb): acc.lightbulb.on.onValueChange.append { call(topic, $0.map { "\($0 ? 1 : 0)" }) }
        case let (acc as LightSensor): acc.lightSensor.currentLight.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as LockMechanism): acc.lockMechanism.lockCurrentState.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Outlet): acc.outlet.on.onValueChange.append { call(topic, $0.map { "\($0 ? 1 : 0)" }) }
        case let (acc as SecuritySystem): acc.securitySystem.securitySystemCurrentState.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as SmokeSensor): acc.smokeSensor.smokeDetected.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Switch): acc.`switch`.on.onValueChange.append { call(topic, $0.map { "\($0 ? 1 : 0)" }) }
        case let (acc as Thermometer): acc.temperatureSensor.currentTemperature.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Thermostat): acc.thermostat.currentTemperature.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as Window): acc.window.currentPosition.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        case let (acc as WindowCovering): acc.windowCovering.currentPosition.onValueChange.append { call(topic, $0.map { "\($0)" }) }
        default: return false
        }
        return true
    }

    @discardableResult
    func update(value: String) -> Bool {
        switch self {
        case let (acc as AirQualitySensor): acc.airQualitySensor.airQuality.value = Int(value).flatMap { AirQuality(rawValue: $0) }
        case let (acc as BatteryService): acc.batteryService.batteryLevel.value = Int(value)
        case let (acc as BridgeConfiguration): acc.bridgeConfiguration.configureBridgedAccessoryStatus.value = value.data(using: .utf8)
        case let (acc as BridgingState): acc.bridgingState.linkQuality.value = Int(value)
        case let (acc as Door): acc.door.currentPosition.value = Int(value)
        case let (acc as Fan): acc.fan.on.value = value != "0"
        case let (acc as GarageDoorOpener): acc.garageDoorOpener.currentDoorState.value = Int(value).flatMap { CurrentDoorState(rawValue: $0) }
        case let (acc as Hygrometer): acc.humiditySensor.currentRelativeHumidity.value = Double(value)
        case let (acc as Lightbulb): acc.lightbulb.on.value = value != "0"
        case let (acc as LightSensor): acc.lightSensor.currentLight.value = Double(value)
        case let (acc as LockMechanism): acc.lockMechanism.lockCurrentState.value = Int(value).flatMap { LockCurrentState(rawValue: $0) }
        case let (acc as Outlet): acc.outlet.on.value = value != "0"
        case let (acc as SecuritySystem): acc.securitySystem.securitySystemCurrentState.value = Int(value).flatMap { SecuritySystemCurrentState(rawValue: $0) }
        case let (acc as SmokeSensor): acc.smokeSensor.smokeDetected.value = Int(value).flatMap { SmokeDetected(rawValue: $0) }
        case let (acc as Switch): acc.`switch`.on.value = value != "0"
        case let (acc as Thermometer): acc.temperatureSensor.currentTemperature.value = Double(value)
        case let (acc as Thermostat): acc.thermostat.currentTemperature.value = Double(value)
        case let (acc as Window): acc.window.currentPosition.value = Int(value)
        case let (acc as WindowCovering): acc.windowCovering.currentPosition.value = Int(value)
        default: return false
        }
        return true
    }
}
