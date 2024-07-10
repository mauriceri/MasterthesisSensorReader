//
//  SoundService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.06.24.
//

import Foundation
import AVFoundation

class SoundService {
    var player: AVAudioPlayer?
    
    
    func playSound() {
        guard let url = Bundle.main.url(forResource: "interfacesound", withExtension: "mp3") else { return }
        
        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)
            
            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)

            guard let player = player else { return }
            
            player.play()
            
        } catch let error {
            print(error.localizedDescription)
        }
    }
}
