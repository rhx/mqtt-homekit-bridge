//
//  HAPDeviceDelegate.swift
//  mqtt-homekit-bridge
//
//  Created by Rene Hexel on 10/6/18.
//
import Foundation
import HAP

fileprivate let sharedDelegate = HAPDeviceDelegate()

class HAPDeviceDelegate {
    static var shared: HAPDeviceDelegate { return sharedDelegate }

    var onBoolChange: [(Accessory, Bool?) -> Void] = []
    var onIntChange: [(Accessory, Int?) -> Void] = []
    var onDoubleChange: [(Accessory, Double?) -> Void] = []
    var onDataChange: [(Accessory, Data?) -> Void] = []

    var onCurrentDoorStateChange: [(Accessory, CurrentDoorState?) -> Void] = []
    var onLockCurrentStateChange: [(Accessory, LockCurrentState?) -> Void] = []
    var onSecuritySystemCurrentStateChange: [(Accessory, SecuritySystemCurrentState?) -> Void] = []
    var onSmokeDetectedChange: [(Accessory, SmokeDetected?) -> Void] = []
}

extension HAPDeviceDelegate: DeviceDelegate {
    func characteristic<T>(_ characteristic: GenericCharacteristic<T>, ofService service: Service, ofAccessory a: Accessory, didChangeValue newValue: T?) {
        print(" --> Characteristic \(characteristic) of service \(service.type) of accessory \(a.info.name.value ?? name) changed to: \(String(describing: newValue))")
        switch newValue {
        case let value as Bool?:   onBoolChange.forEach   { $0(a, value) }
        case let value as Int?:    onIntChange.forEach    { $0(a, value) }
        case let value as Double?: onDoubleChange.forEach { $0(a, value) }
        case let value as Data?:   onDataChange.forEach   { $0(a, value) }
        case let value as CurrentDoorState?:           onCurrentDoorStateChange.forEach           { $0(a, value) }
        case let value as LockCurrentState?:           onLockCurrentStateChange.forEach           { $0(a, value) }
        case let value as SecuritySystemCurrentState?: onSecuritySystemCurrentStateChange.forEach { $0(a, value) }
        case let value as SmokeDetected?:              onSmokeDetectedChange.forEach              { $0(a, value) }
        default: print("Unknown value")
        }
    }
}
