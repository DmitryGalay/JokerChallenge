//
//  LaunchArguments.swift


import Foundation

public struct LaunchArguments {
    public static let Test = "FIREFOX_TEST"
    public static let SkipIntro = "FIREFOX_SKIP_INTRO"
    public static let SkipWhatsNew = "FIREFOX_SKIP_WHATS_NEW"
    public static let SkipETPCoverSheet = "FIREFOX_SKIP_ETP_COVER_SHEET"
    public static let ClearProfile = "FIREFOX_CLEAR_PROFILE"
    public static let StageServer = "FIREFOX_USE_STAGE_SERVER"
    public static let DeviceName = "DEVICE_NAME"
    public static let ServerPort = "GCDWEBSERVER_PORT:"

    // After the colon, put the name of the file to load from test bundle
    public static let LoadDatabasePrefix = "FIREFOX_LOAD_DB_NAMED:"
}
