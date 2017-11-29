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
