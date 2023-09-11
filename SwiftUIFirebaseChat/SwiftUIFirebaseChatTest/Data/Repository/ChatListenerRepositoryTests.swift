//
//  ChatListenerRepositoryTests.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/21.
//

import XCTest

@testable import SwiftUIFirebaseChat

final class ChatListenerRepositoryTests: XCTestCase {

    var firebaseSerivce: MockFirebaseService!
    var repo: ChatListenerRepositoryProtocol!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        firebaseSerivce = MockFirebaseService()
        repo = ChatListenerRepository(firebaseSerivce: firebaseSerivce)
    }

    override func tearDownWithError() throws {
        firebaseSerivce = nil
        repo = nil
        try super.tearDownWithError()
    }
    
    func testStartChatMessageListener_Success() {
        let mockChatMessage = ChatMessageResponse(
            fromId: "mockFromId",
            toId: "mockToId",
            text: "mockText",
            imageUrl: "mockImageUrl",
            videoUrl: "mockVideoUrl",
            fileUrl: "mockFileUrl",
            imageWidth: .zero,
            imageHeight: .zero,
            timestamp: Date(),
            fileName: "mockName",
            fileType: "mockType",
            fileSize: "mockSize"
        )
        firebaseSerivce.mockChatMessageResult = .success(mockChatMessage)
        
        let mockChatUer = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileUrl")
        repo.startChatMessageListener(chatUser: mockChatUer) { result in
            switch result {
            case .success(let chatMessage):
                XCTAssertEqual(chatMessage.text, mockChatMessage.text)
                XCTAssertEqual(chatMessage.imageUrl, mockChatMessage.imageUrl)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testStartChatMessageListener_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        firebaseSerivce.mockChatMessageResult = .failure(mockError)
        
        let mockChatUer = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileUrl")
        repo.startChatMessageListener(chatUser: mockChatUer) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }

}
