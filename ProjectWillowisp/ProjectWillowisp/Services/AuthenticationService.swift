//
//  AuthenticationService.swift
//  ProjectWillowisp
//
//  Created by Bryan Malumphy on 8/8/22.
//

import Foundation
import UIKit
import Supabase
import Combine
import SafariServices
import RevenueCat
import GoTrue

final class AuthenticationService {
    
    static let productId = "reverie_premium_one_month"
    
    static let shared = AuthenticationService()
    
    private let supabaseClient: SupabaseClient = SupabaseProvider.shared.supabaseClient
    
    private lazy var authSubject = PassthroughSubject<Bool, Never>()
    lazy var authPublisher = authSubject.eraseToAnyPublisher()
        
    private init() {}
    
    private var safariVC: SFSafariViewController?
    
    func loginWithDiscord(with presenting: UIViewController) {
        Task {
            do {
                NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(self.oAuthCallback(_:)),
                            name: NSNotification.Name(rawValue: "OAuthCallBack"),
                            object: nil)
                let url = try supabaseClient.auth.getOAuthSignInURL(
                    provider: .discord,
                    redirectTo: URL(
                        string: SupabaseProvider.shared.discordCallbackUrl)!)
                let safariVC = await SFSafariViewController(url: url as URL)
                self.safariVC = safariVC
                await presenting.present(safariVC, animated: true, completion: nil)
            } catch {
                authSubject.send(false)
                print("### Discord Sign in Error: \(error)")
            }
        }
    }
    
    func loginWithApple(with presentingVC: UIViewController) {
        Task {
            do {
                NotificationCenter.default.addObserver(
                            self,
                            selector: #selector(self.oAuthCallback(_:)),
                            name: NSNotification.Name(rawValue: "OAuthCallBack"),
                            object: nil)
                let url = try supabaseClient.auth.getOAuthSignInURL(provider: .apple, redirectTo: URL(string: "projectfyt://login-callback")!)
                safariVC = await SFSafariViewController(url: url as URL)
                await presentingVC.present(safariVC!, animated: true, completion: nil)
            } catch {
                print("### Apple Sign in Error: \(error)")
            }
        }
    }
    
    func hasCredentials() async -> Bool {
        return (try? await supabaseClient.auth.session.providerToken) != nil
    }
    
    func currentUserEmail() async -> String? {
        return (try? await supabaseClient.auth.session.user.email)
    }
    
    func currentUserId() async -> UUID? {
        return (try? await supabaseClient.auth.session.user.id)
    }
                
    @objc private func oAuthCallback(_ notification: NSNotification){
        guard let url = notification.userInfo?["url"] as? URL  else { return }
        Task {
            do {
                try await supabaseClient.auth.session(from: url)
                guard let currentUserId = await currentUserId()?.uuidString else { return }
                Purchases.shared.logIn(currentUserId) { [weak self] purchaserInfo, created, error in
                    if let error = error {
                        print(error)
                    }
                    
                    if purchaserInfo?.activeSubscriptions.contains(Self.productId) == true {
                        UserDefaults.standard.set(true, forKey: Self.productId)
                    } else {
                        UserDefaults.standard.set(false, forKey: Self.productId)
                    }
                    self?.authSubject.send(true)
                }
            } catch {
                authSubject.send(false)
                print("### oAuthCallback error: \(error)")
            }
        }
        safariVC?.dismiss(animated: true)
    }
    
    func logout(presentingVC: UIViewController) async {
        do {
            try await supabaseClient.auth.signOut()
            DispatchQueue.main.async {
                presentingVC.dismiss(animated: true)
                Purchases.shared.logOut() {_,_ in
                    UserDefaults.standard.setValue(false, forKey: AuthenticationService.productId)
                }
            }
        } catch {
            print("### Logout error: \(error)")
        }
    }
    
    func deleteUser() async -> Bool {
        let success = await UserProfileService.shared.deleteUser()
        return success
    }
    
    func updateEmail(email: String) async -> Bool {
        let success = (try? await supabaseClient.auth.update(user: UserAttributes(email: email))) != nil
        return success
    }
    
    func updatePassword(password: String) async -> Bool {
        let success = (try? await supabaseClient.auth.update(user: UserAttributes(password: password))) != nil
        return success
    }
}
