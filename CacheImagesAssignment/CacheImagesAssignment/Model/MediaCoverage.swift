//
//  MediaCoverage.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import Foundation

struct MediaCoverage: Decodable {
    let thumbnail: ThumbnailModel
}

struct ThumbnailModel: Decodable {
    let id: String
    let domain: String
    let basePath: String
    let key: String
    let qualities: [Int]
}

extension MediaCoverage {
    
    //Computed property to form the image URL path
    var imagePath: String {
        "\(thumbnail.domain)/\(thumbnail.basePath)/\(thumbnail.qualities[0])/\(thumbnail.key)"
    }
}
