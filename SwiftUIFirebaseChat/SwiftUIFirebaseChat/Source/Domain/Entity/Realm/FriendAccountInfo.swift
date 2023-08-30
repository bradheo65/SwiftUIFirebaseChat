//
//  FriendAccountInfo.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

final class FriendAccountInfo: Object {
    
    @objc dynamic var uid: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var profileImageURL: String = ""
    @objc dynamic var username: String {
        email.components(separatedBy: "@").first ?? email
    }
    
    override static func primaryKey() -> String? {
        return "uid"
    }
    
}
