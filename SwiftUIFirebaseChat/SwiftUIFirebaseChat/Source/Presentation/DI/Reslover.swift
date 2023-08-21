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
    
    // MARK: - Firebase Service DI

    container.register(FirebaseUserServiceProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    container.register(FirebaseFileUploadServiceProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    // MARK: - UserRepository DI
    
    container.register(UserRepositoryProtocol.self) { _ in
        return UserRepository(firebaseService: container.resolve(FirebaseUserServiceProtocol.self)!)
    }
    
    // MARK: - FileUploadRepository DI
    
    container.register(FileUploadRepositoryProtocol.self) { _ in
        return FileUploadRepository(firebaseService: container.resolve(FirebaseFileUploadServiceProtocol.self)!)
    }
    
    // MARK: - Message DI Repository

    container.register(DeleteMessageRepositoryProtocol.self) { _ in
        return DeleteMessageRepository()
    }
    
    container.register(RecentMessageListenerRepositoryProtocol.self) { _ in
        return RecentMessageListenerRepository()
    }
    
    // MARK: - Chat DI Repository

    container.register(ChatMessageListenerRepositoryProtocol.self) { _ in
        return ChatMessageListenerRepository()
    }
    
    container.register(SendMessageRepositoryProtocol.self) { _ in
        return SendMessageRepository()
    }
    
    container.register(FileSaveRepositoryProtocol.self) { _ in
        return FileSaveRepository()
    }
    
    // MARK: - Login DI UseCase
    
    container.register(RegisterUserUseCaseProtocol.self) { _ in
        return RegisterUserUseCase(
            userRepo: container.resolve(UserRepositoryProtocol.self)!,
            fileUploadRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)

    container.register(LoginUserUseCaseProtocol.self) { _ in
        return LoginUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    // MARK: - Message DI UseCase
    
    container.register(LogoutUseCaseProtocol.self) { _ in
        return LogoutUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(DeleteRecentMessageUseCaseProtocol.self) { _ in
        return DeleteRecentMessageUseCase(repo: container.resolve(DeleteMessageRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(GetAllUserUseCaseProtocol.self) { _ in
        return GetAllUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(GetCurrentUserUseCaseProtocol.self) { _ in
        return GetCurrentUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(AddRecentMessageListenerUseCaseProtocol.self) { _ in
        return AddRecentMessageListenerUseCase(repo: container.resolve(RecentMessageListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(RemoveRecentMessageListenerUseCaseProtocol.self) { _ in
        return RemoveRecentMessageListenerUseCase(repo: container.resolve(RecentMessageListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    // MARK: - Chat DI UserCase
    
    container.register(AddChatMessageListenerUseCaseProtocol.self) { _ in
        return AddChatMessageListenerUseCase(chatMessageListenerRepo: container.resolve(ChatMessageListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(RemoveChatMessageListenerUseCaseProtocol.self) { _ in
        return RemoveChatMessageListenerUseCase(chatMessageListenerRepo: container.resolve(ChatMessageListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(SendTextMessageUseCaseProtocol.self) { _ in
        return SendTextMessageUseCase(sendMessageRepo: container.resolve(SendMessageRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(SendImageMessageUseCaseProtocol.self) { _ in
        return SendImageMessageUseCase(
            sendMessageRepo: container.resolve(SendMessageRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)
    
    container.register(SendVideoMessageUseCaseProtocol.self) { _ in
        return SendVideoMessageUseCase(
            sendMessageRepo: container.resolve(SendMessageRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)
    
    container.register(SendFileMessageUseCaseProtocol.self) { _ in
        return SendFileMessageUseCase(
            sendMessageRepo: container.resolve(SendMessageRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)

    container.register(FileSaveUseCaseProtocol.self) { _ in
        return FileSaveUseCase(repo: container.resolve(FileSaveRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    return container
}
