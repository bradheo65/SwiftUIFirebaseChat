//
//  ChatLogViewModel.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/07/26.
//

import Foundation
import SwiftUI

final class ChatLogViewModel: ObservableObject {
    
    @Published var chatMessages: [ChatLog] = []
    
    @Published var errorMessage = ""

    @Published var count = 0
    @Published var image: UIImage?
    @Published var isSaveCompleted = false
    @Published var isErrorAlert = false

    private let chatUser: ChatUser?
    
    private let sendMessageUseCase: SendTextMessageUseCaseProtocol
    private let sendImageMessageUseCase: SendImageMessageUseCaseProtocol
    private let sendVideoMessageUseCase: SendVideoMessageUseCaseProtocol
    private let sendFileMessageUseCase: SendFileMessageUseCaseProtocol
    private let fileSave: FileSaveUseCaseProtocol
    private let startChatMessageListener: StartChatMessageListenerUseCaseProtocol
    private let stopChatMessageListenerUseCase: StopChatMessageListenerUseCaseProtocol

    init(
        chatUser: ChatUser?,
        sendTextMessage: SendTextMessageUseCaseProtocol,
        sendImageMessage: SendImageMessageUseCaseProtocol,
        sendVideoMessage: SendVideoMessageUseCaseProtocol,
        sendFileMessage: SendFileMessageUseCaseProtocol,
        fileSave: FileSaveUseCaseProtocol,
        startChatMessageListner: StartChatMessageListenerUseCaseProtocol,
        stopChatMessageListener: StopChatMessageListenerUseCaseProtocol
    ) {
        self.chatUser = chatUser
        self.sendMessageUseCase = sendTextMessage
        self.sendImageMessageUseCase = sendImageMessage
        self.sendVideoMessageUseCase = sendVideoMessage
        self.sendFileMessageUseCase = sendFileMessage
        self.fileSave = fileSave
        self.startChatMessageListener = startChatMessageListner
        self.stopChatMessageListenerUseCase = stopChatMessageListener
    }
    
    /**
    메세지 리스너를 활성화하고 새 메세지를 받아오는 함수
     
     새로운 메시지를 받으면 'chatMessages' 배열에 메세지를 추가하고 스크롤뷰를 조작
     
     - Throws: 'startChatMessageListener.excute(chatUser: chatUser)' 메서드가 실패한 경우 에러를 출력
     */
    func addListener() {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        chatMessages.removeAll()
        
        startChatMessageListener.excute(chatUser: chatUser) { result in
            switch result {
            case .success(let chatMessage):
                self.chatMessages.append(chatMessage)
                
                // ScollViewProxy receiver 업데이트
                DispatchQueue.main.async {
                    self.count += 1
                }
            case .failure(let error):
                print(error)
            }
        }
    }
    
    /**
    메세지 리스너를 비활성화하는 함수
     */
    func removeListener() {
        stopChatMessageListenerUseCase.excute()
    }
    
    /**
    텍스트 메세지를 전송하는 함수
     
     전송된 메시지의 결과 메세지를 출력
     
     - Parameters:
        - text: 전송할 텍스트
     
     - Throws: 'sendMessageUseCase.execute(text: text, chatUser: chatUser)' 메서드가 실패한 경우 에러를 출력
     */
    func handleSendText(text: String) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }

        Task {
            do {
                let sendMessageResultMessage = try await sendMessageUseCase.execute(
                    text: text,
                    chatUser: chatUser
                )
                
                print(sendMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
     
    /**
    이미지 메세지를 전송하는 함수
     
     전송된 메시지의 결과 메세지를 출력
     
     - Parameters:
        - image: 전송할 이미지
     
     - Throws: 'sendImageMessageUseCase.excute(image: image, chatUser: chatUser)' 메서드가 실패한 경우 에러를 출력
     */
    func handleSendImage(image: UIImage?) {
        guard let image = image else {
            print("Fail to image load")
            return
        }
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendImageMessageResultMessage = try await sendImageMessageUseCase.excute(
                    image: image,
                    chatUser: chatUser
                )
                
                print(sendImageMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    /**
    비디오 메세지를 전송하는 함수
     
     전송된 메시지의 결과 메세지를 출력
     
     - Parameters:
        - url: 전송할 비디오 URL
     
     - Throws: 'sendVideoMessageUseCase.excute(url: videoUrl, chatUser: chatUser)' 메서드가 실패한 경우 에러를 출력
     */
    func handleSendVideo(url: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendVideoMessageResultMessage = try await sendVideoMessageUseCase.excute(
                    url: url,
                    chatUser: chatUser
                )
                
                print(sendVideoMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    /**
    파일 메세지를 전송하는 함수
     
     전송된 메시지의 결과 메세지를 출력
     
     - Parameters:
        - url: 전송할 파일 URL
     
     - Throws: 'sendFileMessageUseCase.excute(url: url, chatUser: chatUser)' 메서드가 실패한 경우 에러를 출력
     */
    func handleSendFile(url: URL) {
        guard let chatUser = chatUser else {
            print("no Chat User")
            return
        }
        
        Task {
            do {
                let sendFileMessageResultMessage = try await sendFileMessageUseCase.excute(
                    url: url,
                    chatUser: chatUser
                )
                
                print(sendFileMessageResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
    /**
     이미지를 사진 앨범에 저장하는 함수

     이미지 저장 완료 시 `isSaveCompleted`를 토글하고, 에러 발생 시 에러 알림을 표시

     - Parameters:
       - image: 저장할 이미지
     */
    func handleImageSave(image: UIImage) {
        ImageSaveManager.shared.writeToPhotoAlbum(image: image)
        
        ImageSaveManager.shared.successHandler = {
            self.isSaveCompleted.toggle()
        }
        
        ImageSaveManager.shared.errorHandler = {
            self.isErrorAlert.toggle()
            self.errorMessage = $0.localizedDescription
        }
    }
    
    /**
     파일을 저장하는 함수

     파일 저장 완료 시 `isSaveCompleted` 상태 업데이트하고, 결과 메세지 출력

     - Parameters:
       - fileInfo: 저장할 파일의 정보

     - Throws: 'FileSaveManager.shared.save(name: fileInfo.name, at: url)' 메서드가 실패한 경우 에러를 출력
     */
    func handleFileSave(fileInfo: FileInfo?) {
        guard let fileInfo = fileInfo else {
            print("Fail to file load")
            return
        }
        
        Task {
            do {
                let url = try await fileSave.excute(url: fileInfo.url)
                
                let fileSaveResultMessage = try await FileSaveManager.shared.save(
                    name: fileInfo.name,
                    at: url
                )
                
                DispatchQueue.main.sync {
                    self.isSaveCompleted.toggle()
                }
                print(fileSaveResultMessage)
            } catch {
                print(error)
            }
        }
    }
    
}
