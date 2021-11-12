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

    var searchResult: SearchResult! {
        // for iPad, after searchResult be set a new value
        didSet {
            if isViewLoaded {
                updateUI()
            }
        }
    }
    
    var downloadTask: URLSessionDownloadTask?

    enum AnimationStyle {
        case slide
        case fade
    }
    var dismissStyle = AnimationStyle.fade
    var isPopUp = false
    
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

        if isPopUp {
            // change the popupView into a rounded corner rectangle
            // my confusion: it seems not the effect we want, why?
            popupView.layer.cornerRadius = 10

            // draw gradient background
            view.backgroundColor = UIColor.clear
            let dimmingView = GradientView(frame: CGRect.zero)
            dimmingView.frame = view.bounds
            view.insertSubview(dimmingView, at: 0)

            // note: it's UITapGestureRecognizer
            let gestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(close))
            gestureRecognizer.cancelsTouchesInView = false
            gestureRecognizer.delegate = self
            view.addGestureRecognizer(gestureRecognizer)
    //        print("TAG DetailViewController viewDidLoad()...")

        }else {
            // why background pattern doesn't show in iPad? -- my confusion
            // it's a bug, I connected popupView property to the view of the Detail scene,
            // then when popupView.isHidden = true, new backgroundColor is hidden too
            view.backgroundColor = UIColor(patternImage: UIImage(named: "LandscapeBackground")!)
            popupView.isHidden = true
            
            // will change later for localization
            title = NSLocalizedString("StoreSearch", comment: "split view detail title")
        }

        updateUI()

        
    }
    
    // MARK: - Helper Methods
    func updateUI() {
        guard searchResult != nil else {return}
        
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
        
        // for iPad, let popupView show
        // TODO: this way the second pane will show quite abruptly, how to change make it show with animation?
//        popupView.isHidden = false
        showDetailPane()
    }

    // the effect is not good enough, to be improved later...
    func showDetailPane() {
        UIView.animate(withDuration: 0.3,
                       animations: {
//            self.splitViewController!.preferredDisplayMode = .automatic
            self.popupView.isHidden = false
            self.popupView.transform = CGAffineTransform(scaleX: 0.9, y: 0.9)
        },
                       completion: { _ in
            self.popupView.transform = CGAffineTransform(scaleX: 1, y: 1)
        })
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
        if touch.view === self.view {
            print("TAG gestureRecognizer shouldReceive true")
            return true
        }else {
            print("TAG gestureRecognizer shouldReceive false")
            return false
        }
//        return touch.view === self.view
// or
//        return touch.view == self.view
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
