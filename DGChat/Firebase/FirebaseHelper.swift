//
//  FirebaseHelper.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 27/09/23.
//

import Foundation
import Combine
import Firebase
import FirebaseCore
import FirebaseAuth
import FirebaseFirestore

class FirebaseHelper {
    
    static let shared = FirebaseHelper()
    
    var signUpObserver = PassthroughSubject<Bool, Never>()
    var signInObserver = PassthroughSubject<String, Never>()
    var forgotPasswordResetLinkSent = PassthroughSubject<Bool, Never>()
}

// MARK: - Firebase Helper - Authentication

extension FirebaseHelper {
    
/// Sign Up
    public func accountCreate(email: String, password: String) {
        FirebaseAuth.Auth.auth().createUser(withEmail: email, password: password, completion: {result, error in
            result != nil
            ? self.signUpObserver.send(true)
            : self.signUpObserver.send(false)
        })
    }
    
///  Sign In
    public func signInToFirebase(email: String, password: String) {
        FirebaseAuth.Auth.auth().signIn(withEmail: email, password: password, completion: { result, error in
            self.signInObserver.send(result?.user.email ?? "")
        })
    }
    
/// Sign Out
    public func signOutUser() {
        if Auth.auth().currentUser != nil {
            try! Auth.auth().signOut()
        }
    }
    
/// Forgot Password Reset Link share
    public func forgotPasswordReset(email: String) {
        Auth.auth().sendPasswordReset(withEmail: email) { (error) in
            if let error = error {
                self.forgotPasswordResetLinkSent.send(false)
            } else {
                self.forgotPasswordResetLinkSent.send(true)
            }
        }
    }
}
