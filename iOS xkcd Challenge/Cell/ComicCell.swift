//
//  ComicCell.swift
//  iOS xkcd Challenge
//
//  Created by David Troupe on 1/29/19.
//  Copyright © 2019 Studio. All rights reserved.
//

import UIKit
import Anchorage
import Kingfisher

class ComicCell: UITableViewCell {
  
  private let scrollView: UIScrollView = {
    let scrollView = UIScrollView()
    scrollView.contentSize = CGSize(width: 300, height: 300)
    scrollView.isScrollEnabled = false
    scrollView.clipsToBounds = true
    scrollView.alwaysBounceVertical = false
    scrollView.alwaysBounceHorizontal = false
    scrollView.minimumZoomScale = 1.0
    scrollView.maximumZoomScale = 6.0
    return scrollView
  }()
  
  private let comicImageView: UIImageView = {
    let imageView = UIImageView()
    imageView.clipsToBounds = true
    imageView.contentMode = .scaleAspectFit
    imageView.translatesAutoresizingMaskIntoConstraints = false
    return imageView
  }()
  
  private let titleLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.boldSystemFont(ofSize: 17)
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private let altLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 14)
    label.textAlignment = .left
    label.numberOfLines = 0
    return label
  }()
  
  private let dateLabel: UILabel = {
    let label = UILabel()
    label.font = UIFont.systemFont(ofSize: 10)
    label.textAlignment = .left
    label.numberOfLines = 1
    return label
  }()
  
  private func configureUI() {
    contentView.backgroundColor = UIColor.lightGray
    scrollView.delegate = self
    
    let screenWidth = UIScreen.main.bounds.width
    
    contentView.addSubview(titleLabel)
    titleLabel.topAnchor == contentView.topAnchor + 16
    titleLabel.horizontalAnchors == contentView.horizontalAnchors + 8
    
    contentView.addSubview(scrollView)
    scrollView.topAnchor == titleLabel.bottomAnchor + 4
    scrollView.heightAnchor == screenWidth
    scrollView.horizontalAnchors == contentView.horizontalAnchors
    
    scrollView.addSubview(comicImageView)
    comicImageView.topAnchor == scrollView.topAnchor
    comicImageView.horizontalAnchors == scrollView.horizontalAnchors
    comicImageView.bottomAnchor == scrollView.bottomAnchor
    comicImageView.centerXAnchor == scrollView.centerXAnchor
    comicImageView.centerYAnchor == scrollView.centerYAnchor
    
    contentView.addSubview(altLabel)
    altLabel.topAnchor == scrollView.bottomAnchor + 4
    altLabel.horizontalAnchors == contentView.horizontalAnchors + 8
    
    
    contentView.addSubview(dateLabel)
    dateLabel.topAnchor == altLabel.bottomAnchor + 10
    dateLabel.horizontalAnchors == contentView.horizontalAnchors + 8
    dateLabel.bottomAnchor == contentView.bottomAnchor - 12
  }
  
  override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
    super.init(style: style, reuseIdentifier: reuseIdentifier)
    configureUI()
  }
  
  required init?(coder aDecoder: NSCoder) {
    super.init(coder: aDecoder)
    configureUI()
  }
  
  func configure(withComic comic: Comic) {
    titleLabel.text = comic.title
    if let url = URL(string: comic.imageURL) {
      comicImageView.kf.setImage(with: url) { result in
        switch result {
        case .success(let value):
          
          let image = value.image
          
          if image.imageOrientation != .up, let cgImage = image.cgImage {
            
            let newImage = UIImage(cgImage: cgImage, scale: image.scale, orientation: .up)
            let cache = ImageCache.default
            cache.store(newImage, forKey: url.absoluteString)
            
            DispatchQueue.main.async {
              self.comicImageView.image = newImage
            }
          }
        case .failure(let error):
          print(error)
        }
      }
    }
    
    altLabel.text = comic.alt
    dateLabel.text = "\(comic.month)-\(comic.day)-\(comic.year)"
  }
  
  override func prepareForReuse() {
    super.prepareForReuse()
    comicImageView.image = nil
    titleLabel.text = nil
    altLabel.text = nil
    scrollView.setZoomScale(1.0, animated: false)
  }
  
  override func setSelected(_ selected: Bool, animated: Bool) {
    super.setSelected(selected, animated: animated)
  }
}

extension ComicCell: UIScrollViewDelegate {
  func viewForZooming(in scrollView: UIScrollView) -> UIView? {
    return comicImageView
  }
}
