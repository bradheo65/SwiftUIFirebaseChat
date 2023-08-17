//
//  FileSaveRepositoryProtocol.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/17.
//

import Foundation

protocol FileSaveRepositoryProtocol {
    
    func save(url: URL, completion: @escaping (Result<URL, Error>) -> Void)
    
}
