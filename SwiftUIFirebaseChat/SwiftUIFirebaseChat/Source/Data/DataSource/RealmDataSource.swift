//
//  RealmDataSource.swift
//  SwiftUIFirebaseChat
//
//  Created by PJH on 2023/08/31.
//

import Foundation

import RealmSwift

final class RealmDataSource: RealmDataSourceProtocol {
    
    static let shared = RealmDataSource()
    private var chatLogsToken: NotificationToken?

    private init() {
        getLocationRealm()
    }
    
    func getLocationRealm() {
        let realm = try! Realm()

        print("Realm is located: ", realm.configuration.fileURL!)
    }
    
    func read<T: Object>(_ object: T.Type) -> Results<T> {
        let realm = try! Realm()
        
        return realm.objects(object)
    }
    
    func add<T: Object>(_ object: T) {
        let realm = try! Realm()

        try! realm.write {
            realm.add(object, update: .modified)
        }
    }
    
    func create<T: Object>(_ object: T.Type, value: Any) {
        let realm = try! Realm()

        try! realm.write {
            realm.create(object, value: value, update: .modified)
        }
    }
    
    func update(block: @escaping () -> Void) {
        let realm = try! Realm()

         try! realm.write {
            block()
        }
    }
    
    func delete<T: Object>(_ object: T) {
        let realm = try! Realm()

        try! realm.write {
            realm.delete(object)
        }
    }
    
    func deleteAll() {
        let realm = try! Realm()

        try! realm.write {
            realm.deleteAll()
        }
    }
    
}
