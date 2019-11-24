//
//  Message.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 24/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import Firebase

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
    let fromId, toId: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.fromId = dictionary["fromId"] as? String ?? ""
        self.toId = dictionary["toId"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
        self.isFromCurrentLoggedUser = Auth.auth().currentUser?.uid == self.fromId
    }
}
