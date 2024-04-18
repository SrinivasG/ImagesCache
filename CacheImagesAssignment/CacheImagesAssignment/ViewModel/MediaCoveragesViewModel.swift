//
//  MediaCoveragesViewModel.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import Foundation
import UIKit

class MediaCoveragesViewModel {
    private let apiClient: MediaCoveragesAPI
    private var coverages: [MediaCoverage] = []
    
    init(apiClient: MediaCoveragesAPI) {
        self.apiClient = apiClient
    }
    
    /// Fetch all media coverages from the server
    func fetchMediaCoverages() async throws {
        coverages = try await apiClient.fetchMediaCoverages()
    }
    
    /// Download all images with Group Task
    func fetchAllThumbnails() async {
        await withTaskGroup(of: UIImage?.self) { group in
            for coverage in coverages {
                group.addTask {
                    try? await self.fetchImage(coverage: coverage)
                }
            }
        }
    }
    
    /// Fetch an image from memory cache or disk cache. If not found download from the server and save in disk and memory cache.
    private func fetchImage(coverage: MediaCoverage) async throws -> UIImage {
        let thumbnailId: String = coverage.thumbnail.id
        
        //From memory cache
        if let imageFromCache = await MemoryCache().retrieve(with: thumbnailId) {
            return imageFromCache
        }
        
        //From Disk cache
        if let imageFromDiskCache = await DiskCache().retrieve(with: thumbnailId) {
            await MemoryCache().save(image: imageFromDiskCache, with: thumbnailId)
            return imageFromDiskCache
        }
        
        //Download an image from server
        guard let url = URL(string: coverage.imagePath) else {
            throw URLError(.badURL)
        }
        
        do {
            let (imageData, _) = try await URLSession.shared.data(from: url)
            if let image = UIImage(data: imageData) {
                let croppedImage = image.centreCropImage()
                await MemoryCache().save(image: croppedImage, with: thumbnailId)
                await DiskCache().save(image: croppedImage, with: thumbnailId)
                return croppedImage
            } else {
                throw URLError(.badURL)
            }
        } catch {
            throw error
        }
    }

    /// Computed property to return the count of coverages
    var numberOfItems: Int {
        coverages.count
    }
    
    /// load an image
    func loadImage(for indexPath: IndexPath) async throws -> UIImage {
        return try await fetchImage(coverage: coverages[indexPath.item])
    }
}

//MARK: -
extension UIImage {
    /// Crop an image 
    func centreCropImage() -> UIImage {
        let center = CGPoint(x: self.size.width/2, y: self.size.height/2)
        let origin = CGPoint(x: center.x - DesiredImage.width/2, y: center.y - DesiredImage.height/2)
        let cgCroppedImage = self.cgImage!.cropping(to: CGRect(origin: origin, size: CGSize(width: DesiredImage.width, height: DesiredImage.height)))!
        let croppedImage = UIImage(cgImage: cgCroppedImage, scale: self.scale, orientation: self.imageOrientation)
        return croppedImage
    }
}

