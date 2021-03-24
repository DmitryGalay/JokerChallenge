//
//  AudioManager.swift

import AVFoundation
import AVKit

public protocol SoundFile {
    var filename: String { get }
    var type: String { get }
}

public struct Music: SoundFile {
    public var filename: String
    public var type: String
}

public struct Effect: SoundFile {
    public var filename: String
    public var type: String
}

class AudioManager {
	
	public var backgroundMusicPlayer: AVAudioPlayer?
	public var soundEffectPlayer: AVAudioPlayer?
	
	static let shared = AudioManager()
	
	func play(music: Music) {
		guard Options.shared.sound else {
			return
		}
		if let player = backgroundMusicPlayer, player.isPlaying == false {
			player.play()
			return
		} else {
			backgroundMusicPlayer?.stop()
			guard let newPlayer = try? AVAudioPlayer(soundFile: music) else { return }
			newPlayer.play()
			backgroundMusicPlayer = newPlayer
		}
	}
	
    func pause() {
        backgroundMusicPlayer?.pause()
    }
    
    func play(effect: Effect) {
		guard Options.shared.sound else {
			return
		}
        guard let effectPlayer = try? AVAudioPlayer(soundFile: effect) else { return }
        effectPlayer.play()
        soundEffectPlayer = effectPlayer
    }
}

extension AVAudioPlayer {
    
    public enum AudioPlayerError: Error {
        case fileNotFound
    }
    
    public convenience init(soundFile: SoundFile) throws {
        guard let url = Bundle.main.url(forResource: soundFile.filename, withExtension: soundFile.type) else { throw AudioPlayerError.fileNotFound }
        try self.init(contentsOf: url)
    }
}

