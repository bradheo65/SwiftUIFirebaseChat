//
//  MessagingRespositoryTests.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/21.
//

import XCTest

@testable import SwiftUIFirebaseChat

final class MessagingRespositoryTests: XCTestCase {

    private var mockFirebaseService: MockFirebaseService!
    private var repository: MessagingRepository!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFirebaseService = MockFirebaseService()
        repository = MessagingRepository(firebaseService: mockFirebaseService)
    }

    override func tearDownWithError() throws {
        mockFirebaseService = nil
        repository = nil
        try super.tearDownWithError()
    }
    
    func testThumbnailImageForVideoURL() {
        let bundle = Bundle(for: type(of: self))
        guard let videoURL = bundle.url(forResource: "SampleVideo_1280x720_1mb", withExtension: "mp4") else {
            XCTFail("Could not find the video file in the bundle.")
            return
        }

        let thumbnailImage = repository.thumbnailImageForVideoURL(fileURL: videoURL)
        
        XCTAssertNotNil(thumbnailImage, "Thumbnail image should not be nil")
    }
        
    func testSendText_Success() {
        let mockMessage = "Success to Send Text Message"
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        
        repository.sendText(text: "mockText", chatUser: mockChatUser) { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSendText_Faulure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockError = mockError
        
        repository.sendText(text: "mockText", chatUser: mockChatUser) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testSendImage_Success() {
        let mockSuccess = "Success to Send Image Message"
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")

        repository.sendImage(url: URL(string: "mockUrl")!, image: UIImage(), chatUser: mockChatUser) { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockSuccess)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSendImage_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockError = mockError
        
        repository.sendImage(url: URL(string: "mockUrl")!, image: UIImage(), chatUser: mockChatUser) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testSendVideo_Success() {
        let mockMessage = "Success to Send Video Message"
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        
        repository.sendVideo(
            imageUrl: URL(string: "mockImageUrl")!,
            videoUrl: URL(string: "mockVideoUrl")!,
            image: UIImage(),
            chatUser: mockChatUser
        ) { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSendVideo_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockError = mockError
        
        repository.sendVideo(
            imageUrl: URL(string: "mockImageUrl")!,
            videoUrl: URL(string: "mockVideoUrl")!,
            image: UIImage(),
            chatUser: mockChatUser
        ) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Failure")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testSendFile_Success() {
        let mockMessage = "Success to Send File Message"
        let mockFileInfo = FileInfo(url: URL(string: "mockUrl")!, name: "mockName", contentType: "mockContentType", size: "mockSize")
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        
        repository.sendFile(fileInfo: mockFileInfo, chatUser: mockChatUser) { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSendFile_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        let mockFileInfo = FileInfo(url: URL(string: "mockUrl")!, name: "mockName", contentType: "mockContentType", size: "mockSize")
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockError = mockError
        
        repository.sendFile(fileInfo: mockFileInfo, chatUser: mockChatUser) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testSendRecent_Success() {
        let mockMessage = "Success to Send Recent Message"
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")

        repository.sendRecentMessage(text: "mockText", chatUser: mockChatUser) { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSendRecentMessage_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        let mockChatUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockError = mockError
        
        repository.sendRecentMessage(text: "mockText", chatUser: mockChatUser) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
}
