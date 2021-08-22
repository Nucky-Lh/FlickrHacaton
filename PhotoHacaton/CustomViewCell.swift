//
//  CustomViewCell.swift
//  PhotoHacaton
//
//  Created by Николай Лахов on 21.08.2021.
//

import UIKit
import Kingfisher

class CustomViewCell: UICollectionViewCell {

   
    @IBOutlet weak var imageView: UIImageView!
    
    
    var imageURL: String? {
        didSet {
            if let imageURL = imageURL, let url = URL(string: imageURL) {
                imageView.kf.setImage(with: url)
            } else {
                imageView.image = nil
                imageView.kf.cancelDownloadTask()
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageURL = nil
        }
    }


