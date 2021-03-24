//
//  Options.swift

import Foundation

struct OptionsKey {
    static let vibration = "kGameVibaration"
    static let sound = "kGameSound"
    static let gameMode = "kGameMode"
    static let score = "gameScoreKey"
}
class Options {
    var allGameSettings = [GameSettings]()
    static let shared = Options()
    init() {
        
        if UserDefaults.standard.value(forKey: OptionsKey.sound) == nil {
            sound = true
        }
        if UserDefaults.standard.value(forKey: OptionsKey.vibration) == nil {
            vibration = true
        }
    }

var vibration: Bool {
    set {
        UserDefaults.standard.set(newValue, forKey: OptionsKey.vibration)
        UserDefaults.standard.synchronize()
    }
    get {
        return UserDefaults.standard.bool(forKey: OptionsKey.vibration)
    }
}

var sound: Bool {
    set {
        UserDefaults.standard.set(newValue, forKey: OptionsKey.sound)
        UserDefaults.standard.synchronize()
    }
    get {
        return UserDefaults.standard.bool(forKey: OptionsKey.sound)
    }
}

var gameMode: Int {
    set {
        UserDefaults.standard.set(newValue, forKey: OptionsKey.gameMode)
        UserDefaults.standard.synchronize()
    }
    get {
        return UserDefaults.standard.integer(forKey: OptionsKey.gameMode)
    }
}

var score: Int {
    set {
        UserDefaults.standard.set(newValue, forKey: OptionsKey.score)
        UserDefaults.standard.synchronize()
    }
    get {
        return UserDefaults.standard.integer(forKey: OptionsKey.score)
    }
}


}
