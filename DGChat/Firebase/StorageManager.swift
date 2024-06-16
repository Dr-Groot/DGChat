//
//  StorageManager.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 04/10/23.
//

import Foundation
import FirebaseStorage

final class StorageManager {
    
    static let shared = StorageManager()
    
    private let storage = Storage.storage().reference()
//    Return Url of image if uploaded otherwise error
    public typealias UploadPictureCompletion = (Result<String, Error>) -> Void
    
    // Upload picture to Firebase Storage
    public func uploadProfilePicture(with data: Data, fileName: String, completion: @escaping UploadPictureCompletion) {
        storage.child("images/\(fileName)").putData(data, metadata: nil, completion: {metadata, error in
            guard error == nil else {
                // Failed
                print("Failed to upload picture to Firebase")
                completion(.failure(StorageErrors.failedToUpload))
                return
            }
            
            self.storage.child("images/\(fileName)").downloadURL(completion: { url, error in
                guard let url = url else {
                    print("Failed to get download url from Firebase")
                    completion(.failure(StorageErrors.failedToGetDownloadUrl))
                    return
                }
                
                let urlString = url.absoluteString
                print("Download Profile Picture URL: \(urlString)")
                completion(.success(urlString))
            })
        })
    }
}
