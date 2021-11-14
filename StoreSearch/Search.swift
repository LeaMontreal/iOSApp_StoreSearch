//
//  Search.swift
//  StoreSearch
//
//  Created by user206341 on 11/10/21.
//

import Foundation

class Search {
//    var searchResults = [SearchResult]()
//    var searchResults :[SearchResult] = []
//    var hasSearched = false
//    // flag app is downloading data from a web server
//    var isLoading = false
    enum State {
        case notSearchedYet // error occured is in this case
        case loading
        case noResult
        case results([SearchResult])
    }
    private (set) var state: State = .notSearchedYet
    
    var dataTask: URLSessionDataTask?

    // define a closure type
    typealias SearchComplete = (Bool) -> Void
    
    enum Category: Int {
        case all = 0
        case music = 1
        case software = 2
        case ebook = 3

        // enum can have properties and methods
        var type: String {
            switch self {
            case .all: return ""
            case .music: return "musicTrack"
            case .software: return "software"
            case .ebook: return "ebook"

            }
        }
    }
    
    func performSearch(for text: String, category: Category, completion: @escaping SearchComplete) {
        print("TAG Searching...")

        if !text.isEmpty {
            // 1. create a URL object url
            let url = itunesURL(searchText: text, category: category)
            // cancel previous search task
            dataTask?.cancel()
            // change state of search
//            hasSearched = true
//            isLoading = true
            state = .loading
            

            // 2. create a URLSessionDataTask object
            let urlSession = URLSession.shared
            dataTask = urlSession.dataTask(with: url) {data, response, error in
                var isSuccess = false
                var newState = State.notSearchedYet
                
                // fake bad network condition
//                sleep(5)
                
                if let error = error as NSError?, error.code == -999 {
                    // error.code == -999 means previous search was cancelled, when user started new search
                    return
                    // TODO: why don't deal with other error?
                
                // 3. check HTTPURLResponse object's status code, 200 means get the response success
                }else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
                    print("TAG Success! \(data!)")
                    
                    if let data = data {
                        var searchResults = self.parse(data: data)
                        if searchResults.isEmpty {
//                            print("TAG searchResults.count = \(searchResults.count)")
                            newState = .noResult
                        }else {
                            searchResults.sort(by: <)
                            newState = State.results(searchResults)
                            // the same as:
//                            newState = .results(searchResults)
                        }
                        
                        // query if current closure run on main thread
                        print("TAG dataTask Thread is Main Thread: " + (Thread.current.isMainThread ? "Yes" : "No"))
                        
//                        self.isLoading = false
                        isSuccess = true
                    }
                }else {
                    print("TAG Failure! \(response!)")
                }
                               
//                if !isSuccess {
////                    self.hasSearched = false
////                    self.isLoading = false
//                    newState = .notSearchedYet
//                }
                
                DispatchQueue.main.async {
                    // change state ONLY in main thread, to avoid race condition
                    self.state = newState
                    completion(isSuccess)
                }
            }
            
            // start data task, an asyncronous on a background thread
            dataTask?.resume()
        }
    }
    
    // create search URL object
    func itunesURL(searchText: String, category: Category) -> URL {
        let kind = category.type
        
        // encode special character, like space, < >, in the searchText
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
//        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
    }

    // get [SearchResult] from data
    func parse(data: Data) -> [SearchResult] {
        let decoder = JSONDecoder()
        do {
            let result = try decoder.decode(ResultArray.self, from: data)
            return result.results
        }catch {
            print("JSON Error :\(error)")
            return []
        }
    }

}
