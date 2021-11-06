//
//  SearchViewController.swift
//  StoreSearch
//
//  Created by user206341 on 11/3/21.
//

import UIKit

class SearchViewController: UIViewController {

    @IBOutlet var searchBar: UISearchBar!
    @IBOutlet var tableView: UITableView!
        
    // fake results
    var searchResults = [SearchResult]()
    var hasSearched = false
    
    // define constant for reusable cell identifier
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //
//        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        // after change the search bar attached with the status area, there's 6 points more vertical space
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
        
        // register nib file for cell, then when we call tableView.dequeueReusableCell(), will get a UITableViewCell from nib file
        // for nibName, we don't need filename with .xib, only filename is enough
        var nibCell = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // register NothingFoundCell
        nibCell = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        searchBar.becomeFirstResponder()
    }

    // MARK: - Helper Methods
    func itunesURL(searchText: String) -> URL {
        // encode special character, like space, < >, in the searchText
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
        let urlString = String(format: "https://itunes.apple.com/search?term=%@", encodedText)
        let url = URL(string: urlString)
        return url!
    }
    
    // Get Data object from the data received from the server
    func performStoreRequest(with url: URL) -> Data? {
        do {
//            return try String(contentsOf: url, encoding: String.Encoding.utf8)
            return try Data(contentsOf: url)
        }catch {
            print("Download Error: \(error.localizedDescription)")
            showNetworkError()
            return nil
        }
    }

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
    
    // test ? operator
//    func test() -> String {
//        let a = 2
//        let b = 3
//        var text: String? = ""
//
//        if a > b {
//            text = nil
//        }else {
//            text = "Normal"
//        }
//
//        return text==nil ? "":text!
//    }

    func showNetworkError() {
        let controller = UIAlertController(title: "Whoops...", message: "There was an error accessing itunes store" +
                          "Please try later", preferredStyle: .alert)
        let action = UIAlertAction(title: "OK", style: .default, handler: nil)
        controller.addAction(action)
        
        present(controller, animated: true, completion: nil)
    }
}

// MARK: Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {

        // do not need the fake data
//        if searchBar.text != "Justin bieber" {
//            for i in 0...2 {
//                let searchResult = SearchResult()
//                searchResult.name = String(format: "Fake result %d", i)
//                searchResult.artistName = searchBar.text!
//                searchResults.append(searchResult)
//            }
//        }

        if !searchBar.text!.isEmpty {
            // searchBar resign first responder, then the key board will hide itself
            searchBar.resignFirstResponder()

            searchResults = []

            let url = itunesURL(searchText: searchBar.text!)
            print("TAG URL is: '\(url)'")
            hasSearched = true

//            print("TAG test result is: '\(test())'")
            
            if let data = performStoreRequest(with: url) {
                // use print() to make function ok, then output to TableView
//                let results = parse(data: data)
//                print("TAG Got Results :\(results)")
                searchResults = parse(data: data)
                
                // sort the results
                // option 1:
//                searchResults.sort {result1, result2 in
//                    return result1.name.localizedStandardCompare(result2.name) == .orderedAscending
//                }
                // option 2:
//                searchResults.sort {$0.name.localizedStandardCompare($1.name) == .orderedAscending}
                // option 3:
//                searchResults.sort {$0 < $1}
                // option 4:
                searchResults.sort(by: <)
                
                tableView.reloadData()
            }
        }
    }
    
    // make the search bar attach with the status area
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}


extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // note: here's no override keyword for func
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !hasSearched {
            return 0
        } else if searchResults.count == 0 {
            return 1
        }else {
            return searchResults.count
        }

    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        // replace by constant in struct
//        let cellIdentifier = "SearchResultCell"
        
        // change to real data with cell from nib file, this part only for fake data
//        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
//        if cell == nil {
//            // with String Array fake data, use default style UITableViewCell
////            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
//            // change String Array data to SearchResult data model
//            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
////            print("TAG create a new default cell")
//        }
                
        if searchResults.count == 0 {
            return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
        }else {
            // change to real data with cell from nib file
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell

            let searchResult = searchResults[indexPath.row]
            cell.nameLabel.text = searchResult.name
            //cell.artistNameLabel.text = searchResults[indexPath.row].artistName
            if searchResult.artist.isEmpty {
                cell.artistNameLabel.text = "Unknown"
            }else {
                cell.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
            }
            
            return cell
        }
    }
    
    // do not turn gray when user select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // do not let user select (No Result Found) cell
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 {
            return nil
        }else {
            return indexPath
        }
    }
}
