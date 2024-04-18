//
//  ApiClient.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import Foundation

struct ApiClient {
    static var mediaCoveragesAPI: URL {
        let urlPath = ApiPath.apiVersion+ApiPath.mediaCoverages
        return APIEndpoint(path: urlPath, urlQueryParams: [URLQueryItem(name: "limit",
                                                                        value: ApiPath.coveragesLimit)]).url!
    }
}

private struct APIEndpoint {
    let path: String
    let urlQueryParams: [URLQueryItem]
    
    var url: URL? {
        var components = URLComponents()
        components.scheme = "https"
        components.host = "acharyaprashant.org"
        components.path = path
        components.queryItems = urlQueryParams
        return components.url
    }
}
