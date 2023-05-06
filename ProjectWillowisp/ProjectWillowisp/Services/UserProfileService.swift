//
//  UserService.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import Foundation
import Combine
import Supabase

enum ProfileError: Error {
    case deletedUser
}

final class User: JSONCodable {
    let id: UUID
    var username: String?
    var bio: String?
    var cover_image_url: String?
    var avatar_url: String?
    var deleted: Bool
    let created_at: String
    var is_subscribed: Bool {
        return UserDefaults.standard.bool(forKey: AuthenticationService.productId)
    }
    
    init(id: UUID, displayName: String?, bio: String?, coverImageUrl: String?, profileImageUrl: String?, user_id: Int, deleted: Bool, created_at: String) {
        self.id = id
        self.username = displayName
        self.bio = bio
        self.cover_image_url = coverImageUrl
        self.avatar_url = profileImageUrl
        self.deleted = deleted
        self.created_at = created_at
    }
}

final class UserProfileService {
    
    static let shared = UserProfileService()
    
    private let profileDatabase = SupabaseProvider.shared.profileDatabase
    
    private lazy var currentUserSubject = CurrentValueSubject<User?, Never>(nil)
    lazy var currentUserPublisher = currentUserSubject.eraseToAnyPublisher()
    
    var currentUser: User? {
        return currentUserSubject.value
    }
    
    private init() {}
    
    func getCurrentUserProfile() async -> User? {
        guard let userId = await SupabaseProvider.shared.loggedInUserId() else { return nil }
        let query = SupabaseProvider
            .shared
            .profileDatabase
            .select()
            .match(query: ["id": userId])
            .single()
                    
        do {
            let response: User = try await query.execute().value
            if response.deleted {
                throw ProfileError.deletedUser
            }
            print("VALUE RETURNED: \(response)")
            currentUserSubject.send(response)
            return response
        } catch {
            print("ERROR FETCHING USER: \(error.localizedDescription)")
            return nil
        }
    }
    
    func getUserWithId(_ id: String) async -> User? {
        let query = SupabaseProvider
            .shared
            .profileDatabase
            .select()
            .match(query: ["id": id])
            .single()
                    
        do {
            let response: User = try await query.execute().value
            print("VALUE RETURNED: \(response)")
            currentUserSubject.send(response)
            return response
        } catch {
            print("ERROR FETCHING USER: \(error.localizedDescription)")
            return nil
        }

    }
    
    func updateBio(bio: String?) async -> Bool {
        guard let user = currentUser else { return false }
        user.bio = bio
        currentUserSubject.send(user)
        return (try? await profileDatabase.update(values: user).execute().value) != nil
    }
    
    func updateProfileUrl(url: String?) async -> Bool {
        guard let user = currentUser else { return false }
        user.avatar_url = url
        currentUserSubject.send(user)
        return (try? await profileDatabase.update(values: user).execute().value) != nil
    }
    
    func updateDisplayName(name: String?) async -> Bool {
        guard let user = currentUser else { return false }
        user.username = name
        currentUserSubject.send(user)
        return (try? await profileDatabase.update(values: user).execute().value) != nil
    }
    
    func updateCoverPhoto(url: String?) async -> Bool {
        guard let user = currentUser else { return false}
        user.cover_image_url = url
        currentUserSubject.send(user)
        return (try? await profileDatabase.update(values: user).execute().value) != nil
    }
    
    func deleteUser() async ->Bool {
        guard let user = currentUser else { return false}
        user.deleted = true
        currentUserSubject.send(user)
        return (try? await profileDatabase.update(values: user).execute().value) != nil
    }
}
