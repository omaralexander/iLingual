//
//  choosingAVideoFile.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 2/1/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Photos
import CHTCollectionViewWaterfallLayout
import ViewAnimator
import NotificationBannerSwift


class choosingAVideoFile: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{
    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var collectionViewCellSize: UIView!
    
    var images = [PHAsset]()
    var stringToPassOver: URL?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            self.getImages()
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        
        
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
    }
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
  
    override func viewDidLayoutSubviews() {
        setupCollectionView()
    }
    
    func setupCollectionView(){
        let layout = CHTCollectionViewWaterfallLayout()
        layout.minimumColumnSpacing = 2
        layout.minimumInteritemSpacing = 2
        
        self.collectionView.autoresizingMask = [UIViewAutoresizing.flexibleHeight, UIViewAutoresizing.flexibleWidth]
        self.collectionView.alwaysBounceVertical = true
        self.collectionView.collectionViewLayout = layout
    }
    
    func getImages() {
    
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.video, options: nil)
        assets.enumerateObjects({ (object, count, stop) in
            // self.cameraAssets.add(object)
            self.images.append(object)
        })
        
        //In order to get latest image first, we just reverse the array
        self.images.reverse()
        
        // To show photos, I have taken a UICollectionView
        DispatchQueue.main.async{
            let animation = AnimationType.from(direction: .bottom, offset: 50.0)
            self.collectionView.animateViews(animations: [animation])
            self.collectionView.reloadData()
        }
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return images.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! userPhotosCell
        
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true
        
        options.progressHandler = {
            (progress, error,stop,info) in

            if error != nil {
                print(error!.localizedDescription)
                return
            }
        }

        manager.requestImage(for: asset, targetSize: CGSize(width: cell.frame.width, height: cell.frame.height),
                                            contentMode: .aspectFill,
                                            options: options) { (result, _) in
                                                if result == nil {
                                                    print("There was no cell found")
                                                    return
                                                } else {
                                                cell.imageView.image = result
                                            }
                                        }
                                return cell
                            }
    
    
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let animation = AnimationType.from(direction: .bottom, offset: 50.0)
        cell.animate(animations: [animation])
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        let options = PHVideoRequestOptions()
        options.isNetworkAccessAllowed = true
        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(String(describing: asset.creationDate)).MOV")

        manager.requestAVAsset(forVideo: asset, options: options) { (asset,result, _) in
            guard let resultingAsset = asset as? AVURLAsset else {
                print("There was no URL found")
                return
            }
            
            if String(describing: resultingAsset.url).hasPrefix("file:///var/mobile/Media/PhotoData/Metadata/DCIM/") {
                let videoData = NSData(contentsOf: resultingAsset.url)
                let resultOfWritingToURL = videoData?.write(to: fileURL, atomically: false)
                if resultOfWritingToURL == true {
                    self.stringToPassOver = fileURL
                    self.performSegue(withIdentifier: "selectALanguage", sender: self)
                }
            } else {
                self.stringToPassOver = resultingAsset.url
                self.performSegue(withIdentifier: "selectALanguage", sender: self)
            }
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        
        let imageHeight = images[indexPath.row].pixelHeight
        let imageWidth = images[indexPath.row].pixelWidth
        return CGSize(width: imageHeight, height: imageWidth)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectALanguage" {
            let viewController = segue.destination as! selectingALanguage
            viewController.urlOfVideo = self.stringToPassOver
        }
    }
}


