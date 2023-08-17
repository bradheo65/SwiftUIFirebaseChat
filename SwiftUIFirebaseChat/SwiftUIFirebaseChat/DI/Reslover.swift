//
//  Reslover.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

import Swinject

// MARK: - Dependency Injection Singleton
final class Reslover {

    static let shared = Reslover()
    
    private var container = buildContatier()
    
    private init() { }
    
    func resolve<T>(_ type: T.Type) -> T {
        container.resolve(T.self)!
    }
    //this is used for tests to set mock container
    func setDependencyContainer(_ container: Container) {
        self.container = container
    }
    
}

// MARK: - Dependency Injection Container

func buildContatier() -> Container {
    let container = Container()
    
    container.register(RecentMessageListenerRepositoryProtocol.self) { _ in
        return RecentMessageListenerRepository()
    }
    
    container.register(AddRecentMessageListenerUseCaseProtocol.self) { _ in
        return AddRecentMessageListenerUseCase(repo: container.resolve(RecentMessageListenerRepositoryProtocol.self) ?? RecentMessageListenerRepository())
    }.inObjectScope(.container)
    
    container.register(RemoveRecentMessageListenerUseCaseProtocol.self) { _ in
        return RemoveRecentMessageListenerUseCase(repo: container.resolve(RecentMessageListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    return container
}
