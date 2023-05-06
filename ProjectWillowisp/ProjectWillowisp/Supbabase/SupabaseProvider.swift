//
//  SupabaseConstants.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import Foundation
import Supabase
import SupabaseStorage
import Realtime
import Combine

class SupabaseProvider {
    
    private let apiDictionaryKey = "supabase-key"
    private let supabaseUrlKey = "supabase-url"
    private let discordUrlKey = "discord-callback-url"
    
    private let appConfigSubject = CurrentValueSubject<AppConfig?, Never>(nil)
    var appConfig: AppConfig? {
        return appConfigSubject.value
    }
    
    private init() {}
    
    static let shared = SupabaseProvider()
    
    lazy var supabaseClient: SupabaseClient = {
        return SupabaseClient(supabaseURL: supabaseUrl, supabaseKey: apiKey)
    }()
    
    func loggedInUserId() async -> String? {
        return try? await SupabaseProvider.shared.supabaseClient.auth.session.user.id.uuidString
    }
    
    private var keysPlist: NSDictionary {
        if
            let path = Bundle.main.path(forResource: "Keys", ofType: "plist"),
            let dictionary = NSDictionary(contentsOfFile: path) {
            return dictionary
        }
        fatalError("You must have a Keys.plist file in your application codebase.")
    }
    
    private var apiKey: String {
        guard let apiKey = keysPlist[apiDictionaryKey] as? String else {
            fatalError("Your Keys.plist must have a key of: \(apiDictionaryKey) and a corresponding value of type String.")
        }
        return apiKey
    }
    
    var supabaseUrl: URL {
        guard let url = keysPlist[supabaseUrlKey] as? String else {
            fatalError("Your Keys.plist must have a key of: \(supabaseUrlKey) and a corresponding value of type String.")
        }
        return URL(string: url)!
    }
    
    var discordCallbackUrl: String {
        guard let url = keysPlist[discordUrlKey] as? String else {
            fatalError("Your Keys.plist must have a key of: \(discordUrlKey) and a corresponding value of type String.")
        }
        return url
    }
    
    // Storage
    
    func storageClient(bucketName: String = "photos") async -> StorageFileApi? {
        guard let jwt = try? await supabaseClient.auth.session.accessToken else { return nil}
        return SupabaseStorageClient(
            url: "\(supabaseUrl)/storage/v1",
            headers: [
                "Authorization": "Bearer \(jwt)",
                "apikey": apiKey,
            ]
        ).from(id: bucketName)
    }
    
    // Data
    
    lazy var profileDatabase = supabaseClient.database.from("profiles")
    
    lazy var postDatabase = supabaseClient.database.from("posts")

    lazy var contentDatabase = supabaseClient.database.from("content")
    
    lazy var commentDatabase = supabaseClient.database.from("replies")
    
    lazy var likesDatabase = supabaseClient.database.from("likes")
    
    lazy var playlistsDatabase = supabaseClient.database.from("playlists")
    
    lazy var playlistItemsDatabase = supabaseClient.database.from("playlistitems")
    
    lazy var appConfigDatabase = supabaseClient.database.from("app_config")
    
    // Realtime
    
    lazy var realtimeClient = {
        let client = RealtimeClient(
            endPoint: "\(supabaseUrl)/realtime/v1",
            params: ["apikey": apiKey])
        client.connect()
        return client
    }()
    lazy var realtimePostChanges = realtimeClient.channel(.table("posts", schema: "public"))
    
    lazy var realtimeCommentChanges = realtimeClient.channel(.table("replies", schema: "public"))
}
