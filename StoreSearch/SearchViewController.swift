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
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        //
//        tableView.contentInset = UIEdgeInsets(top: 56, left: 0, bottom: 0, right: 0)
        // after change the search bar attached with the status area, there's 6 points more vertical space
        tableView.contentInset = UIEdgeInsets(top: 50, left: 0, bottom: 0, right: 0)
    }


}

// MARK: Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        // searchBar resign first responder, then the key board will hide itself
        searchBar.resignFirstResponder()
        
//        print("TAG searchBarSearchButtonClicked, the text is: \(searchBar.text!)")
        searchResults = []
        if searchBar.text != "Justin bieber" {
            for i in 0...2 {
                let searchResult = SearchResult()
                searchResult.name = String(format: "Fake result %d", i)
                searchResult.artistName = searchBar.text!
                searchResults.append(searchResult)
            }
        }
        
        hasSearched = true
        tableView.reloadData()
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
        let cellIdentifier = "SearchResultCell"
        var cell: UITableViewCell! = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        if cell == nil {
            // with String Array fake data, use default style UITableViewCell
//            cell = UITableViewCell(style: .default, reuseIdentifier: cellIdentifier)
            // change String Array data to SearchResult data model
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: cellIdentifier)
//            print("TAG create a new default cell")
        }
        
        if searchResults.count == 0 {
            cell.textLabel!.text = "(No Result Found)"
            cell.detailTextLabel!.text = ""
        }else {
            cell.textLabel!.text = searchResults[indexPath.row].name
            cell.detailTextLabel!.text = searchResults[indexPath.row].artistName
        }
        
//        print("TAG set cell text: \(searchResults[indexPath.row])")
        
        return cell
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
