//
//  Conversation.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 10/10/23.
//

import Foundation

struct Conversation {
    let id: String
    let name: String
    let otherUserEmail: String
    let latestMEssage: LatestMessage
}

struct LatestMessage {
    let date: String
    let text: String
    let isRead: Bool
}
