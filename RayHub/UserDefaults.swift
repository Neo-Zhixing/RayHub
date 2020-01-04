//
//  UserDefaults.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/5/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import Foundation


func registerUserDefaults(_ defaults: UserDefaults) {
    defaults.register(defaults: [
        "socks.host": "localhost",
        "socks.port": 1080,
        "socks.udp": true,
        "socks.auth": false,
        
        "http.host": "localhost",
        "http.port": 8080,
        "http.allowTransparent": true,
        "http.auth": false,
        "http.timeout": 60
    ])
}
