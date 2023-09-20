//
//  LoginUser.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/09/20.
//

import Foundation

import RealmSwift

final class LoginUser: Object {
    @Persisted(primaryKey: true) var uid = ""
    @Persisted var email = ""
    @Persisted var password = ""
    @Persisted var profileImageURL = ""
}
