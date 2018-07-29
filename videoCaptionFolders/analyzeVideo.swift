//
//  analyzeVideo.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 2/4/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Speech
import Firebase
import AVFoundation
import NVActivityIndicatorView
import ROGoogleTranslate
import WebKit

class analyzeVideo: UIViewController,WKNavigationDelegate {
    
    var urlPath: URL?
    var translatingFromLanguage: String?
    var googleCodeTranslatingFromLanguage: String?
    var translatingToLanguage:String?
    var youtubeURLLocation: String?
    var videoHTTPLink: String?
    var originalLabelFrame = CGRect()
    var showMoreOriginalTextFieldFrame = CGRect()
    var originalCaptionViewFrame = CGRect()
    var translationCaptionViewFrame = CGRect()
    var webView: WKWebView?

    
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var captionTextField: UITextView!
    @IBOutlet weak var translationTextField: UITextView!
    @IBOutlet weak var translationLabel: UILabel!
    @IBOutlet weak var originalLabel: UILabel!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var showMoreTranslationTextField: UIButton!
    @IBOutlet weak var showMoreOriginalTextField: UIButton!
    @IBOutlet weak var originalCaptionView: UIView!
    @IBOutlet weak var translationCaptionView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!
    @IBOutlet weak var containerView: UIView!
    @IBOutlet weak var viewForWebKit: UIView!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.webView = WKWebView()
        let webViewFrame = CGRect(x: viewForWebKit.frame.origin.x, y: viewForWebKit.frame.origin.y, width: viewForWebKit.frame.width, height: viewForWebKit.frame.height)
        webView?.navigationDelegate = self
        webView?.frame = webViewFrame
        self.webView?.configuration.allowsInlineMediaPlayback = true
        self.webView?.configuration.mediaTypesRequiringUserActionForPlayback = []
        view.addSubview(webView!)
        view.bringSubview(toFront: webView!)
        
        setupView()
        
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                if self.youtubeURLLocation != nil {
                   
                    self.containerView.isHidden = true
                    self.webView?.isHidden = false
                    
                    self.analyzeAudioFromURL(videoLocation: self.youtubeURLLocation!)
                    
                    guard let safeHTTPLink = self.videoHTTPLink else {
                        return print("The link didn't pass")
                    }
                    
                    self.setupWebKit(safeHTTPLink)
                
                } else {

                    self.containerView.isHidden = false
                    self.webView?.isHidden = true
                    
                    guard let nonEmptyVideoURL = self.urlPath else {
                        print("There was no video url found")
                        return
                    }
                    
                    self.analyzeSoundInVideo(nonEmptyVideoURL)
                }

                break
            case .denied:
                
                self.presentingAlertController("No access", "Analyze speech of your video")
                
                break
            case .restricted:
                
                self.presentingAlertController("No access", "Analyze speech of your video")
                
                break
            case .notDetermined:
                SFSpeechRecognizer.requestAuthorization({ granted in
                    if self.youtubeURLLocation != nil {
                        
                        self.containerView.isHidden = true
                        self.webView?.isHidden = false
                        
                        self.analyzeAudioFromURL(videoLocation: self.youtubeURLLocation!)
                        
                   
                        guard let safeHTTPLink = self.videoHTTPLink else {
                            return print("The link didn't pass")
                        }
                        
                        self.setupWebKit(safeHTTPLink)
                    
                    } else {

                        self.containerView.isHidden = false
                        self.webView?.isHidden = true
                        
                        guard let nonEmptyVideoURL = self.urlPath else {
                            print("There was no video url found")
                            return
                        }
                        
                        self.analyzeSoundInVideo(nonEmptyVideoURL)
                    }
                })
            }
        }
    }

    func setupWebKit(_ urlString:String){
        
        let url = URL(string: urlString)
        let request = URLRequest(url: url!)
        
        self.webView?.load(request)
        
    }
    
    func setupView(){
        
        self.originalCaptionView.layer.masksToBounds = false
        self.originalCaptionView.layer.cornerRadius = 10
        self.originalCaptionView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6).cgColor
        self.originalCaptionView.layer.shadowOpacity = 0.4
        self.originalCaptionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.originalCaptionView.layer.shadowRadius = 4
        
        self.translationCaptionView.layer.masksToBounds = false
        self.translationCaptionView.layer.cornerRadius = 10
        self.translationCaptionView.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6).cgColor
        self.translationCaptionView.layer.shadowOpacity = 0.4
        self.translationCaptionView.layer.shadowOffset = CGSize(width: 0, height: 1)
        self.translationCaptionView.layer.shadowRadius = 4
        
        
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        showMoreTranslationTextField.addTarget(self, action: #selector(expandTranslationTextField), for: .touchUpInside)
        showMoreOriginalTextField.addTarget(self, action: #selector(expandOriginalTextField), for: .touchUpInside)
        
        scrollView.contentSize.height = self.originalCaptionView.frame.origin.y + self.originalCaptionView.frame.height * 1.5
        
        self.activityIndicator.startAnimating()
        
    }
    
    override func viewDidLayoutSubviews() {
        
        self.originalCaptionViewFrame = self.originalCaptionView.frame
        
        self.translationCaptionViewFrame = self.translationCaptionView.frame

        self.originalLabelFrame = self.originalLabel.frame

        self.showMoreOriginalTextFieldFrame = self.showMoreOriginalTextField.frame
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        
        if self.youtubeURLLocation != nil{
        let fileLocation = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create:
            false).appendingPathComponent("\(self.youtubeURLLocation as! String)")
        do {
            try FileManager.default.removeItem(at: fileLocation)
        } catch let error {
            print(error.localizedDescription)
            }
        }
    }
    
    func analyzeAudioFromURL(videoLocation: String){
        //after one minute trim the audio file then start repeating the process 9 more times looping through the process to continue speech recognition

        let fileURL = try! FileManager.default.url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false).appendingPathComponent("\(videoLocation)")
        let storageReference = Storage.storage().reference().child(videoLocation)
        
        storageReference.write(toFile: fileURL) { (completedURL, error) in
            if error != nil{
                print(error?.localizedDescription as Any)
                return
            } else {
                
                let viewController = self.childViewControllers.last as? previewVideoViewController
                viewController?.videoUrl = fileURL

                //when different languages are selected, file comes up as corrupt. Leave it as Locale.current for now
                // ar_EG && ar for arabic
                //Locale.init(identifier: "enter languages in here")
            
                guard let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: self.translatingFromLanguage!)) else{
                    print("Can't use this locale")
                    return
                }
            
                let request = SFSpeechURLRecognitionRequest(url: fileURL)
        
                recognizer.recognitionTask(with: request, resultHandler: { (result, error) in
                    if error != nil{
                        print(error?.localizedDescription as Any)
                        return
                    } else {
                        guard let result = result else {
                            print("There was an error transcribing")
                            return
                        }
                        if result.isFinal{
                            self.captionTextField.text = result.bestTranscription.formattedString
                        } else {
                            self.captionTextField.text = result.bestTranscription.formattedString
                            self.translateOutput(result.bestTranscription.formattedString)
                        }
                    }
                })
            }
        }
    }

    func analyzeSoundInVideo(_ url: URL){
        
     //   let asset = AVAsset(url: url)
        
     //   let audioUrl = URL(fileURLWithPath: NSTemporaryDirectory()).appendingPathComponent("audio.m4a")
      
    //    asset.writeAudioTrack(to: audioUrl, success: {
          //  print("success")
     //   }) { (error) in
        //    print(error.localizedDescription)
      //  }

        guard let recognizer = SFSpeechRecognizer(locale: Locale.init(identifier: self.translatingFromLanguage!)) else {
            print("Speech recogniztion not available for specfiied locale")
            return
        }

        let request = SFSpeechURLRecognitionRequest(url: url)
        recognizer.recognitionTask(with: request) { (result, err) in
            if err != nil {
                print(err?.localizedDescription as Any)
                return
            }
            guard let result = result else{
                print("there was an error transcribing")
                return
            }
            if result.isFinal{
                //we would stop the activityIndicator running
                self.captionTextField.text = result.bestTranscription.formattedString
                self.translateOutput(result.bestTranscription.formattedString)
            } else {
                self.captionTextField.text = result.bestTranscription.formattedString
                self.translateOutput(result.bestTranscription.formattedString)
                
            }
        }
    }
    
    func translateOutput(_ output: String){
        
        let params = ROGoogleTranslateParams(source: self.googleCodeTranslatingFromLanguage!, target: self.translatingToLanguage!, text: output)
        let translator = ROGoogleTranslate()
        translator.apiKey = "AIzaSyDsF3NRWrH_2RltXRmLcjBiuxwId0DfcBA"
        translator.translate(params: params) { (result) in
            DispatchQueue.main.async{
            
            self.translationTextField.text = result
            self.activityIndicator.isHidden = true
            self.activityIndicator.stopAnimating()
            }
        }
    }
    
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func expandOriginalTextField(){
        if self.showMoreOriginalTextField.titleLabel?.text == "Show More"{
            
            self.scrollView.setContentOffset(CGPoint(x: self.originalLabel.frame.origin.x, y: self.originalLabel.frame.origin.y), animated: true)
            self.scrollView.isScrollEnabled = false
            
            UIView.animate(withDuration: 0.5){
                
                self.showMoreOriginalTextField.setTitle("Show Less", for: .normal)
                self.originalCaptionView.frame.size.width = UIScreen.main.bounds.width
                self.originalCaptionView.frame.size.height = self.scrollView.frame.height
                
            }
        } else{
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.scrollView.isScrollEnabled = true
            
            UIView.animate(withDuration: 0.5){
                self.showMoreOriginalTextField.setTitle("Show More", for: .normal)
                self.originalCaptionView.frame = self.originalCaptionViewFrame
            }
        }
    }
    
    @objc func expandTranslationTextField(){
        if self.showMoreTranslationTextField.titleLabel?.text == "Show More"{
            
            self.scrollView.setContentOffset(CGPoint(x: self.translationLabel.frame.origin.x, y: self.translationLabel.frame.origin.y), animated: true)
            self.scrollView.isScrollEnabled = false
            
           
            UIView.animate(withDuration: 0.5){
                
                self.showMoreTranslationTextField.setTitle("Show Less", for: .normal)
                self.translationCaptionView.frame.size.width = UIScreen.main.bounds.width
                self.translationCaptionView.frame.size.height = self.scrollView.frame.height
                
                self.originalCaptionView.frame.origin.y = self.originalCaptionView.frame.origin.y + UIScreen.main.bounds.height + self.originalCaptionView.frame.height
               
                self.originalLabel.frame.origin.y = self.originalLabel.frame.origin.y + UIScreen.main.bounds.height + self.originalLabel.frame.height
                
                self.showMoreOriginalTextField.frame.origin.y = self.showMoreOriginalTextField.frame.origin.y + UIScreen.main.bounds.height + self.showMoreOriginalTextField.frame.height
                }
        } else{
            
            self.scrollView.setContentOffset(CGPoint(x: 0, y: 0), animated: true)
            self.scrollView.isScrollEnabled = true
            UIView.animate(withDuration: 0.5){
                
                self.showMoreTranslationTextField.setTitle("Show More", for: .normal)
                
                self.translationCaptionView.frame = self.translationCaptionViewFrame
                
                self.originalCaptionView.frame = self.originalCaptionViewFrame
                
                self.originalLabel.frame = self.originalLabelFrame
                
                self.showMoreOriginalTextField.frame = self.showMoreOriginalTextFieldFrame
            }
        }
    }
    
    func presentingAlertController(_ title:String,_ message:String){
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
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
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        print("did finish loading the link")
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "videoInBackground"{
            
            let viewController = segue.destination as! previewVideoViewController
            
            if self.youtubeURLLocation == nil{
                guard let nonEmptyVideoURL = self.urlPath else {
                    print("There was no video url found")
                    return
                }
                print("This is the nonEmptyVideoURL \(nonEmptyVideoURL)")
                    viewController.videoUrl = nonEmptyVideoURL
                }
            }
        }
    }


