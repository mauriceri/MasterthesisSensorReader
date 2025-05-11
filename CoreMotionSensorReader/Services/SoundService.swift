//
//  SoundService.swift
//  CoreMotionSensorReader
//
//  Created by Maurice Richter on 19.06.24.
//

import Foundation
import AVFoundation

class SoundService {
    private var player: AVAudioPlayer?

    private func playSound(named name: String) {
        guard let url = Bundle.main.url(forResource: name, withExtension: "mp3") else {
            print("Sounddatei '\(name).mp3' nicht gefunden.")
            return
        }

        do {
            try AVAudioSession.sharedInstance().setCategory(.playback, mode: .default)
            try AVAudioSession.sharedInstance().setActive(true)

            player = try AVAudioPlayer(contentsOf: url, fileTypeHint: AVFileType.mp3.rawValue)
            player?.play()
        } catch {
            print("Fehler beim Abspielen von '\(name).mp3': \(error.localizedDescription)")
        }
    }

    func playSound() {
        playSound(named: "interfacesound")
    }

    func playBodyPosSound() {
        playSound(named: "feedbacksound")
    }

    func playLeft() {
        playSound(named: "links")
    }

    func playRight() {
        playSound(named: "rechts")
    }

    func playDown() {
        playSound(named: "unten")
    }

    func playUp() {
        playSound(named: "oben")
    }

    func playLeftInclined() {
        playSound(named: "linksgeneigt")
    }

    func playRightInclined() {
        playSound(named: "rechtsgeneigt")
    }
    
    func playCalibrated() {
        playSound(named: "kalibriert")
    }
    
    func playDownLeft() {
        playSound(named: "ulinks")
    }
    
    func playDownRight() {
        playSound(named: "urechts")
    }
    
    func playUpLeft() {
        playSound(named: "obenlinks")
    }
    
    func playUpRight() {
        playSound(named: "obenrechts")
    }
}

