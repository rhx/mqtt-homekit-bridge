//
//  MQTTDevice.swift
//  mqtt-homekit-bridge
//
//  Created by Rene Hexel on 29/11/17.
//

import Foundation

typealias MQTTTopic = String
typealias MQTTAction = String

struct MQTTDevice: Decodable {
    let id: String?
    let name: String?
    let service: String
    let manufacturer: String?
    let model: String?
    let serial: String?
    let topic: [MQTTAction : MQTTTopic]
//    let payload: [MQTTAction : String]
}

extension MQTTDevice {
    /// Return the MQTT status topic to subscribe to for the given characteristic
    ///
    /// - Parameter characteristic: device characteristic in question
    /// - Returns: the status topic configured or `nil` if unconfigured
    func statusTopic(for characteristic: String) -> String? {
        return topic["status\(characteristic)"]
    }

    /// Return the MQTT control topic to post to for the given characteristic
    ///
    /// - Parameter characteristic: device characteristic in question
    /// - Returns: the control topic configured or `nil` if unconfigured
    func controlTopic(for characteristic: String) -> String? {
        return topic["set\(characteristic)"]
    }
}
