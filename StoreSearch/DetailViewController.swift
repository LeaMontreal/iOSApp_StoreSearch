//
//  DetailViewController.swift
//  StoreSearch
//
//  Created by user206341 on 11/7/21.
//

import UIKit

class DetailViewController: UIViewController {

    @IBOutlet var popupView: UIView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var artworkImageView: UIImageView!
    @IBOutlet weak var artistNameLabel: UILabel!
    @IBOutlet weak var genreLabel: UILabel!
    @IBOutlet weak var kindLabel: UILabel!
    @IBOutlet weak var priceButton: UIButton!

    var searchResult: SearchResult!
    var downloadTask: URLSessionDownloadTask?

    enum AnimationStyle {
        case slide
        case fade
    }
    var dismissStyle = AnimationStyle.fade
    
    // is invoked to load the view controller from the storyboard
    required init?(coder: NSCoder) {
        super.init(coder: coder)
        transitioningDelegate = self
    }
    
    deinit {
        print("DetailViewController deinit \(self)")
        downloadTask?.cancel()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        
        // draw gradient background
        view.backgroundColor = UIColor.clear
        let dimmingView = GradientView(frame: CGRect.zero)
        dimmingView.frame = view.bounds
        view.insertSubview(dimmingView, at: 0)
        
        // change the popupView into a rounded corner rectangle
        // my confusion: it seems not the effect we want, why?
        popupView.layer.cornerRadius = 10
        
        // note: it's UITapGestureRecognizer
        let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
        gestureRecognizer.cancelsTouchesInView = false
        gestureRecognizer.delegate = self
        view.addGestureRecognizer(gestureRecognizer)
//        print("TAG DetailViewController viewDidLoad()...")
        
        updateUI()
    }
    
    // MARK: - Helper Methods
    func updateUI() {
        nameLabel.text = searchResult.name
        if searchResult.artist.isEmpty {
            artistNameLabel.text = "Unknown"
        }else {
            artistNameLabel.text = searchResult.artist
        }
        kindLabel.text = searchResult.type
        genreLabel.text = searchResult.genre
        
        // show price
        let formatter = NumberFormatter()
        formatter.numberStyle = .currency
        formatter.currencyCode = searchResult.currency
        let priceText: String
        if searchResult.price == 0 {
            priceText = "Free"
        }else if let text = formatter.string(from: searchResult.price as NSNumber) {
            priceText = text
        }else {
            priceText = ""
        }
        priceButton.setTitle(priceText, for: .normal)
        
        // show image
        if let urlImage = URL(string: searchResult.imageLarge) {
            downloadTask = artworkImageView.loadImage(url: urlImage)
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
    @IBAction func close() {
        // when swipe to close this pop-up view, this close() func does not be invoked
        // then cancel download task have to be done in deinit
//        print("TAG DetailViewController close()...")
        dismissStyle = AnimationStyle.slide
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func openInStore() {
        if let url = URL(string: searchResult.storeURL) {
            UIApplication.shared.open(url, options: [:], completionHandler: nil)
        }
    }
}

extension DetailViewController: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldReceive touch: UITouch) -> Bool {
        return touch.view == self.view
    }
}

extension DetailViewController: UIViewControllerTransitioningDelegate {
    func animationController(forPresented presented: UIViewController, presenting: UIViewController, source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return BounceAnimationController()
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        // replaced by switch clause
//        if dismissStyle == AnimationStyle.fade {
//            return FadeOutAnimationController()
//        }else {
//            return SlideOutAnimationController()
//        }
        
        switch dismissStyle {
        case .fade:
            return FadeOutAnimationController()
        case .slide:
            return SlideOutAnimationController()
        }
    }
}
