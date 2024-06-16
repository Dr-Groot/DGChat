//
//  ChatViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 03/10/23.
//

import UIKit
import MessageKit
import InputBarAccessoryView
import Firebase

class ChatViewController: MessagesViewController {

    public static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .medium
        formatter.timeStyle = .long
        formatter.locale = .current
        return formatter
    }()
    public var conversationId: String?
    public var isNewConverstaion = false
    public var otherUserEmail: String = ""
    public var otherUserName: String = ""
    private var messages = [Message]()
    
    private var selfSender: Sender? {
        let safeEmail = CommonHelper.shared.getSafeName()
        
        return Sender(
            photoURL: "",
            senderId: safeEmail,
            displayName: "Me"
        )
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        configTheme()
        messagesCollectionView.messagesDataSource = self
        messagesCollectionView.messagesLayoutDelegate = self
        messagesCollectionView.messagesDisplayDelegate = self
        messageInputBar.delegate = self
    }
    
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        messageInputBar.inputTextView.becomeFirstResponder()
        if let conversationId = conversationId {
            listenForMessages(id: conversationId)
        }
    }

    private func configTheme() {}
    
    private func listenForMessages(id: String) {
        DatabaseManager.shared.getAllMessageForConversation(with: id, completion: { [weak self] result in
            switch result {
            case .success(let messages):
                guard !messages.isEmpty else {
                    return
                }
                self?.messages = messages
                
                DispatchQueue.main.async {
                    self?.messagesCollectionView.reloadDataAndKeepOffset()
                }
                
            case .failure(let error):
                print("Failed To Load Messages \(error)")
            }
        })
    }
}

extension ChatViewController: InputBarAccessoryViewDelegate {
    
    private func createMessageId() -> String? {
//        Combination of SelfEmail + Date + OtherUserEmail + RandomInt
        
        let currentUserEmail = CommonHelper.shared.getSafeName()
        
        let dateString = Self.dateFormatter.string(from: Date())
        
        let newIdentifier = "\(otherUserEmail)_\(currentUserEmail)_\(dateString)"
        print("MESSAGE ID: \(newIdentifier)")
        return newIdentifier
    }
    
    func inputBar(_ inputBar: InputBarAccessoryView, didPressSendButtonWith text: String) {
        guard !text.replacingOccurrences(of: " ", with: "").isEmpty,
              let selfSender = self.selfSender,
              let messageId = createMessageId() else {
            return
        }
        
        let message = Message(
            sender: selfSender,
            messageId: messageId,
            sentDate: Date(),
            kind: .text(text)
        )
        
//      Send message
        if isNewConverstaion {
//            create new conversation
            DatabaseManager.shared.createNewConversation(with: otherUserEmail, name: self.otherUserName, firstMessage: message, completion: { [weak self] success in
                if (success) {
                    print("Message Sent Successfully")
                    self?.isNewConverstaion = false
                    inputBar.inputTextView.text = ""
                } else {
                    print("Message Sent Failed !")
                }
            })
        } else {
//            Append to existing converstaion
            guard let conversationId = conversationId else {
                return
            }
            
            DatabaseManager.shared.sendMessage(to: conversationId, name: self.otherUserName, newMessage: message, completion: { success in
                if success {
                    print("Message Sent Successfully")
                    inputBar.inputTextView.text = ""
//                    DatabaseManager.shared.updateLatestMessageCurrentChat(with: self.otherUserEmail, name: self.otherUserName, firstMessage: message, completion: { success in
//                        success
//                        ? print("Latest Message Uploaded Success")
//                        : print("Latest Message Uploaded Fail")
//                    })
                } else {
                    print("Message Sent Failed !")
                }
            })
        }
    }
}

extension ChatViewController: MessagesDataSource, MessagesLayoutDelegate, MessagesDisplayDelegate {
    
    func currentSender() -> MessageKit.SenderType {
        if let sender = selfSender {
            return sender
        }
        fatalError("Self sender is nil, Email should be cached")
    }
    
    func messageForItem(at indexPath: IndexPath, in messagesCollectionView: MessageKit.MessagesCollectionView) -> MessageKit.MessageType {
        return messages[indexPath.section]
    }
    
    func numberOfSections(in messagesCollectionView: MessageKit.MessagesCollectionView) -> Int {
        return messages.count
    }
    
}

