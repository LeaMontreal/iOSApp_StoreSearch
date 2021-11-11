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

    private let search = Search()
    // move to class Search
//    var searchResults :[SearchResult] = []
//    var hasSearched = false
    // flag app is downloading data from a web server
//    var isLoading = false
    
//    var dataTask: URLSessionDataTask?

    // define constant for reusable cell identifier
    struct TableView {
        struct CellIdentifiers {
            static let searchResultCell = "SearchResultCell"
            static let nothingFoundCell = "NothingFoundCell"
            static let loadingCell = "LoadingCell"
        }
    }
    
    var landscapeVC: LandscapeViewController?
    
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

    // invoked when trait collection for this view controller change
    override func willTransition(to newCollection: UITraitCollection, with coordinator: UIViewControllerTransitionCoordinator) {
        super.willTransition(to: newCollection, with: coordinator)
        
        switch newCollection.verticalSizeClass {
        case .compact:
            showLandscape(with: coordinator)
        case .regular,.unspecified:
            hideLandscape(with: coordinator)
        @unknown default:
            break
        }
    }
    
    // MARK: - Navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowDetail" {
            //segue.destination.modalPresentationStyle = .overFullScreen
            // pageSheet is the default style, in this style, the pop-up view can be dismissed by swiping from the top
            segue.destination.modalPresentationStyle = .pageSheet
            
            let indexPath = sender as! IndexPath
            let controller = segue.destination as! DetailViewController
            controller.searchResult = search.searchResults[indexPath.row]
        }
    }
    
    // MARK: - Helper Methods
    
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

    func showLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        guard landscapeVC == nil else {return}
        
        landscapeVC = storyboard!.instantiateViewController(withIdentifier: "LandscapeViewController") as? LandscapeViewController
        if let controller = landscapeVC {
            // pass search results data to landscape view
            controller.search = search
            
            controller.view.frame = view.bounds
            controller.view.alpha = 0
            
            // add one view controller to another view controller, is called View Controller Containment
            // 1. add the landscape view as a subView
            view.addSubview(controller.view)
            // 2. tell SearchViewController that landscape controller is managing that part of the screen
            addChild(controller)
            // 3. tell landscape controller that it has a parent which is SearchViewController
            // 3.(-1) add  crossfade transition animation
            coordinator.animate(alongsideTransition: {
                _ in
                controller.view.alpha = 1
                // hide keyboard
                self.searchBar.resignFirstResponder()
                // if the detail pop-up view openned, dismiss it
                if self.presentedViewController != nil {
                    self.dismiss(animated: true, completion: nil)
                }
            },
                                completion: {   // completion closure is invoked after animate() finished
                _ in
                // 3. tell landscape controller that it has a parent which is SearchViewController
                controller.didMove(toParent: self)
            })
        }
    }

    func hideLandscape(with coordinator: UIViewControllerTransitionCoordinator) {
        if let controller = landscapeVC {
            controller.willMove(toParent: nil)
            
            // add crossfade transition animation
            coordinator.animate(alongsideTransition: {
                _ in
                controller.view.alpha = 0
            },
                                completion: {
                _ in
                controller.removeFromParent()
                controller.view.removeFromSuperview()
                self.landscapeVC = nil
            })
        }
    }

}

// MARK: Search Bar Delegate
extension SearchViewController: UISearchBarDelegate {
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        performSearch()
    }
    
    func performSearch() {
        search.performSearch(for: searchBar.text!, category: segmentedControl.selectedSegmentIndex) {
            isSuccess in
            if !isSuccess {
                self.showNetworkError()
            }
            
            self.tableView.reloadData()
        }
        
        tableView.reloadData()
        searchBar.resignFirstResponder()
    }
    
    // make the search bar attach with the status area
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}

extension SearchViewController: UITableViewDelegate, UITableViewDataSource {
    // note: here's no override keyword for func
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if !search.hasSearched {
            return 0
        } else if search.searchResults.count == 0 || search.isLoading == true {
            return 1
        }else {
            return search.searchResults.count
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
                
        if search.isLoading {
            let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.loadingCell, for: indexPath)
            let spinner = cell.viewWithTag(100) as! UIActivityIndicatorView
            spinner.startAnimating()
            print("TAG start spinner")
            return cell

        }else {
            if search.searchResults.count == 0 {
                return tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.nothingFoundCell, for: indexPath)
            }else {
                // change to real data with cell from nib file
                let cell = tableView.dequeueReusableCell(withIdentifier: TableView.CellIdentifiers.searchResultCell, for: indexPath) as! SearchResultCell

                let searchResult = search.searchResults[indexPath.row]
                cell.configure(for: searchResult)
                
                return cell
            }
        }
        
    }
    
    // do not turn gray when user select cell
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        // show detail pop-up view
        performSegue(withIdentifier: "ShowDetail", sender: indexPath)
    }
    
    // do not let user select (No Result Found) cell
    func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        if search.searchResults.count == 0 || search.isLoading == true {
            return nil
        }else {
            return indexPath
        }
    }
}
