//
//  ViewController.swift
//  PhotoHacaton
//
//  Created by Николай Лахов on 21.08.2021.
//
import Foundation
import UIKit
import Alamofire
import SwiftyJSON
import Kingfisher
import MBProgressHUD

class MainViewController: UIViewController {

    @IBOutlet weak var collectionView: UICollectionView!
    
    var photos: [Photo] = []
    var layoutType: LayoutType = .grid
    
 
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
       
        getFlickrPhotos()
        
        }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super .prepare(for: segue, sender: sender)

        if let photoViewController = segue.destination as? PhotoViewController,
            let indexPath = collectionView.indexPathsForSelectedItems?.first {
                photoViewController.photo = photos[indexPath.row]
            }

        }
        
    
    @IBAction func segmentControl(_ sender: UISegmentedControl) {
        self.layoutType = LayoutType(rawValue: sender.selectedSegmentIndex) ?? .grid
        collectionView.reloadData()
    }

    }
    
//MARK CollectionView
extension MainViewController: UICollectionViewDelegate, UICollectionViewDataSource, UICollectionViewDelegateFlowLayout, UISearchBarDelegate{
    
    enum LayoutType: Int {
        case grid
        case list
    }
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return photos.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "CustomViewCell", for: indexPath) as! CustomViewCell
        
        let photo = photos[indexPath.row]
        cell.imageURL = layoutType == .grid ? photo.smallImageURL : photo.bigImageURL
        
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        if layoutType == .grid {
        let itemWidth = collectionView.bounds.width / 3
        return CGSize(width: itemWidth, height: itemWidth)
        } else {
            return CGSize(width: collectionView.bounds.width, height: 300)
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, viewForSupplementaryElementOfKind kind: String, at indexPath: IndexPath) -> UICollectionReusableView {
        var reusableView = UICollectionReusableView()

        if kind == UICollectionView.elementKindSectionHeader {
            reusableView = collectionView.dequeueReusableSupplementaryView(ofKind: kind, withReuseIdentifier: "SearchHeader", for: indexPath)
        }

        return reusableView
    }
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        getFlickrPhotos(searchText: searchBar.text)
    }
    
    
}

//MARK Networking
extension MainViewController {
   
    
        func getFlickrPhotos(searchText: String? = nil) {
            MBProgressHUD.showAdded(to: view, animated: true)
    
            fetchFlickrPhotos(searchText: searchText) { [weak self] (photos) in
                guard let strongSelf = self else { return }
                MBProgressHUD.hide(for: strongSelf.view, animated: true)
                
                if let photos = photos {
                    strongSelf.photos = photos
                    strongSelf.collectionView.reloadData()
                }
            }
        }
        
    
    func fetchFlickrPhotos(searchText: String? = nil, completion: (([Photo]?) -> Void)? = nil) {
        let url = URL(string: "https://www.flickr.com/services/rest/")!
        var parameters = [
            "method" : "flickr.interestingness.getList",
            "api_key" : "702ed6485749d0c578dfcdb4c738cfc8",
            "sort" : "relevance",
            "per_page" : "50",
            "format" : "json",
            "nojsoncallback" : "1",
            "extras" : "url_q,url_z"
        ]
        
        if let searchText = searchText {
            parameters["method"] = "flickr.photos.search"
            parameters["text"] = searchText
        }
        
        AF.request(url, method: .get, parameters: parameters)
            .validate()
            .responseData { (responce) in
                switch responce.result {
                case .success:
                    guard let data = responce.data, let json = try? JSON(data: data) else {
                        print("Error while parsing Flickr response")
                        completion?(nil)
                        return
                    }
 
                    // добрались до JSON                    print(json)
                    let photosJSON = json["photos"]["photo"]
                    let photos = photosJSON.arrayValue.compactMap { Photo(json: $0) }
                    completion?(photos)
                   
                case .failure(let error):
                    print("Error while featcing photos: \(error.localizedDescription)")
                    completion?(nil)
                }
        }
    }
    
}
