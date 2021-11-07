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
        
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    
    @IBAction func segmentChanged(_ sender: UISegmentedControl) {
//        print("TAG Segment changed: \(sender.selectedSegmentIndex)")
        performSearch()
    }
    
    // fake results
    var searchResults = [SearchResult]()
    var hasSearched = false
    var isLoading = false
    
    var dataTask: URLSessionDataTask?
    
    // define constant for reusable cell identifier
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //
//        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        // after change the search bar attached with the status area, there's 6 points more vertical space
        tableView.contentInset = UIEdgeInsets(top: 94, left: 0, bottom: 0, right: 0)
        
        // register nib file for cell, then when we call tableView.dequeueReusableCell(), will get a UITableViewCell from nib file
        // for nibName, we don't need filename with .xib, only filename is enough
        var nibCell = UINib(nibName: TableView.CellIdentifiers.searchResultCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.searchResultCell)
        
        // register NothingFoundCell
        nibCell = UINib(nibName: TableView.CellIdentifiers.nothingFoundCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.nothingFoundCell)
        
        // register LoadingCell
        nibCell = UINib(nibName: TableView.CellIdentifiers.loadingCell, bundle: nil)
        tableView.register(nibCell, forCellReuseIdentifier: TableView.CellIdentifiers.loadingCell)
        
        searchBar.becomeFirstResponder()
    }

    // MARK: - Helper Methods
    func itunesURL(searchText: String, category: Int) -> URL {
        let kind: String
        switch category {
        case 1: kind = "musicTrack"
        case 2: kind = "software"
        case 3: kind = "ebook"
        default: kind = ""
        }
        
        // encode special character, like space, < >, in the searchText
        let encodedText = searchText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)!
//        let urlString = String(format: "https://itunes.apple.com/search?term=%@&limit=200", encodedText)
        let urlString = "https://itunes.apple.com/search?" + "term=\(encodedText)&limit=200&entity=\(kind)"
        let url = URL(string: urlString)
        return url!
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
        performSearch()
    }
    
    func performSearch() {

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

            let url = itunesURL(searchText: searchBar.text!, category: self.segmentedControl.selectedSegmentIndex)
            print("TAG URL is: '\(url)'")
            // cancel previous search task
            dataTask?.cancel()
            hasSearched = true
            isLoading = true
            tableView.reloadData()

            let urlSession = URLSession.shared
            dataTask = urlSession.dataTask(with: url) {data, response, error in
                if let error = error as NSError?, error.code == -999 {
                    return  // search was cancelled
                    // TODO: why don't deal with other error?
                    //print("TAG Failure! \(error.localizedDescription)")
                
                }else if let httpResponse = response as? HTTPURLResponse, httpResponse.statusCode == 200 {
//                    print("TAG Success! \(data!)")
                    if let data = data {
                        self.searchResults = self.parse(data: data)
                        self.searchResults.sort(by: <)
                        
                        // query if current closure run on main thread
                        print("TAG dataTask Thread is Main Thread: " + (Thread.current.isMainThread ? "Yes" : "No"))
                        
                        DispatchQueue.main.async {
                            print("TAG Current Thread is Main Thread: " + (Thread.current.isMainThread ? "Yes" : "No"))
                            self.isLoading = false
                            self.tableView.reloadData()
                        }
                        
                        return
                    }
                }else {
                    print("TAG Failure! \(response!)")
                }
                
                DispatchQueue.main.async {
                    self.hasSearched = false
                    self.isLoading = false
                    self.tableView.reloadData()
                    self.showNetworkError()
                }

            }
            
            // start data task, an asyncronous on a background thread
            dataTask?.resume()
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
        } else if searchResults.count == 0 || isLoading == true {
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
                
        if isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            print("TAG start spinner")
            return cell

        }else {
            if searchResults.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            }else {
                // change to real data with cell from nib file
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell

                let searchResult = searchResults[indexPath.row]
                cell.configure(for: searchResult)
                
                return cell
            }
        }
        
    }
    
    // do not turn gray when user select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // do not let user select (No Result Found) cell
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if searchResults.count == 0 || isLoading == true {
            return nil
        }else {
            return indexPath
        }
    }
}
