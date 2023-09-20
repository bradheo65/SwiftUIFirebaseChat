//
//  FriendUser.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

import RealmSwift

final class FriendUser: Object {
    @Persisted(primaryKey: true) var uid = ""
    @Persisted var email = ""
    @Persisted var profileImageURL = ""
}
