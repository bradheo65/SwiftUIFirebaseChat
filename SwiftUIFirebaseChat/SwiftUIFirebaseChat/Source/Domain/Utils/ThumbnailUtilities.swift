//
//  ThumbnailUtilities.swift
//  SwiftUIFirebaseChat
//
//  Created by brad on 2023/08/25.
//

import Foundation

import AVFoundation
import UIKit

final class ThumbnailUtilities {
    
    static func generateThumbnailForVideo(fileURL: URL) throws -> UIImage {
        let asset = AVAsset(url: fileURL)
        let imageGenerator = AVAssetImageGenerator(asset: asset)
        
        do {
            let thumbnailCGImage = try imageGenerator.copyCGImage(at: CMTimeMake(value: 1, timescale: 60), actualTime: nil)
            return UIImage(cgImage: thumbnailCGImage)
        } catch {
            throw error
        }
    }
    
}
