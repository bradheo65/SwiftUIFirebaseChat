//
//  RealmDataSourceProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/31.
//

import Foundation

import RealmSwift

protocol RealmDataSourceProtocol {
        
    func read<T: Object>(_ object: T.Type) -> Results<T>
    func add<T: Object>(_ object: T)
    func create<T: Object>(_ object: T.Type, value: Any)
    func update(block: @escaping () -> Void)
    func delete<T: Object>(_ object: T)
    func deleteAll()
    
}
