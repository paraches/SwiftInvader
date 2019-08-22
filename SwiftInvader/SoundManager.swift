//
//  SoundManager.swift
//  SwiftInvader
//
//  Created by paraches on 2019/08/19.
//  Copyright © 2019年 paraches lifestyle lab. All rights reserved.
//

import Foundation
import AVFoundation

enum SoundName: String, CaseIterable {
    case invader_0 = "invader_0"
    case invader_1 = "invader_1"
    case invader_2 = "invader_2"
    case invader_3 = "invader_3"
}

extension SoundName {
    func previousSound() -> SoundName {
        switch self {
        case .invader_0:
            return .invader_3
        case .invader_1:
            return .invader_0
        case .invader_2:
            return .invader_1
        case .invader_3:
            return .invader_2
        }
    }
}

class SoundManager {
    static let sharedInstance = SoundManager()
    private var players = [SoundName: AVAudioPlayer]()
    
    private init() {
        for soundName in SoundName.allCases {
            guard let bundle = Bundle.main.path(forResource: soundName.rawValue, ofType: "wav") else { continue }
            let soundFileNameURL = URL(fileURLWithPath: bundle)
            do {
                let player = try AVAudioPlayer(contentsOf: soundFileNameURL)
                players[soundName] = player
                player.prepareToPlay()
            } catch let error {
                print(error.localizedDescription)
            }
        }
    }
    
    func play(_ sound: SoundName) {
        guard  let player = players[sound] else { return }

        if let previousPlayer = players[sound.previousSound()], previousPlayer.isPlaying {
            previousPlayer.stop()
            previousPlayer.prepareToPlay()
        }
        player.play()
    }
}
