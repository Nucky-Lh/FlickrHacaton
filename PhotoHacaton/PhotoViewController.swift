//
//  PhotoViewController.swift
//  PhotoHacaton
//
//  Created by Николай Лахов on 21.08.2021.
//

import UIKit
import Kingfisher

class PhotoViewController: UIViewController {
    
    var photo: Photo?
    
    @IBOutlet weak var photoImageView: UIImageView!
    

    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let photo = photo, let url = URL(string: photo.bigImageURL) {
            photoImageView.kf.setImage(with: url)
        }

       
    }
    
}
