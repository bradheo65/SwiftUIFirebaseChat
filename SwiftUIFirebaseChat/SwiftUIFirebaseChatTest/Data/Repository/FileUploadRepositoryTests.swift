//
//  FileUploadRepositoryTests.swift
//  SwiftUIFirebaseChatTest
//
//  Created by brad on 2023/08/18.
//

import XCTest

@testable import SwiftUIFirebaseChat

final class FileUploadRepositoryTests: XCTestCase {

    private var mockFirebaseService: MockFirebaseService!
    private var repository: FileUploadRepository!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        mockFirebaseService = MockFirebaseService()
        repository = FileUploadRepository(firebaseService: mockFirebaseService)
    }

    override func tearDownWithError() throws {
        mockFirebaseService = nil
        repository = nil
        try super.tearDownWithError()
    }
    
    func testUploadImage_Success() {
        let mockUrl = URL(string: "mockUrl")!
        mockFirebaseService.mockUrlResult = .success(mockUrl)
        
        repository.uploadImage(image: UIImage()) { result in
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
        
        repository.uploadImage(image: UIImage()) { result in
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
        
        repository.uploadVideo(url: URL(string: "mockUrl")!) { result in
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
        
        repository.uploadVideo(url: URL(string: "mockUrl")!) { result in
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
        
        repository.uploadFile(url: URL(string: "mockUrl")!) { result in
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
        
        repository.uploadFile(url: URL(string: "mockUrl")!) { result in
            switch result {
            case .success:
                XCTFail("Unexpected Success")
            case .failure(let error):
                XCTAssertEqual(error as NSError, mockError)
            }
        }
    }

}
