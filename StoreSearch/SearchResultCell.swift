//
//  SearchResultCell.swift
//  StoreSearch
//
//  Created by user206341 on 11/4/21.
//

import UIKit

class SearchResultCell: UITableViewCell {

    @IBOutlet var nameLabel: UILabel!
    @IBOutlet var artistNameLabel: UILabel!
    @IBOutlet var artworkImageView: UIImageView!
    
    var downloadTask: URLSessionDownloadTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        // Initialization code
        // change the selected background of the cell
        let selectedView = UIView(frame: CGRect.zero)
        selectedView.backgroundColor = UIColor(named: "SearchBarColor")?.withAlphaComponent(0.5)
        selectedBackgroundView = selectedView
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
    // when current cell is going to be reuse
    override func prepareForReuse() {
        super.prepareForReuse()
        
        // cancel pending download task
        if let text = nameLabel.text {
            print("TAG SearchResultCell prepareForReuse \(text)")
        }else {
            print("TAG SearchResultCell prepareForReuse No NameLabel")
        }
        downloadTask?.cancel()
        downloadTask = nil
    }
    
    // MARK: - Helper Methods
    func configure(for searchResult: SearchResult) {
        self.nameLabel.text = searchResult.name
        //cell.artistNameLabel.text = searchResults[indexPath.row].artistName
        if searchResult.artist.isEmpty {
            self.artistNameLabel.text = "Unknown"
        }else {
            self.artistNameLabel.text = String(format: "%@ (%@)", searchResult.artist, searchResult.type)
        }

        // load image from url in searchResult
        artworkImageView.image = UIImage(systemName: "square")
        if let smallURL = URL(string: searchResult.imageSmall) {
            downloadTask = artworkImageView.loadImage(url: smallURL)
        }
        
    }

}
