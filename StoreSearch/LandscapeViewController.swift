//
//  LandscapeViewController.swift
//  StoreSearch
//
//  Created by user206341 on 11/9/21.
//

import UIKit

class LandscapeViewController: UIViewController {

    @IBOutlet weak var scrollView: UIScrollView!    
    @IBOutlet weak var pageControl: UIPageControl!

    // replaced by search
//    var searchResults = [SearchResult]()
    var search: Search!
    private var isFirstTime = true
    private var downloadTasks = [URLSessionDownloadTask]()
    
    deinit {
        print("TAG LandscapeViewController deinit \(self)")
        for task in downloadTasks {
            task.cancel()
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // disable Auto Layout
        view.removeConstraints(view.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        view.removeConstraints(scrollView.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        view.removeConstraints(pageControl.constraints)
        view.translatesAutoresizingMaskIntoConstraints = true
        
        // set the background for landscape view
        view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        // try: how about we put the two background the same? will it be more smooth? -- not a good idea
//        scrollView.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
        
        // very important: for testing scroll view works or not
//        scrollView.contentSize = CGSize(width: 1000, height: 1000)
        
        pageControl.numberOfPages = 0
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        // set frame of scrollView
        // use safe area to avoid the notch of iPhone X and later iPhone
        let safeFrame = view.safeAreaLayoutGuide.layoutFrame
        scrollView.frame = safeFrame
        
        // set frame of pageControl
        pageControl.frame = CGRect(x: safeFrame.origin.x, y: safeFrame.height - pageControl.frame.height,
                                   width: safeFrame.width, height: pageControl.frame.height)
        
        // calculate how many buttons can fit in according the view size
        // note: (we can only know the view size after viewDidLoad() invoked)
        if isFirstTime {
            isFirstTime = false
            tileButtons(search.searchResults)
        }
    }

    // MARK: - Private Methods
    private func tileButtons(_ searchResults: [SearchResult]) {
        let itemWidth: CGFloat = 94
        let itemHeight: CGFloat = 88
        var columnsPerPage = 0
        var rowsPerPage = 0
        var marginX: CGFloat = 0
        var marginY: CGFloat = 0
        let viewWidth = scrollView.bounds.size.width
        let viewHeight = scrollView.bounds.size.height
        
        columnsPerPage = Int(viewWidth/itemWidth)
        rowsPerPage = Int(viewHeight/itemHeight)
        
        print("TAG \(rowsPerPage) rows per page, \(columnsPerPage) columns per page")
        
        marginX = (viewWidth - itemWidth * CGFloat(columnsPerPage)) * 0.5
        marginY = (viewHeight - itemHeight * CGFloat(rowsPerPage)) * 0.5
        
        // Button size
        let buttonWidth: CGFloat = 82
        let buttonHeight: CGFloat = 82
        let paddingHorz = (itemWidth - buttonWidth) * 0.5
        let paddingVert = (itemHeight - buttonHeight) * 0.5
        
        // Add the buttons
        var row = 0
        var column = 0
        var x = marginX
        for (index, result) in search.searchResults.enumerated() {
            // draw buttons in the first column, then the second...
            // system button for test
//            let button = UIButton(type: .system)
//            button.backgroundColor = UIColor.white
//            button.setTitle("\(index)", for: .normal)

            // customize button background image
            let button = UIButton(type: .custom)
            button.setBackgroundImage(UIImage(named: "LandscapeButton"), for: .normal)
            downloadImage(for: result, andPlaceOn: button)
            
            //
            button.frame = CGRect(x: x + paddingHorz,
                                  y: marginY + paddingVert + CGFloat(row) * itemHeight,
                                  width: buttonWidth, height: buttonHeight)
            
            //
            scrollView.addSubview(button)
            
            // change to another item
            row += 1
            if Int(row) == rowsPerPage {
                row = 0
                column += 1
                x += itemWidth
                
                if Int(column) == columnsPerPage {
                    column = 0
                    x += 2 * marginX
                }
            }
            
        }
        
        // set the contentSize of scrollView
        let numPages = 1 + (search.searchResults.count - 1) / (rowsPerPage * columnsPerPage)
        scrollView.contentSize = CGSize(width: CGFloat(numPages) * viewWidth, height: viewHeight)
        print("TAG Number of pages: \(numPages)")
        
        pageControl.numberOfPages = numPages
        pageControl.currentPage = 0
    }
    
    private func downloadImage(for result: SearchResult, andPlaceOn button: UIButton) {
        if let url = URL(string: result.imageSmall) {
            // completionHandler: <#T##(URL?, URLResponse?, Error?) -> Void#>
            let task = URLSession.shared.downloadTask(with: url) {
                [weak button]url, _, error in
                if error == nil, let url = url,
                   let data = try? Data(contentsOf: url),
                   let image = UIImage(data: data)
                {
                    DispatchQueue.main.async {
                        if let button = button {
                            button.setImage(image, for: .normal)
                        }
                    }
                }
            }
            
            task.resume()
            downloadTasks.append(task)
        }
    }
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destination.
        // Pass the selected object to the new view controller.
    }
    */

    // MARK: - Actions
    @IBAction func pageChanged(_ sender: UIPageControl) {
        // set scroll view content offset base on page control's current page
//        scrollView.contentOffset = CGPoint(x: CGFloat(sender.currentPage) * scrollView.bounds.size.width,
//                                           y: 0)
        
        // add animation
        UIView.animate(withDuration: 0.3, delay: 0,
                       options: [.curveEaseInOut],
                       animations: {
            self.scrollView.contentOffset = CGPoint(x: self.scrollView.bounds.size.width * CGFloat(sender.currentPage), y: 0)
        },
                       completion: nil)
    }
}

extension LandscapeViewController: UIScrollViewDelegate {
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        // set page control current page base on scroll view's content offset
        
//        let viewWidth = view.bounds.size.width    // use view width is the same ?
        let width = scrollView.bounds.size.width
        let page = Int((scrollView.contentOffset.x + width * 0.5)/width)
        pageControl.currentPage = page
    }
}
