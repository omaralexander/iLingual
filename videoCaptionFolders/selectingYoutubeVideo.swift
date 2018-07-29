//
//  selectingYoutubeVideo.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 2/7/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Firebase
import NotificationBannerSwift
import NVActivityIndicatorView
import GoogleMobileAds

class selectingYoutubeVideo: UIViewController, GADBannerViewDelegate {
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var borderUnderTextField: UITextField!
    @IBOutlet weak var youtubeTextField:UITextField!
    @IBOutlet weak var nextButton:UIButton!
    @IBOutlet weak var activityIndicator:NVActivityIndicatorView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    
    var videoLocation = ""
    var videoHTTPLink = ""
    
    let warningStatusBanner = StatusBarNotificationBanner(title: "Getting everything ready,hang tight!", style: .warning)
    var progressStatusBanner: StatusBarNotificationBanner?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonFunction), for: .touchUpInside)
        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(dismissKeyboard)))
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(dismissKeyboard))
        swipeDown.direction = .down
        view.addGestureRecognizer(swipeDown)
        
        borderUnderTextField.layer.masksToBounds = true
        
        let border = CALayer()
        let width = CGFloat(1.5)
        let whiteColor = UIColor.black.cgColor
       
        border.borderColor = whiteColor
        border.borderWidth = CGFloat(1.5)
        border.frame = CGRect(x: 0, y: borderUnderTextField.frame.size.height - width, width: borderUnderTextField.frame.size.width, height: borderUnderTextField.frame.size.height)
        border.borderWidth = width
        border.opacity = 0.7
        borderUnderTextField.layer.addSublayer(border)
        
        bannerView.frame.origin.y = UIScreen.main.bounds.height - bannerView.frame.height
        bannerView.adUnitID = "ca-app-pub-5917202857375028/3364442514"
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
        print("The adview has failed \(error.localizedDescription)")
    }
    func adViewWillPresentScreen(_ bannerView: GADBannerView) {
        print("User has selected ad; moving to full screen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func dismissKeyboard(){
        view.endEditing(true)
    }
    override func viewWillDisappear(_ animated: Bool) {
        self.warningStatusBanner.dismiss()
        self.progressStatusBanner?.dismiss()
    }
    
    func signUserInAnonymously(){
        Auth.auth().signInAnonymously { (user, err) in
            if err != nil{
                self.showErrorBanner((err?.localizedDescription)!)
                return
            } else {
                self.nextButtonFunction()
            }
        }
    }
    @objc func nextButtonFunction(){
        
        if self.youtubeTextField.text == "Enter URL" || self.youtubeTextField.text == " " || self.youtubeTextField.text?.isEmpty == true {
            
            let warning = StatusBarNotificationBanner(title: "No URL entered", style: .danger)
            warning.autoDismiss = true
            warning.show()
            
        } else {
        
        warningStatusBanner.autoDismiss = false
            
            self.nextButton.isHidden = true
            self.activityIndicator.isHidden = false
            self.activityIndicator.startAnimating()
            
            self.videoLocation = ""
        
            guard let uid = Auth.auth().currentUser?.uid else{
                print("no uid")
                self.signUserInAnonymously()
                return
            }
        
            guard let youtubeURL = self.youtubeTextField.text else {
                print("there was nothing entered")
                return
            }
            
            self.videoHTTPLink = youtubeURL
        
            warningStatusBanner.show()
      
        let value = ["youtubeURL":youtubeURL,"linkLocation":""] as [String:Any]
      
            Database.database().reference().child("YoutubeRequests").child(uid).updateChildValues(value, withCompletionBlock: { (err, ref) in
                if err != nil{
                    self.showErrorBanner((err?.localizedDescription)!)
                } else {
                    
                    self.progressInfoObserver(uid)
                    
                    var observer:UInt = 0
                    observer = Database.database().reference().child("YoutubeRequests").child(uid).observe(.value, with: { (snapshot) in
                        if let dictionary = snapshot.value as? [String: AnyObject]{
                            
                            guard let value = dictionary["linkLocation"] as? String else {return}

                            self.videoLocation = value
                            if value != ""{
                                Database.database().reference().child("YoutubeRequests").child(uid).removeObserver(withHandle: observer)
                                
                                self.warningStatusBanner.dismiss()
                                
                                self.nextButton.isHidden = false
                                self.activityIndicator.isHidden = true
                                self.activityIndicator.stopAnimating()
                                
                                self.performSegue(withIdentifier: "selectLanguage", sender: self)
                        }
                    }
                })
            }
        })
    }
}
    func progressInfoObserver(_ uid: String){
        
        var progressInfoObserver:UInt = 0
        
        progressInfoObserver = Database.database().reference().child("YoutubeRequests").child(uid).observe(.value, with: { (snapshot) in
            if let dictionary = snapshot.value as? [String: AnyObject]{

                guard let value = dictionary["progressInfo"] as? String else {return}
                    print("This is the values inside of progressInfo \(value)")
            
                switch value {
                case "File size is too large":
                    self.warningStatusBanner.dismiss()
                    self.setupBannerForProgress("File is larger than 10MB", .danger)

                    Database.database().reference().child("YoutubeRequests").child(uid).removeObserver(withHandle: progressInfoObserver)

                default:
                    print("strange...")
                }
            }
        })
    }
    
    
    func setupBannerForProgress(_ description:String,_ style: BannerStyle){
       // progressStatusBanner?.dismiss()
        
        self.warningStatusBanner.dismiss()
        self.nextButton.isHidden = false
        self.activityIndicator.isHidden = true
        self.activityIndicator.stopAnimating()
        
        progressStatusBanner = StatusBarNotificationBanner(title: description, style: style)
        progressStatusBanner?.autoDismiss = true
        progressStatusBanner?.show()
        
    }
    
    func showErrorBanner(_ errorDescrption:String){
        let errorBanner = NotificationBanner(title: "Error",
                                             subtitle: errorDescrption,
                                             style: .danger)
        errorBanner.show()
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectLanguage"{
            let viewController = segue.destination as? selectingALanguage
            viewController?.youtubeURLLocation = self.videoLocation
            viewController?.videoHTTPLink = self.videoHTTPLink
        }
    }
}

