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
