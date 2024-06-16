//
//  DatabaseManager.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 28/09/23.
//

import Foundation
import Firebase
import FirebaseDatabase

class DatabaseManager {
    
    static let shared = DatabaseManager()
    private let database =  Database.database().reference()
}

// MARK: - Account Management - Firebase Realtime DB

extension DatabaseManager {
    
// Validate existing user
    public func userExsitsCheck(with email: String, completion: @escaping ((Bool) -> Void)) {
        var safeEmail = email.replacingOccurrences(of: ".", with: "-")
        safeEmail = safeEmail.replacingOccurrences(of: "@", with: "-")
        
        database.child(safeEmail).observeSingleEvent(of: .value, with: { snapshot in
           snapshot.childrenCount == 0
            ? completion(true)
            : completion(false)
        })
    }
    
// Inserts new user to database
    public func insertUser(with user: ChatAppUser, completion: @escaping (Bool) -> Void) {
        database.child(user.safeEmail).setValue([
            "first_name": user.firstName,
            "last_name": user.lastName,
        ], withCompletionBlock: { error ,_  in
            
            guard error == nil else {
                print("Failed to Write To DB")
                completion(false)
                return
            }
            completion(true)
            
// Adding user to global user list
            self.database.child("users").observeSingleEvent(of: .value, with: { snapshot in
                if var usersCollections = snapshot.value as? [[String: String]] {
// Append user to dictionary
                    let newElement = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    usersCollections.append(contentsOf: newElement)
                    self.database.child("users").setValue(usersCollections)
                } else {
// Create user array
                    let newCollection: [[String: String]] = [
                        [
                            "name": user.firstName + " " + user.lastName,
                            "email": user.safeEmail
                        ]
                    ]
                    self.database.child("users").setValue(newCollection)
                }
            })
        })
    }
    
//  Get username from DB and save to UserDefaults
    public func getUserName() {
        database.child(CommonHelper.shared.getSafeName()).observeSingleEvent(of: .value, with: { snapshot in
            let firstName = snapshot.childSnapshot(forPath: "first_name").value as! String
            let lastName = snapshot.childSnapshot(forPath: "last_name").value as! String
            let name: String = firstName + " " + lastName
            UserDefaults.standard.setValue(name, forKey: L10n.userNameKey)
        })
    }
    
//  Get All Users from DB
    public func getAllUsers(completion: @escaping (Result<[[String: String]], Error>) -> Void) {
        database.child("users").observeSingleEvent(of: .value, with: {snapshot in
            guard let value = snapshot.value as? [[String: String]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            completion(.success(value))
        })
    }
}

// MARK: - Sending Messages/ Conversation - Firebase Realtime DB

extension DatabaseManager {
    
// Create new conversation with target user email and First message sent
    public func createNewConversation(with otherUserEmail: String, name: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let safeEmail = CommonHelper.shared.getSafeName()
        guard let currentName = UserDefaults.standard.value(forKey: L10n.userNameKey) as? String  else {
            return
        }
        let ref = database.child("\(safeEmail)")
        
        ref.observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard var userNode = snapshot.value as? [String: Any] else {
                completion(false)
                print("User Not Found")
                return
            }
            
            let messageDate = firstMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch firstMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let conversationID = "conversation_\(firstMessage.messageId)"
 
//  Current User Conversation
            let newConversation: [String: Any] = [
                "id": conversationID,
                "other_user_email": otherUserEmail,
                "name": name,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
 
//  Recipient Conversation
            let recipient_newConversation: [String: Any] = [
                "id": conversationID,
                "other_user_email": safeEmail,
                "name": currentName,
                "latest_message": [
                    "date": dateString,
                    "message": message,
                    "is_read": false
                ]
            ]
            
// Update reciepient Conversation Entry
            self?.database.child("\(otherUserEmail)/conversations").observeSingleEvent(of: .value, with: { [weak self] snapshot in
                
                if var conversations = snapshot.value as? [[String: Any]] {
        // Append
                    conversations.append(recipient_newConversation)
                    self?.database.child("\(otherUserEmail)/conversations").setValue([conversations])
                } else {
        // Create
                    self?.database.child("\(otherUserEmail)/conversations").setValue([recipient_newConversation])
                }
            })
            
// Update Current User Conversation Entry
            if var conversation = userNode["conversations"] as? [[String: Any]] {
        // Converstaion exists => Append
                conversation.append(newConversation)
                userNode["conversations"] = conversation
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            } else {
        // Create new Conversation
                userNode["conversations"] = [
                    newConversation
                ]
                
                ref.setValue(userNode, withCompletionBlock: {[weak self] error, _ in
                    guard error == nil else {
                        completion(false)
                        return
                    }
                    self?.finishCreatingConversation(name: name, conversationID: conversationID, firstMessage: firstMessage, completion: completion)
                })
            }
        })
    }
    
 
//  Create Conversation in DB - "conversation_\(firstMessage.messageId)"
    private func finishCreatingConversation(name: String, conversationID: String, firstMessage: Message, completion: @escaping (Bool) -> Void) {
        
        let messageDate = firstMessage.sentDate
        let dateString = ChatViewController.dateFormatter.string(from: messageDate)
        var message = ""
        
        switch firstMessage.kind {
        case .text(let messageText):
            message = messageText
        case .attributedText(_):
            break
        case .photo(_):
            break
        case .video(_):
            break
        case .location(_):
            break
        case .emoji(_):
            break
        case .audio(_):
            break
        case .contact(_):
            break
        case .linkPreview(_):
            break
        case .custom(_):
            break
        }
        
        let currentUserEmail = CommonHelper.shared.getSafeName()
        
        let collectionMessage: [String: Any] = [
            "id": firstMessage.messageId,
            "type": firstMessage.kind.MessageKindString,
            "content": message,
            "date": dateString,
            "sender_email": currentUserEmail,
            "is_read": false,
            "name": name
        ]
        
        let value: [String: Any] = [
            "message": [
                collectionMessage
            ]
        ]
        
        database.child("\(conversationID)").setValue(value, withCompletionBlock: {error, _ in
            guard error == nil else {
                completion(false)
                return
            }
            completion(true)
        })
    }
    
// Fetches and return all conversation with the user with passed in email
    public func getAllConversation(for email: String, completion: @escaping (Result<[Conversation], Error>) -> Void) {
        
        database.child("\(email)/conversations").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let conversations: [Conversation] = value.compactMap({dictionary in
                guard let converstaionID = dictionary["id"] as? String,
                      let name = dictionary["name"] as? String,
                      let otherUserEmail = dictionary["other_user_email"] as? String,
                      let latestMessage = dictionary["latest_message"] as? [String: Any],
                      let date = latestMessage["date"] as? String,
                      let message = latestMessage["message"] as? String,
                      let isRead = latestMessage["is_read"] as? Bool else {
                    return nil
                }
                
                let latestMessageObject = LatestMessage(date: date, text: message, isRead: isRead)
                return Conversation(id: converstaionID, name: name, otherUserEmail: otherUserEmail, latestMEssage: latestMessageObject)
            })
            
            completion(.success(conversations))
        })
    }
    
// Get all messages for a given conversation
    public func getAllMessageForConversation(with id: String, completion: @escaping (Result<[Message], Error>) -> Void) {
        
        database.child("\(id)/message").observe(.value, with: { snapshot in
            
            guard let value = snapshot.value as? [[String: Any]] else {
                completion(.failure(DatabaseError.failedToFetch))
                return
            }
            
            let messages: [Message] = value.compactMap({dictionary in
                guard let name = dictionary["name"] as? String,
                      let isRead = dictionary["is_read"] as? Bool,
                      let messageID = dictionary["id"] as? String,
                      let content = dictionary["content"] as? String,
                      let senderEmail = dictionary["sender_email"] as? String,
                      let dateString = dictionary["date"] as? String,
                      let type = dictionary["type"] as? String else {
                    return nil
                }
                
                let sender = Sender(photoURL: "", senderId: senderEmail, displayName: name)
                
                return Message(sender: sender, messageId: messageID, sentDate: Date(), kind: .text(content))
            })
            
            completion(.success(messages))
        })
    }
    
// Sends a message with target conversation and message
    public func sendMessage(to conversation: String, name: String, newMessage: Message, completion: @escaping (Bool) -> Void) {
///   Steps :-
        /// Add new Message to Messages
        /// Update sender latest message
        /// Update recipient latest message
        
        self.database.child("\(conversation)/message").observeSingleEvent(of: .value, with: { [weak self] snapshot in
            
            guard let strongSelf = self else {
                return
            }
            
            guard var currentMessages = snapshot.value as? [[String: Any]] else {
                completion(false)
                return
            }
            
            let messageDate = newMessage.sentDate
            let dateString = ChatViewController.dateFormatter.string(from: messageDate)
            
            var message = ""
            
            switch newMessage.kind {
            case .text(let messageText):
                message = messageText
            case .attributedText(_):
                break
            case .photo(_):
                break
            case .video(_):
                break
            case .location(_):
                break
            case .emoji(_):
                break
            case .audio(_):
                break
            case .contact(_):
                break
            case .linkPreview(_):
                break
            case .custom(_):
                break
            }
            
            let currentUserEmail = CommonHelper.shared.getSafeName()
            
            let newMessageEntry: [String: Any] = [
                "id": newMessage.messageId,
                "type": newMessage.kind.MessageKindString,
                "content": message,
                "date": dateString,
                "sender_email": currentUserEmail,
                "is_read": false,
                "name": name
            ]
            
            currentMessages.append(newMessageEntry)
            
            strongSelf.database.child("\(conversation)/message").setValue(currentMessages, withCompletionBlock: { error, _ in
                guard error == nil else {
                    completion(false)
                    return
                }
                completion(true)
            })
        })
    }
 }

