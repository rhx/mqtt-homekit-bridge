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
    func characteristic(_ characteristic: GenericCharacteristic<Bool>, ofService: Service, ofAccessory a: Accessory, didChangeValue: Bool?) { onBoolChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<Int>, ofService: Service, ofAccessory a: Accessory, didChangeValue: Int?) { onIntChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<Double>, ofService: Service, ofAccessory a: Accessory, didChangeValue: Double?) { onDoubleChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<Data>, ofService: Service, ofAccessory a: Accessory, didChangeValue: Data?) { onDataChange.forEach { $0(a, didChangeValue) } }

    func characteristic(_ characteristic: GenericCharacteristic<CurrentDoorState>, ofService: Service, ofAccessory a: Accessory, didChangeValue: CurrentDoorState?) { onCurrentDoorStateChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<LockCurrentState>, ofService: Service, ofAccessory a: Accessory, didChangeValue: LockCurrentState?) { onLockCurrentStateChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<SecuritySystemCurrentState>, ofService: Service, ofAccessory a: Accessory, didChangeValue: SecuritySystemCurrentState?) { onSecuritySystemCurrentStateChange.forEach { $0(a, didChangeValue) } }
    func characteristic(_ characteristic: GenericCharacteristic<SmokeDetected>, ofService: Service, ofAccessory a: Accessory, didChangeValue: SmokeDetected?) { onSmokeDetectedChange.forEach { $0(a, didChangeValue) } }
}
