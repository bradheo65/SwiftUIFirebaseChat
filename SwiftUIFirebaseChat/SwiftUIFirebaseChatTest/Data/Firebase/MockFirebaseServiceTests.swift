//
//  MockFirebaseServiceTests.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/18.
//

import XCTest

@testable import SwiftUIFirebaseChat

final class MockFirebaseServiceTests: XCTestCase {

    private var mockFirebaseService: MockFirebaseService!

    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFirebaseService = MockFirebaseService()
    }

    override func tearDownWithError() throws {
        mockFirebaseService = nil
        try super.tearDownWithError()
    }

    func testRegisterUser_Success() {
        let mockMessage = "Success to Register User"
        
        mockFirebaseService.registerUser(email: "mockEmail", password: "password") { result in
            switch result {
            case .success(let meesage):
                XCTAssertEqual(meesage, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testRegisterUser_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        mockFirebaseService.registerUser(email: "mockEmail", password: "password") { result in
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
                
        mockFirebaseService.saveUserInfo(email: "mockEmail", profileImageUrl: URL(string: "mockProfileImageUrl")!, store: "mockStore") { result in
            switch result {
            case .success(let message):
                XCTAssertEqual(message, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testSaveUserInfo_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        mockFirebaseService.saveUserInfo(email: "mockEmail", profileImageUrl: URL(string: "mockProfileImageUrl")!, store: "mockStore") { result in
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
        
        mockFirebaseService.loginUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success(let meesage):
                XCTAssertEqual(meesage, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testLogIn_Failure() {
        let mockError = NSError(domain: "mockErrorDomin", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        mockFirebaseService.loginUser(email: "mockEmail", password: "mockPassword") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Failure")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testLogOut_Success() {
        let mockMessage = "Success to Logout"
        
        mockFirebaseService.logoutUser { result in
            switch result {
            case .success(let meesage):
                XCTAssertEqual(meesage, mockMessage)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testLogOut_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockError = mockError
        
        mockFirebaseService.logoutUser { result in
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
        
        mockFirebaseService.fetchAllUser { result in
            switch result {
            case .success(let chatUser):
                XCTAssertEqual(chatUser.uid, mockUser.uid)
                XCTAssertEqual(chatUser.email, mockUser.email)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testFetchAllUsers_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockAllUsersResult = .failure(mockError)
        
        mockFirebaseService.fetchAllUser { result in
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
        mockFirebaseService.mockAllUsersResult = .success(mockUser)
        
        mockFirebaseService.fetchCurrentUser { result in
            switch result {
            case .success(let chatUser):
                XCTAssertEqual(chatUser?.uid, mockUser.uid)
                XCTAssertEqual(chatUser?.email, mockUser.email)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testFetchCurrentUser_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockCurrentUserResult = .failure(mockError)
        
        mockFirebaseService.fetchCurrentUser { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    func testUploadImage_Success() {
        let mockUrl = URL(string: "mockUrl")!
        mockFirebaseService.mockUrlResult = .success(mockUrl)

        mockFirebaseService.uploadImage(image: UIImage(), store: "mockStore") { result in
            switch result {
            case .success(let url):
                XCTAssertEqual(url, mockUrl)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testUploadImage_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockUrlResult = .failure(mockError)
        
        mockFirebaseService.uploadImage(image: UIImage(), store: "mockStore") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testUploadVideo_Success() {
        let mockUrl = URL(string: "mockUrl")!
        mockFirebaseService.mockUrlResult = .success(mockUrl)
        
        mockFirebaseService.uploadVideo(url: URL(string: "mockUrl")!, store: "mockStore") { result in
            switch result {
            case .success(let url):
                XCTAssertEqual(url, mockUrl)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testUploadVideo_Failure() {
        let mockError = NSError(domain: "mockErrorDomain", code: 123, userInfo: nil)
        mockFirebaseService.mockUrlResult = .failure(mockError)
        
        mockFirebaseService.uploadVideo(url: URL(string: "mockUrl")!, store: "mockStore") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
    func testUploadFile_Success() {
        let mockFileInfo = FileInfo(url: URL(string: "mockUrl")!, name: "mockName", contentType: "mockContentType", size: "mockSize")
        mockFirebaseService.mockFireInfoResult = .success(mockFileInfo)
        
        mockFirebaseService.uploadFile(url: URL(string: "mockUrl")!, store: "mockStore") { result in
            switch result {
            case .success(let fileInfo):
                XCTAssertEqual(fileInfo.name, mockFileInfo.name)
                XCTAssertEqual(fileInfo.contentType, mockFileInfo.contentType)
            case .failure:
                XCTFail("Unexpected Failure")
            }
        }
    }
    
    func testUploadFile_Failure() {
        let mockError = NSError(domain: "mockDomainError", code: 123, userInfo: nil)
        mockFirebaseService.mockFireInfoResult = .failure(mockError)
        
        mockFirebaseService.uploadFile(url: URL(string: "mockUrl")!, store: "mockStore") { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }
    
}
