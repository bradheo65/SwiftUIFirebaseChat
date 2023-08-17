//
//  NetworkService.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/10.
//

import Foundation

final class NetworkService {
    
    static let shared = NetworkService()
    
    private init() { }
    
    private let sessionConfig = URLSessionConfiguration.default
    
    func downloadFile(url: URL, completion: @escaping (Result<URL, Error>) -> Void) {
        let request = URLRequest(url: url)
        
        let task = URLSession(configuration: sessionConfig).downloadTask(with: request) { url, response, error in
            if let error = error {
                completion(.failure(error))
            }
            
            if let url = url {
                completion(.success(url))
            }
        }
        task.resume()
    }
    
}
