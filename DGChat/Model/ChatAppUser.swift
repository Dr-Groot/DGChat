//
//  ChatAppUser.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 28/09/23.
//

import Foundation

struct ChatAppUser {
    let firstName: String
    let lastName: String
    let emailAddress: String
    
    var profilePicutreFileName: String {
        return "\(safeEmail)_profile_picture.png"
    }
    
    var safeEmail: String {
        var safeEmail = emailAddress.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
}
