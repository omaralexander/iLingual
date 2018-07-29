//
//  chooseAPhotoViewController.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 12/7/17.
//  Copyright © 2017 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Photos
import CHTCollectionViewWaterfallLayout
import ViewAnimator

class chooseAPhotoViewController: UIViewController, UICollectionViewDelegate, UICollectionViewDataSource, CHTCollectionViewDelegateWaterfallLayout{

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var collectionView: UICollectionView!
    
    var images = [PHAsset]()
    var collectionViewSize = CGSize()
    var imageToPassOver = UIImage()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        DispatchQueue.global(qos: .background).async {
            self.getImages()
        }
        self.collectionView.dataSource = self
        self.collectionView.delegate = self
        setupCollectionView()
     
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)

    }
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
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
        let assets = PHAsset.fetchAssets(with: PHAssetMediaType.image, options: nil)
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
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
//CGSize(width: images[indexPath.row].pixelWidth, height: images[indexPath.row].pixelHeight)

        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: cell.frame.width, height: cell.frame.height),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                cell.imageView.image = result
        })
    
        return cell
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        let animation = AnimationType.from(direction: .bottom, offset: 50.0)
        cell.animate(animations: [animation])
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! userPhotosCell
        let asset = images[indexPath.row]
        let manager = PHImageManager.default()
        if cell.tag != 0 {
            manager.cancelImageRequest(PHImageRequestID(cell.tag))
        }
        
        cell.tag = Int(manager.requestImage(for: asset,
                                            targetSize: CGSize(width: images[indexPath.row].pixelWidth, height: images[indexPath.row].pixelHeight),
                                            contentMode: .aspectFill,
                                            options: nil) { (result, _) in
                                                self.imageToPassOver = result!
                                                self.performSegue(withIdentifier: "analyzePhoto", sender: self)
        })
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAtIndexPath indexPath: IndexPath) -> CGSize {
        let imageHeight = images[indexPath.row].pixelHeight
        let imageWidth = images[indexPath.row].pixelWidth
        
        return CGSize(width: imageHeight, height: imageWidth)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "analyzePhoto" {
            let viewController = segue.destination as! analyzePhotoViewController
            viewController.imageToAnalyze = self.imageToPassOver
            
        }
    }
}

