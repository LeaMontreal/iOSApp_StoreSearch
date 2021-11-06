//
//  SearchResult.swift
//  StoreSearch
//
//  Created by user206341 on 11/3/21.
//

import Foundation

class ResultArray: Codable {
    var resultCount = 0
    var results = [SearchResult]()
}

class SearchResult: Codable, CustomStringConvertible {
    // CustomStringConvertible protocol
    var description: String {
//        return "\n Result - Kind: \(kind ?? "None") Name: \(name), Artist Name: \(artistName ?? "None"),Genre:\(genre),Store URL: \(storeURL ?? "None")"
        return "\n Result - Kind: \(kind ?? "None") Name: \(name), Artist Name: \(artistName ?? "None")"
    }
    
    // keep property's name same as the string in JSON data
    var kind: String? = ""
    var artistName: String? = ""
    
    var trackName: String? = ""
    var collectionName: String? = ""
    
    var trackViewURL: String? = ""
    var collectionURL: String? = ""
    
    var trackPrice: Double? = 0.00
    var collectionPrice: Double?
    var itemPrice: Double?
    
    var currency: String = ""

    // replaced by enum
//    var artworkUrl60: String = ""
//    var artworkUrl100: String = ""
//    var trackViewUrl: String? = ""
//    var primaryGenreName: String = ""
    var imageSmall: String = ""
    var imageLarge: String = ""
//    var storeURL: String? = ""
//    var genre: String = ""
    var itemGenre: String?
    var bookGenre: [String]?
    
    enum CodingKeys: String, CodingKey {
        case imageSmall = "artworkUrl60"
        case imageLarge = "artworkUrl100"
//        case storeURL = "trackViewUrl"
        case itemGenre = "primaryGenreName"
        case bookGenre = "genres"
        case itemPrice = "price"
        case kind, artistName, trackName, collectionName
        case trackViewURL, collectionURL
        case trackPrice, collectionPrice, currency
    }
    
    var name: String {
        return trackName ?? collectionName ?? ""
//        if let trackName = trackName {
//            return trackName
//        }else {
//            return ""
//        }
    }
    var storeURL: String {
        return trackViewURL ?? collectionURL ?? ""
    }
    
    var price: Double {
        return trackPrice ?? collectionPrice ?? itemPrice ?? 0.0
    }
    
    var genre: String {
        if let genre = itemGenre {
            return genre
        }
        if let genres = bookGenre {
            return genres.joined(separator: ",")
        }
        
        return ""
    }
    
    var type: String {
        let kind = self.kind ?? "audiobook"
        switch kind {
        case "album": return "Album"
        case "audiobook": return "Audio Book"
        case "book": return "Book"
        case "ebook": return "E-Book"
        case "feature-movie": return "Movie"
        case "music-video": return "Music Video"
        case "podcast": return "Podcast"
        case "software": return "App"
        case "song": return "Song"
        case "tv-episode": return "TV-Episode"
        default: break
        }
        return "Unknown"
    }
    
    var artist: String {
        return artistName ?? ""
    }
    
    // overload < operator for sorting search results
    static func < (lhs: SearchResult, rhs: SearchResult) -> Bool {
        return lhs.name.localizedStandardCompare(rhs.name) == .orderedAscending
    }
}
