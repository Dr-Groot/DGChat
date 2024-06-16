//
//  CommonHelper.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 05/10/23.
//

import Foundation
import Firebase

class CommonHelper {
    
    static let shared = CommonHelper()
    
    public func getSafeName() -> String {
        let email = Auth.auth().currentUser?.email ?? ""
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        return safeEmail
    }
    
    public func getPictureFileName() -> String {
        return("\(getSafeName())_profile_picture.png")
    }
}
