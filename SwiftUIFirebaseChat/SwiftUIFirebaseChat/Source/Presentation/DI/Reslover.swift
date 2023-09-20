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

    func setDependencyContainer(_ container: Container) {
        self.container = container
    }
    
}

// MARK: - Dependency Injection Container

func buildContatier() -> Container {
    let container = Container()
    
    container.register(RealmDataSourceProtocol.self) { _ in
        return RealmDataSource.shared
    }.inObjectScope(.container)
    
    // MARK: - Service - Firebase

    container.register(FirebaseUserServiceProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    container.register(FirebaseFileUploadServiceProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    container.register(FirebaseMessagingServiceProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    container.register(FirebaseChatListenerProtocol.self) { _ in
        return FirebaseService.shared
    }.inObjectScope(.container)
    
    // MARK: - Repository - User
    
    container.register(UserRepositoryProtocol.self) { _ in
        return UserRepository(
            firebaseService: container.resolve(FirebaseUserServiceProtocol.self)!,
            dataSource: container.resolve(RealmDataSourceProtocol.self)!
        )
    }
    
    // MARK: - Repository - FileUpload
    
    container.register(FileUploadRepositoryProtocol.self) { _ in
        return FileUploadRepository(firebaseService: container.resolve(FirebaseFileUploadServiceProtocol.self)!)
    }
    
    // MARK: - Repository - Messaging

    container.register(MessagingRepositoryProtocol.self) { _ in
        return MessagingRepository(
            firebaseService: container.resolve(FirebaseMessagingServiceProtocol.self)!,
            dataSource: container.resolve(RealmDataSourceProtocol.self)!)
    }
    
    // MARK: - Repository - ChatListener

    container.register(ChatListenerRepositoryProtocol.self) { _ in
        return ChatListenerRepository(
            firebaseSerivce: container.resolve(FirebaseChatListenerProtocol.self)!,
            dataSource: container.resolve(RealmDataSourceProtocol.self)!)
    }
    
    // MARK: - Repository - FileSave

    container.register(FileSaveRepositoryProtocol.self) { _ in
        return FileSaveRepository()
    }
    
    // MARK: - UseCase - User
    
    container.register(RegisterUserUseCaseProtocol.self) { _ in
        return RegisterUserUseCase(
            userRepo: container.resolve(UserRepositoryProtocol.self)!,
            fileUploadRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)

    container.register(LoginUserUseCaseProtocol.self) { _ in
        return LoginUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
        
    container.register(LogoutUseCaseProtocol.self) { _ in
        return LogoutUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(DeleteRecentMessageUseCaseProtocol.self) { _ in
        return DeleteRecentMessageUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(FetchAllUserUseCaseProtocol.self) { _ in
        return FetchAllUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(FetchCurrentUserUseCaseProtocol.self) { _ in
        return FetchCurrentUserUseCase(userRepo: container.resolve(UserRepositoryProtocol.self)!)
    }.inObjectScope(.container)
  
    // MARK: - UserCase - Message

    container.register(FetchChatMessageUseCaseProtocol.self) { _ in
        return FetchChatMessageUseCase(messageRepo: container.resolve(MessagingRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(FetchNextChatMessageUseCaseProtocol.self) { _ in
        return FetchNextChatMessageUseCase(messageRepo: container.resolve(MessagingRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(SendTextMessageUseCaseProtocol.self) { _ in
        return SendTextMessageUseCase(sendMessageRepo: container.resolve(MessagingRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(SendImageMessageUseCaseProtocol.self) { _ in
        return SendImageMessageUseCase(
            sendMessageRepo: container.resolve(MessagingRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)
    
    container.register(SendVideoMessageUseCaseProtocol.self) { _ in
        return SendVideoMessageUseCase(
            sendMessageRepo: container.resolve(MessagingRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)
    
    container.register(SendFileMessageUseCaseProtocol.self) { _ in
        return SendFileMessageUseCase(
            sendMessageRepo: container.resolve(MessagingRepositoryProtocol.self)!,
            uploadFileRepo: container.resolve(FileUploadRepositoryProtocol.self)!
        )
    }.inObjectScope(.container)

    container.register(FileSaveUseCaseProtocol.self) { _ in
        return FileSaveUseCase(repo: container.resolve(FileSaveRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    // MARK: - UserCase - MessageListener
    
    container.register(FetchUserChatMessageUseCaseProtocol.self) { _ in
        return FetchUserChatMessageUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(FetchAllChatMessageUseCaseProtocol.self) { _ in
        return FetchAllChatMessageUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(StartChatMessageListenerUseCaseProtocol.self) { _ in
        return StartChatMessageListenerUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(StopChatMessageListenerUseCaseProtocol.self) { _ in
        return StopChatMessageListenerUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(StartRecentMessageListenerUseCaseProtocol.self) { _ in
        return StartRecentMessageListenerUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(StopRecentMessageListenerUseCaseProtocol.self) { _ in
        return StopRecentMessageListenerUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    container.register(StartConversationListenerUseCaseProtocol.self) { _ in
        return StartConversationListenerUseCase(chatListenerRepo: container.resolve(ChatListenerRepositoryProtocol.self)!)
    }.inObjectScope(.container)
    
    return container
}
