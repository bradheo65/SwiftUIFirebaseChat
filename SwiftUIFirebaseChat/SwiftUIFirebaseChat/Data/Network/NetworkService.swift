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
    
    func downloadFile(url: URL) async throws -> Result<URL, Error> {
        do {
            let (data, _) = try await URLSession.shared.download(from: url)
            
            return .success(data)
        }
        catch let error {
            return .failure(error)
        }
    }
    
}
