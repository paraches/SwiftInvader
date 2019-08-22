//
//  PPGameInputController.swift
//  SpriteKitSample
//
//  Created by paraches on 2019/07/17.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import Cocoa

extension Int {
    static let keyboardA = 0
    static let keyboardS = 1
    static let keyboardX = 6
    static let keyboardZ = 7
    static let keyboardLeft = 123
    static let keyboardRight = 124
    static let keyboardDown = 125
    static let keyboardUp = 126
}

protocol PPGameInputDelegate {
    func onKeyDown(_ index: Int)
    func onKeyUp(_ index: Int)
}

class PPGameInputController {
    struct PadValue {
        var hVal: UInt8 = 64
        var vVal: UInt8 = 64
        var button: UInt8 = 0
        
        init(data: Data) {
            if data.count == 3 {
                hVal = data[0]
                vVal = data[1]
                button = data[2]
            }
        }
        
        static func ==(lhs: PadValue, rhs: PadValue) -> Bool {
            return (lhs.hVal == rhs.hVal) && (lhs.vVal == rhs.vVal) && (lhs.button == rhs.button)
        }
        
        static func !=(lhs: PadValue, rhs: PadValue) -> Bool {
            return (lhs.hVal != rhs.hVal) || (lhs.vVal != rhs.vVal) || (lhs.button != rhs.button)
        }
        
    }
    
    static let gamePadKeyCodeTable: Dictionary<Int, Int?> = [0: .aKey, 1: .bKey, 2: nil, 3: .selectKey, 4: .startKey, 5:nil, 6: nil, 7: nil]
    
    static let keyboardKeyCodeTable: Dictionary<Int, Int> = [.keyboardZ: .aKey, .keyboardX: .bKey, .keyboardA: .selectKey, .keyboardS: .startKey, .keyboardUp: .upKey, .keyboardDown: .downKey, .keyboardLeft: .leftKey, .keyboardRight: .rightKey]

    var lastPadValue: PadValue = PadValue(data: Data())
    var pushedKeys: Set<Int> = []

    var delegate: PPGameInputDelegate?
    
    init(delegate: PPGameInputDelegate? = nil) {
        self.delegate = delegate
        
        setupKeyInput()
        setupHidInput()
    }
    
    private func setupKeyInput() {
        NSEvent.addLocalMonitorForEvents(matching: .keyDown) {
            guard let keyPadCode = PPGameInputController.keyboardKeyCodeTable[Int($0.keyCode)] else { return $0 }
            self.delegate?.onKeyDown(keyPadCode)
            self.pushedKeys.insert(keyPadCode)
            return nil
        }
        
        NSEvent.addLocalMonitorForEvents(matching: .keyUp) {
            guard let keyPadCode = PPGameInputController.keyboardKeyCodeTable[Int($0.keyCode)] else { return $0 }
            self.delegate?.onKeyUp(keyPadCode)
            self.pushedKeys.remove(keyPadCode)
            return nil
        }
    }
    
    //
    //  USB GamePad controller
    //
    private func setupHidInput() {
        NotificationCenter.default.addObserver(self, selector: #selector(self.hidReadData), name: .HIDDeviceDataReceived, object: nil)
    }

    @objc func hidReadData(notification: Notification) {
        if let dic = notification.object as? NSDictionary, let data = dic["data"] as? Data {
            if data.count == 3 {
                if delegate != nil {
                    sendHidKey(PadValue(data: data))
                }
                else {
                    keepHidData(PadValue(data: data))
                }
            }
        }
    }
    
    private func sendHidKey(_ val: PadValue) {
        guard lastPadValue != val else { return }
        
        //  check left, right button
        if val.hVal != lastPadValue.hVal {
            if val.hVal == 0 {
                if lastPadValue.hVal == 127 {
                    delegate?.onKeyUp(.rightKey)
                }
                delegate?.onKeyDown(.leftKey)
            }
            else if val.hVal == 127 {
                if lastPadValue.hVal == 0 {
                    delegate?.onKeyUp(.leftKey)
                }
                delegate?.onKeyDown(.rightKey)
            }
            else {
                if lastPadValue.hVal == 0 {
                    delegate?.onKeyUp(.leftKey)
                }
                else {
                    delegate?.onKeyUp(.rightKey)
                }
            }
        }
        
        //  check up, down button
        if val.vVal != lastPadValue.vVal {
            if val.vVal == 0 {
                if lastPadValue.vVal == 127 {
                    delegate?.onKeyUp(.downKey)
                }
                delegate?.onKeyDown(.upKey)
            }
            else if val.vVal == 127 {
                if lastPadValue.vVal == 0 {
                    delegate?.onKeyUp(.upKey)
                }
                delegate?.onKeyDown(.downKey)
            }
            else {
                if lastPadValue.vVal == 0 {
                    delegate?.onKeyUp(.upKey)
                }
                else {
                    delegate?.onKeyUp(.downKey)
                }
            }
        }
        
        //  check buttons
        let vXor = val.button ^ lastPadValue.button
        for bit in 0..<8 {
            if vXor[bit] {
                if let tableValue = PPGameInputController.gamePadKeyCodeTable[bit], let keyCode = tableValue {
                    if val.button[bit] {
                        delegate?.onKeyDown(keyCode)
                    }
                    else {
                        delegate?.onKeyUp(keyCode)
                    }
                }
            }
        }
        self.lastPadValue = val
    }

    private func keepHidData(_ val: PadValue) {
        lastPadValue = val
    }

    //
    //  For Controller check without delegate
    //    
    func checkController() -> ([Bool], [Bool]) {
        var keyRegisters = [Bool](repeating: false, count: 8)
        var buttonRegisters = [Bool](repeating: false, count: 8)

        if lastPadValue.hVal == 0 {
            keyRegisters[.leftKey] = true
            keyRegisters[.rightKey] = false
        }
        else if lastPadValue.hVal == 127 {
            keyRegisters[.leftKey] = false
            keyRegisters[.rightKey] = true
        }
        else {
            keyRegisters[.leftKey] = false
            keyRegisters[.rightKey] = false
        }
        
        if lastPadValue.vVal == 0 {
            keyRegisters[.upKey] = true
            keyRegisters[.downKey] = false
        }
        else if lastPadValue.vVal == 127 {
            keyRegisters[.upKey] = false
            keyRegisters[.downKey] = true
        }
        else {
            keyRegisters[.upKey] = false
            keyRegisters[.downKey] = false
        }
        
        for bit in 0..<8 {
            if lastPadValue.button[bit] {
                buttonRegisters[bit] = true
            }
        }
        
        //  Keyboard
        for key in pushedKeys {
            if key == .leftKey || key == .rightKey || key == .upKey || key == .downKey {
                keyRegisters[key] = true
            }
            else {
                buttonRegisters[key] = true
            }
        }
        return (keyRegisters, buttonRegisters)
    }
}
