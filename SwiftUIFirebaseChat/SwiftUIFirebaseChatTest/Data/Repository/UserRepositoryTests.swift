//
//  UserRepositoryTests.swift
//  UserRepositoryTests
//
//  Created by brad on 2023/08/17.
//

import XCTest

@testable import SwiftUIFirebaseChat

final class UserRepositoryTests: XCTestCase {
    
    private var mockFirebaseService: MockFirebaseService!
    private var repository: UserRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFirebaseService = MockFirebaseService()
        repository = UserRepository(firebaseService: mockFirebaseService)
    }
    
    override func tearDownWithError() throws {
        mockFirebaseService = nil
        repository = nil
        try super.tearDownWithError()
    }
    
    func testRegisterUser_Success() {
        let mockMessage = "Success to Register User"
        
        repository.registerUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testRegisterUser_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.registerUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testSaveUserInfo_Success() {
        let mockMessage = "Success to Save User Info"
        
        repository.saveUserInfo(email: "mockEmail", profileImageUrl: URL(string: "mockUrl")!) { result in
            switch result {
            case .success(let meesage):
                XCTAssertEqual(meesage, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSaveUserInfo_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.saveUserInfo(email: "mockEmail", profileImageUrl: URL(string: "mockUrl")!) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testLogIn_Success() {
        let mockMessage = "Success to Login"

        repository.loginUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testLogIn_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.loginUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testLogOut_Success() {
        let mockMessage = "Success to Logout"
        
        repository.logoutUser { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testLogOut_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.logoutUser { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testFetchAllUsers_Success() {
        let mockUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockAllUsersResult = .success(mockUser)

        repository.fetchAllUser { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user.uid, mockUser.uid)
                XCTAssertEqual(user.username, mockUser.username)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testFetchAllUsers_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockAllUsersResult = .failure(mockError)
        
        repository.fetchAllUser { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testFetchCurrentUser_Success() {
        let mockUser = ChatUser(uid: "mockUid", email: "mockEmail", profileImageURL: "mockProfileImageUrl")
        mockFirebaseService.mockCurrentUserResult = .success(mockUser)
        
        repository.fetchCurrentUser { result in
            switch result {
            case .success(let user):
                XCTAssertEqual(user?.uid, mockUser.uid)
                XCTAssertEqual(user?.username, mockUser.username)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testFetchCurrentUser_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockCurrentUserResult = .failure(mockError)
        
        repository.fetchCurrentUser { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testDeleteChatMessage_Success() {
        let mockMessage = "Success to Delete Chat Message"
        
        repository.deleteChatMessage(toId: "mockToId") { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testDeleteChatMessage_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.deleteChatMessage(toId: "mockToId") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testDeleteRecentMessage_Success() {
        let mockMessage = "Success to Delete Recent Message"
        
        repository.deleteRecentChatMessage(toId: "mockToId") { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testDeleteRecentMessage_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        repository.deleteRecentChatMessage(toId: "mockToId") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
}
