//
//  VideoFetchingService.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 3/26/23.
//

import Supabase
import SupabaseStorage
import Combine
import GiphyUISDK
import Realtime

struct LikedPosts: JSONCodable {
    let reply_id: UUID?
    let post_id: UUID?
    let user_id: UUID
    let post: Post
}

final class SocialInteractionService {
    
    static let shared = SocialInteractionService()
    
    var creator_id: UUID {
        return UUID(uuidString: "2eb3a18b-d85a-4241-85bf-3856f933d7bf")!
    }
    
    private let currentPostsSubject = CurrentValueSubject<[Post], Never>([])
    
    var currentCreatorPosts: [Post] {
        return currentPostsSubject.value.filter { $0.user.id == creator_id }.sorted(by: {
            return $0.created_at > $1.created_at
        }).sorted(by: {
            $0.is_pinned && !$1.is_pinned
        })
    }
    
    var currentPremiumPosts: [Post] {
        return currentPostsSubject.value.filter { $0.user.id != creator_id }.sorted(by: {
            return $0.created_at > $1.created_at
        }).sorted(by: {
            $0.is_pinned && !$1.is_pinned
        })
    }
    
    private let currentPlaylistsSubject = CurrentValueSubject<[Playlist], Never>([])
    
    var currentPlaylists: [Playlist] {
        return currentPlaylistsSubject.value
    }
    
    private init() {}
    
    func retrievePosts() async {
        let postsQuery = SupabaseProvider.shared.postDatabase.select(columns: "*,user:profiles(*),likes:likes(*,user:profiles(*)),comments:replies(*,user:profiles(*),likes:likes(*,User:profiles(*)))")
        do {
            let response: [Post] = try await postsQuery.execute().value
            currentPostsSubject.send(response)
        } catch {
            print("ERROR FETCHING POSTS \(error)")
        }
    }
    
    func likePost(postId: UUID?, replyId: UUID?, userId: UUID) async -> Bool {
        let like = Like(reply_id: replyId, post_id: postId, user_id: userId)
        let likeQuery = SupabaseProvider.shared.likesDatabase.insert(values: like)
        
        do {
            let _ = try await likeQuery.execute().value
            if postId != nil {
                currentPostsSubject.value.first(where: { $0.id == postId })?.likes?.append(like)
            } else {
                currentPostsSubject.value.first(where: { $0.comments?.contains(where: { $0.id == replyId }) ?? false })?.comments?.first(where: { $0.id == replyId })?.likes?.append(like)
            }
            return true
        } catch {
            print("ERROR LIKING POST")
        }
        
        return false
    }
    
    func fetchPlaylists() async {
        let playlistsQuery = SupabaseProvider.shared.supabaseClient.database.from("playlists").select(columns: "*,playlistItems:playlistitems(*,post:posts(*,user:profiles(*)))")
        do {
            let response: [Playlist] = try await playlistsQuery.execute().value
            currentPlaylistsSubject.send(response)
        } catch {
            print("ERROR FETCHING PLAYLISTS \(error)")
        }
    }
    
    func addPlaylist(_ playlist: Playlist) {
        currentPlaylistsSubject.send(currentPlaylistsSubject.value + [playlist])
    }
    
    func getLikedPosts(userId: UUID) async -> [LikedPosts] {
        guard let user = UserProfileService.shared.currentUser else { return [] }
        
        do {
            let likedPosts: [LikedPosts] = try await SupabaseProvider.shared.supabaseClient.database.from("likes").select(columns: "*,post:posts(*,user:profiles(*))").match(query: ["user_id": user.id]).execute().value
            return likedPosts
        } catch {
            print(error)
            return []
        }
    }
    
    func postReply(postId: UUID, message: String?, levelToIncrementTo: Int, media: GPHMedia?) async {
        struct ReplyPostRequest: Codable {
            let post_id: UUID
            let message: String?
            let gif_id: String?
            let user_id: UUID
            let level: Int
            let gif_aspect_ratio: Double
        }
        
        guard let user = UserProfileService.shared.currentUser else { return }
        
        let commentPostQuery: Void? = try! await SupabaseProvider.shared.commentDatabase.insert(
            values: ReplyPostRequest(
                post_id: postId,
                message: message,
                gif_id: media?.id,
                user_id: user.id,
                level: levelToIncrementTo,
                gif_aspect_ratio: Double(media?.aspectRatio ?? 1.0)
            )).execute().value
        
        if commentPostQuery == nil {
            print("ERROR MAKING COMMENT")
        }
    }
}
