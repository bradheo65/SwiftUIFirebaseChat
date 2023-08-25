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
        
    func downloadFile(url: URL) async throws -> URL {
        let (url, response) = try await URLSession.shared.download(from: url)
        
        if let httpResponse = response as? HTTPURLResponse {
            let httpCode = httpResponse.statusCode
            
            print("HTTP response code: \(httpCode)")
        }
        return url
    }
    
}
