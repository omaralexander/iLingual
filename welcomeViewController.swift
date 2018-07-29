//
//  welcomeViewController.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 12/6/17.
//  Copyright © 2017 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Canvas
import NotificationBannerSwift
import ViewAnimator
import Crashlytics
import StoreKit
import Photos
import GoogleMobileAds

class welcomeViewController: UIViewController, GADBannerViewDelegate {
  
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    @IBOutlet weak var liveCameraButton: UIButton!
    @IBOutlet weak var choosePhotoButton:UIButton!
    @IBOutlet weak var takeAPhotoButton:UIButton!
    @IBOutlet weak var writingTranslationButton: UIButton!
    
    @IBOutlet weak var liveCameraView: CSAnimationView!
    @IBOutlet weak var takeAPhotoView: CSAnimationView!
    @IBOutlet weak var chooseAPhotoView: CSAnimationView!
    @IBOutlet weak var writingTranslation: CSAnimationView!
    @IBOutlet weak var bannerView: GADBannerView!

    
    @IBAction func unwindToHome(segue:UIStoryboardSegue){
        
    }
    
   let translationIncrementerSetting = "numberOfTranslations"
   let minimumTranslationCount = 5
   let color = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6).cgColor

    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        liveCameraButton.addTarget(self, action: #selector(goToLiveCamera), for: .touchUpInside)
        choosePhotoButton.addTarget(self, action: #selector(goToSelectAPhoto), for: .touchUpInside)
        takeAPhotoButton.addTarget(self, action: #selector(goToTakeAPhoto), for: .touchUpInside)
        writingTranslationButton.addTarget(self, action: #selector(goToWritingTranslation), for: .touchUpInside)
        
        liveCameraButton.layer.cornerRadius = 15
        liveCameraButton.layer.shadowColor = color
        liveCameraButton.layer.shadowOpacity = 0.4
        liveCameraButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        liveCameraButton.layer.shadowRadius = 4
        
        choosePhotoButton.layer.cornerRadius = 15
        choosePhotoButton.layer.shadowColor = color
        choosePhotoButton.layer.shadowOpacity = 0.4
        choosePhotoButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        choosePhotoButton.layer.shadowRadius = 4
        
        takeAPhotoButton.layer.cornerRadius = 15
        takeAPhotoButton.layer.shadowColor = color
        takeAPhotoButton.layer.shadowOpacity = 0.4
        takeAPhotoButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        takeAPhotoButton.layer.shadowRadius = 4
        
        writingTranslationButton.layer.cornerRadius = 15
        writingTranslationButton.layer.shadowColor = color
        writingTranslationButton.layer.shadowOpacity = 0.4
        writingTranslationButton.layer.shadowOffset = CGSize(width: 0, height: 1)
        writingTranslationButton.layer.shadowRadius = 4
        
        animate()
        
        bannerView.frame.origin.y = UIScreen.main.bounds.height - bannerView.frame.height
        bannerView.adUnitID = "ca-app-pub-5917202857375028/2127382466"
        bannerView.rootViewController = self
        bannerView.load(GADRequest())
        bannerView.delegate = self
    }
    
    func adViewDidReceiveAd(_ bannerView: GADBannerView) {
        print("Banner is recieved")
        bannerView.alpha = 0
        UIView.animate(withDuration: 1, animations: {
            bannerView.alpha = 1
        })
    }
    func adView(_ bannerView: GADBannerView, didFailToReceiveAdWithError error: GADRequestError) {
        print("The adView has failed \(error.localizedDescription)")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("User has selected add; moving to full screen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    override func viewDidAppear(_ animated: Bool) {
        self.showReview()
    }
    
    @objc func animate(){
         let animation = AnimationType.from(direction: .bottom, offset: 50.0)
        
        liveCameraButton.animate(animations: [animation])
        choosePhotoButton.animate(animations: [animation])
        takeAPhotoButton.animate(animations: [animation])
        writingTranslation.animate(animations: [animation])
    }
    @objc func goToLiveCamera(){
            let cameraMediaType = AVMediaType.video
            let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
            
            switch cameraAuthorizationStatus {
            case .denied:
                let alertController = UIAlertController(title: "No Camera Access", message: "We need camera access to access your camera", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                
                break
            case .authorized:
                print("it is authorized")
                Answers.logCustomEvent(withName: "Live Camera selected", customAttributes: [:])
                performSegue(withIdentifier: "goToLiveCamera", sender: self)
                break
            case .restricted:
                let alertController = UIAlertController(title: "No Camera Access", message: "We need camera access to access your camera", preferredStyle: .alert)
                let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                    guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(settingsUrl) {
                        UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                            print("Settings opened: \(success)") // Prints true
                        })
                    }
                }
                alertController.addAction(settingsAction)
                let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                alertController.addAction(cancelAction)
                
                self.present(alertController, animated: true, completion: nil)
                
                break
                
            case .notDetermined:
                print("not determined we got a sich ")
                // Prompting user for the permission to use the camera.
                AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (status) in
                    if status == true {
                        Answers.logCustomEvent(withName: "Live Camera selected", customAttributes: [:])
                        self.performSegue(withIdentifier: "goToLiveCamera", sender: self)
                    } else {
                        let alertController = UIAlertController(title: "No Camera Access", message: "We need camera access to access your camera", preferredStyle: .alert)
                        let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                            guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                                return
                            }
                            
                            if UIApplication.shared.canOpenURL(settingsUrl) {
                                UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                    print("Settings opened: \(success)") // Prints true
                                })
                            }
                        }
                        alertController.addAction(settingsAction)
                        let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                        alertController.addAction(cancelAction)
                        
                        self.present(alertController, animated: true, completion: nil)
                    }
                })
            }
        }
    @objc func goToTakeAPhoto(){
        
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            Answers.logCustomEvent(withName: "Take a Photo selected", customAttributes: [:])
            performSegue(withIdentifier: "goToTakeAPhoto", sender: self)
            break
        case .denied:
            let alertController = UIAlertController(title: "No camera access", message: "Can't access camera to take photo", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            break
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType, completionHandler: { (status) in
                if status == true {
                    Answers.logCustomEvent(withName: "Take a Photo selected", customAttributes: [:])
                    self.performSegue(withIdentifier: "goToTakeAPhoto", sender: self)
                } else {
                    let alertController = UIAlertController(title: "No camera access", message: "Can't access camera to take photo", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            break
        case .restricted:
            let alertController = UIAlertController(title: "No camera access", message: "Can't access camera to take photo", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            break
        default:
            print("something is wrong..")
        }
    }
    @objc func goToSelectAPhoto(){
        
        let photosAuthorization = PHPhotoLibrary.authorizationStatus()
        switch photosAuthorization {
        case .authorized:
            Answers.logCustomEvent(withName: "Choose a photo selected", customAttributes: [:])
            performSegue(withIdentifier: "goToChooseAPhoto", sender: self)
            break
        case .denied:
            let alertController = UIAlertController(title: "No photos access", message: "Can't access photo library", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            
            break
        case .notDetermined:
            PHPhotoLibrary.requestAuthorization({ (status) in
                if status == .authorized {
                    Answers.logCustomEvent(withName: "Choose a photo selected", customAttributes: [:])
                    self.performSegue(withIdentifier: "goToChooseAPhoto", sender: self)
                } else {
                    let alertController = UIAlertController(title: "No photos access", message: "Can't access photo library", preferredStyle: .alert)
                    let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                        guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                            return
                        }
                        
                        if UIApplication.shared.canOpenURL(settingsUrl) {
                            UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                                print("Settings opened: \(success)") // Prints true
                            })
                        }
                    }
                    alertController.addAction(settingsAction)
                    let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
                    alertController.addAction(cancelAction)
                    
                    self.present(alertController, animated: true, completion: nil)
                }
            })
            break
        case .restricted:
            let alertController = UIAlertController(title: "No photos access", message: "Can't access photo library", preferredStyle: .alert)
            let settingsAction = UIAlertAction(title: "Settings", style: .default) { (_) -> Void in
                guard let settingsUrl = URL(string: UIApplicationOpenSettingsURLString) else {
                    return
                }
                
                if UIApplication.shared.canOpenURL(settingsUrl) {
                    UIApplication.shared.open(settingsUrl, completionHandler: { (success) in
                        print("Settings opened: \(success)") // Prints true
                    })
                }
            }
            alertController.addAction(settingsAction)
            let cancelAction = UIAlertAction(title: "Cancel", style: .default, handler: nil)
            alertController.addAction(cancelAction)
            
            self.present(alertController, animated: true, completion: nil)
            break
            
        default:
            print("something is wrong")
            
        }
    }
    @objc func goToWritingTranslation(){
        Answers.logCustomEvent(withName: "Writing translation selected", customAttributes: [:])
        let banner = NotificationBanner(title: "Coming soon!",
                                             subtitle: "This will be available in the next update!",
                                             style: .info)
        banner.show()
        //performSegue(withIdentifier: "goToWritingTranslation", sender: self)
    }
    
    func getTranslationCounts() -> Int{
        let usD = UserDefaults()
        let savedRuns = usD.value(forKey: translationIncrementerSetting)
        var translations = 0
        if (savedRuns != nil){
            translations = savedRuns as! Int
        }
        print("Translation times \(translations)")
        return translations
    }
    func showReview() {
        
        let runs = getTranslationCounts()
        if (runs > minimumTranslationCount) {
            
            if #available(iOS 10.3, *) {
                SKStoreReviewController.requestReview()
                
            } else {
                // Fallback on earlier versions
            }
            
        } else {
            
        }
    }
}
