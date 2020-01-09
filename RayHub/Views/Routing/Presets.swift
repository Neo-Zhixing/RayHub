//
//  Presets.swift
//  RayHub
//
//  Created by Zhixing Zhang on 1/9/20.
//  Copyright © 2020 Zhixing Zhang. All rights reserved.
//

import Foundation

struct Preset {
    let title: String
    let identifier: String
    init(_ title: String, _ identifier: String) {
        self.title = title
        self.identifier = identifier
    }
}
let GeositePresets = [
    Preset("Ads", "category-ads"),
    Preset("Ads and Ad providers", "category-ads-all"),
    Preset("Chinese", "cn"),
    Preset("Google", "google"),
    Preset("Facebook", "facebook"),
    Preset("Located in China", "geolocation-cn"),
    Preset("Located outside China", "geolocation-!cn"),
    Preset("Speedtest providers", "speedtest"),
    Preset("Domains ending in .cn", "tld-cn")
]
