//
//  CurrentUser.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/28.
//

import Foundation

import RealmSwift

class CurrentUser: Object {
    
    @objc dynamic var uid: String = ""
    @objc dynamic var email: String = ""
    @objc dynamic var password: String = ""
    @objc dynamic var profileImageUrl: String = ""
    
    override static func primaryKey() -> String? {
        return "uid"
    }
}
