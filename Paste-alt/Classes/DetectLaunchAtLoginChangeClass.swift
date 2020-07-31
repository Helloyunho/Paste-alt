//
//  DetectLaunchAtLoginChangeClass.swift
//  Paste-alt
//
//  Created by Helloyunho on 2020/07/31.
//  Copyright © 2020 Helloyunho. All rights reserved.
//

import Foundation
import Combine
import LaunchAtLogin

class DetectLaunchAtLoginChange: ObservableObject {
    @Published var launchAtLoginBool = LaunchAtLogin.isEnabled {
        didSet {
            changeLaunchAtLogin()
        }
    }
    
    func changeLaunchAtLogin() {
        LaunchAtLogin.isEnabled = self.launchAtLoginBool
    }
}
