//
//  OptionsViewController.swift

import UIKit

class OptionsViewController: UIViewController {
    @IBOutlet weak var sound: UIButton!
    @IBOutlet weak var vibro: UIButton!
    
    @IBOutlet var gameModeButtons: [UIButton]!
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if AppSettings.configuration == .free {
            for button in gameModeButtons {
                if AppSettings.configuration == .free {
                    button.isEnabled = button.tag == 0
                }
            }
        }
        
        for button in gameModeButtons {
            button.isSelected = button.tag == Options.shared.gameMode
        }
        
        sound.isSelected = Options.shared.sound
        vibro.isSelected = Options.shared.vibration
    }
    
    @IBAction func backTapped(sender: UIButton) {
        navigationController?.popViewController(animated: true)
    }
    
    @IBAction func soundButtoDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Options.shared.sound = sender.isSelected
        
        if Options.shared.sound {
            AudioManager.shared.play(music: Audio.MusicFiles.background )
        } else {
            AudioManager.shared.pause()
        }
    }
    
    @IBAction func vibroButtoDidTap(_ sender: UIButton) {
        sender.isSelected = !sender.isSelected
        Options.shared.vibration = sender.isSelected
    }
    
    @IBAction func gameModeDidTap(_ sender: UIButton) {
        clearButtonsState()
        sender.isSelected = true
        Options.shared.gameMode = sender.tag
        
    }
    
    func clearButtonsState() {
        for button in gameModeButtons {
            button.isSelected = false
        }
    }
    
    
}
