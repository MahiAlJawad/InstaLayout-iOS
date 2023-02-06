//
//  PhotoDownloader.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 5/2/23.
//

import Foundation
import UIKit

// MARK: Structs for Data Parsing

struct APIResponse: Codable {
    let id: String
    let urls: PhotoURL
}

struct PhotoURL: Codable {
    let regular: String
}

enum PhotoLoadingError: Error {
    case invalidURL, serverError
    
    var description: String {
        switch self {
        case .invalidURL:  return "Invalid URL"
        case .serverError: return "Server Error"
        }
    }
}

class PhotoDownloader {
    private let clientID = "Register in Unsplash API and get your key"
    private let cache = NSCache<NSString, UIImage>()
    static let shared = PhotoDownloader()
    
    func getPhoto(with urlString: String, photoID: String) async -> Result<UIImage, PhotoLoadingError> {
        if let cachedImage = cache.object(forKey: photoID as NSString) {
            print("Found image from the cache")
            return .success(cachedImage)
        }
        
        guard let url = URL(string: urlString) else {
            print("Failed making url")
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            guard let image = UIImage(data: data) else {
                print("Failed downloading image from url")
                return .failure(.serverError)
            }
            cache.setObject(image, forKey: photoID as NSString)
            
            return .success(image)
        } catch {
            print("Error: \(error)")
            return .failure(.serverError)
        }
    }
    
    func fetchPhotos(for section: Section) async -> Result<[Photo], PhotoLoadingError> {
        var urlString: String {
            switch section {
            case .horizontalGrid:
                return "https://api.unsplash.com/photos?client_id=\(clientID)&page=1&per_page=30"
            case .verticalGrid:
                return "https://api.unsplash.com/photos?client_id=\(clientID)&page=2&per_page=30"
            }
        }
        
        guard let url = URL(string: urlString) else {
            print("Failed making url")
            return .failure(.invalidURL)
        }
        
        do {
            let (data, _) = try await URLSession.shared.data(from: url)
            
            let result = try JSONDecoder().decode([APIResponse].self, from: data)
            
            print("Successfully parsed data")
            
            let photos = result.reduce(into: [Photo]()) { result, apiResponse in
                let photo = Photo(ID: apiResponse.id, urlString: apiResponse.urls.regular)
                result.append(photo)
            }
            
            return .success(photos)
            
        } catch {
            print("Error: \(error)")
            return .failure(.serverError)
        }
    }
}
