//
//  FBLoginViewController.swift
//  Splash
//
//  Created by Shreeya Gad on 3/3/22.
//
import SwiftUI
import FBSDKCoreKit
import FBSDKLoginKit
import Firebase

struct FBLoginView: UIViewRepresentable {
    @EnvironmentObject var viewRouter: ViewRouter
    @Binding var username: String
    
    func updateUIView(_ uiView: FBLoginButton, context: UIViewRepresentableContext<FBLoginView>) {
    }
    
    func makeUIView(context: UIViewRepresentableContext<FBLoginView>) -> FBLoginButton {
        // Login Button made by Facebook
        let loginButton = FBLoginButton()
        loginButton.permissions = ["public_profile", "email"]
        loginButton.delegate = context.coordinator
        return loginButton
    }
    
    func makeCoordinator() -> Coordinator {
        return Coordinator(self)
    }
}

class Coordinator: NSObject, LoginButtonDelegate {
    var parent: FBLoginView
    
    init(_ parent: FBLoginView) {
        self.parent = parent
        super.init()
    }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if result?.isCancelled ?? false {
            print("Cancelled")
        } else if error != nil {
            print("ERROR: Trying to get login results")
        } else {
            let request = GraphRequest(graphPath: "me", parameters: ["fields": "name"])
            request.start { (_,res,_) in
                guard let profileData = res as? [String: Any] else {return}
                self.parent.username = profileData["name"] as! String
            }
            parent.viewRouter.currentPage = .homePage
        }
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // Do something after the user pressed the logout button
        try? Auth.auth().signOut()
    }
}
