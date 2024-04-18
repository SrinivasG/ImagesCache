//
//  MediaCoveragesAPI.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import Foundation

struct MediaCoveragesAPI {
    
    /// Fetch media coverages from the server asynchronously using swift concurrency
    func fetchMediaCoverages() async throws -> [MediaCoverage] {
        let (coveragesData, _) = try await URLSession.shared.data(from: ApiClient.mediaCoveragesAPI)
        let coverages = try JSONDecoder().decode([MediaCoverage].self, from: coveragesData)
        return coverages
    }
}
