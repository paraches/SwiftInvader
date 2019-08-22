//
//  AppDelegate.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/22.
//  Copyright © 2019 paraches lifestyle lab. All rights reserved.
//


import Cocoa

@NSApplicationMain
class AppDelegate: NSObject, NSApplicationDelegate {
    let rfDeviceMonitor = HIDDeviceMonitor([HIDMonitorData(vendorId: 0x0458, productId: 0x1002)], reportSize: 64)

    func applicationDidFinishLaunching(_ aNotification: Notification) {
        // Insert code here to initialize your application
        let rfDeviceDaemon = Thread(target: self.rfDeviceMonitor, selector: #selector(self.rfDeviceMonitor.start), object: nil)
        rfDeviceDaemon.start()
    }
    
    func applicationWillTerminate(_ aNotification: Notification) {
        // Insert code here to tear down your application
    }
    
    
}
