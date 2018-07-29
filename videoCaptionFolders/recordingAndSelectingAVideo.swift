//
//  recordingAndSelectingAVideo.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 1/30/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationBannerSwift
import Photos
import GoogleMobileAds


class recordingAndSelectingAVideo: UIViewController,AVCapturePhotoCaptureDelegate,AVCaptureFileOutputRecordingDelegate,GADInterstitialDelegate {
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var recordVideoButton:UIView!
    @IBOutlet weak var flipCameraImage:UIImageView!
    @IBOutlet weak var imageView:UIView!
    @IBOutlet weak var showVideos:UIImageView!
    @IBOutlet weak var cameraFlashlightImage:UIImageView!
    @IBOutlet weak var upperBackgroundView:UIView!
    @IBOutlet weak var backButtonImage:UIImageView!
    @IBOutlet weak var enterURLButton: UIButton!
    @IBOutlet weak var searchBarForURL: UISearchBar!
    @IBOutlet weak var progressBar: UIView!
    
    var captureSession:AVCaptureSession?
    var videoPreviewLayer:AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var flashSettings = AVCapturePhotoSettings().flashMode
    var videoFileOutput = AVCaptureMovieFileOutput()
    var statusBarStyle: UIStatusBarStyle?
    var videoLocationURL: URL?
    var interstitial: GADInterstitial!
    
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return statusBarStyle!
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.progressBar.isHidden = true
        
        self.statusBarStyle = .default
        
       // self.recordVideoButton.layer.masksToBounds = false
        self.recordVideoButton.layer.cornerRadius = self.recordVideoButton.frame.width / 2
        self.recordVideoButton.layer.cornerRadius = self.recordVideoButton.frame.height / 2
       
        enterURLButton.addTarget(self, action: #selector(enterURLFunction), for: .touchUpInside)
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        flipCameraImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapCamera)))
        cameraFlashlightImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flashFunction)))
        showVideos.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(goToChooseAVideo)))
        
        let longGestureTest = UILongPressGestureRecognizer(target: self, action: #selector(startingRecordingVideo(_:)))
        recordVideoButton.addGestureRecognizer(longGestureTest)
        
      //  let longGesture = UILongPressGestureRecognizer(target: self, action: #selector(recordingVideo(_:)))
       // recordVideoButton.addGestureRecognizer(longGesture)
        
        self.settingUpCameraWithAuth()
        
        interstitial = createAndLoadInterstitial()
    }
    func createAndLoadInterstitial() -> GADInterstitial {
        let interstitial = GADInterstitial(adUnitID:
            "ca-app-pub-5917202857375028/1828957421")
        interstitial.delegate = self
        interstitial.load(GADRequest())
        
        return interstitial
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
    
    func settingUpCameraWithAuth(){
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
      
        switch cameraAuthorizationStatus {
        case .denied:
           
            self.presentingAlertController("No Camera Access", "We need access to record a video")
           
            break
        case .authorized:
          
            self.setupCamera()

            break
        case .restricted:
        
            self.presentingAlertController("No Camera Access", "We need access to record a video")
            
            break
            
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                  self.setupCamera()
                    
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
            }
        }
    }
    
    @objc func startingRecordingVideo(_ sender: UIGestureRecognizer){
        self.videoFileOutput.stopRecording()
        if sender.state == .ended{
            animatingForEndOfVideoRecording()
            self.progressBar.isHidden = true
            self.progressBar.frame.size.width = 0
            
        } else if sender.state == .began {
            self.recordVideo()
            animatingForVideoRecording()
            self.progressBar.isHidden = false
            UIView.animate(withDuration: 40.0){
                self.progressBar.frame.size.width = UIScreen.main.bounds.width
            }
        }
    }
    
    func animatingForVideoRecording(){
        UIView.animate(withDuration: 0.4){
            self.upperBackgroundView.backgroundColor = UIColor.clear
            self.statusBarStyle = .lightContent
            self.setNeedsStatusBarAppearanceUpdate()
            self.backButtonImage.image = UIImage(named: "Bitmap")
            self.flipCameraImage.image = UIImage(named: "flipCamera")
            self.enterURLButton.isHidden = true
        }
    }
    
    func animatingForEndOfVideoRecording(){
        UIView.animate(withDuration: 0.4){
            self.upperBackgroundView.backgroundColor = UIColor.white
            self.statusBarStyle = .default
            self.setNeedsStatusBarAppearanceUpdate()
            self.backButtonImage.image = UIImage(named: "skinnyBlackButton")
            self.flipCameraImage.image = UIImage(named: "blackReverseCamera")
            self.enterURLButton.isHidden = false
        }
    }
    
    
    
    @objc func recordingVideo(_ sender: UIGestureRecognizer){
        
        self.progressBar.isHidden = true
        self.progressBar.frame.size.width = UIScreen.main.bounds.width
        
        if sender.state == .ended{
            self.videoFileOutput.stopRecording()

        } else if sender.state == .began {
            
            self.recordVideo()
            self.progressBar.isHidden = false
            
            UIView.animate(withDuration:60.0){
                self.progressBar.frame.size.width = UIScreen.main.bounds.width
            }
        }
    }
    
    @objc func swapCamera() {
        
        // Get current input
        guard let input = captureSession?.inputs[0] as? AVCaptureDeviceInput else { return }

        
        // Begin new session configuration and defer commit
        captureSession?.beginConfiguration()
        defer { captureSession?.commitConfiguration() }
        
        // Create new capture device
        var newDevice: AVCaptureDevice?
        if input.device.position == .back {
            newDevice = captureDevice(with: .front)
            cameraFlashlightImage.isHidden = true
            flashSettings = .off
            self.cameraFlashlightImage.image = UIImage(named: "flashlight")
        } else {
            newDevice = captureDevice(with: .back)
            cameraFlashlightImage.isHidden = false
            self.cameraFlashlightImage.image = UIImage(named: "flashlight")
            
        }
        
        // Create new capture input
        var deviceInput: AVCaptureDeviceInput!
        do {
            deviceInput = try AVCaptureDeviceInput(device: newDevice!)
        } catch let error {
            self.presentBanner(error.localizedDescription)
            
            return
        }
        
        // Swap capture device inputs
        captureSession?.removeInput(input)
        captureSession?.addInput(deviceInput)
    }
    func setupCamera(){
        
        let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
        let audioDevice = AVCaptureDevice.default(for: AVMediaType.audio)
        
        do {
            let input = try AVCaptureDeviceInput(device: captureDevice!)
            let audioInput = try AVCaptureDeviceInput(device: audioDevice!)
            captureSession = AVCaptureSession()
            captureSession?.addInput(input)
            captureSession?.addInput(audioInput)
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            //set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            captureSession?.addOutput(videoFileOutput)
            
            videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
            videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
            videoPreviewLayer?.frame = view.layer.bounds
            imageView.layer.addSublayer(videoPreviewLayer!)
            
            videoPreviewLayer?.frame = imageView.frame
            
            captureSession?.startRunning()
        }
        catch{
            self.presentBanner(error.localizedDescription)
            return
        }
    }
    
    /// Create new capture device with requested position
    func captureDevice(with position: AVCaptureDevice.Position) -> AVCaptureDevice? {
        
        if #available(iOS 10.2, *) {
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInDualCamera, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
            
            for device in devices {
                if device.position == position {
                    return device
                }
            }
            
        } else {
            // Fallback on earlier versions
            let devices = AVCaptureDevice.DiscoverySession(deviceTypes: [ .builtInWideAngleCamera, .builtInMicrophone, .builtInTelephotoCamera ], mediaType: AVMediaType.video, position: .unspecified).devices
            
            
            for device in devices {
                if device.position == position {
                    return device
                }
            }
        }
        return nil
    }
    func presentBanner(_ errorDescription:String){
        let errorBanner = NotificationBanner(title: "Error",
                                             subtitle: errorDescription,
                                             style: .danger)
        errorBanner.show()
    }
    
    @objc func flashFunction(){
        if flashSettings == .off{
            flashSettings = .on
            UIView.animate(withDuration:0.4){
                self.cameraFlashlightImage.image = UIImage(named: "selectedFlashlight")
            }
        } else{
            flashSettings = .off
            self.cameraFlashlightImage.image = UIImage(named: "flashlight")
        }
    }
    
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    @objc func goToChooseAVideo(){
        performSegue(withIdentifier: "chooseAVideo", sender: self)
    }
    
    @objc func enterURLFunction(){
        if interstitial.isReady{
            interstitial.present(fromRootViewController: self)
        } else {
            print("Ad wasn't ready yet")
            performSegue(withIdentifier: "enterURLSegue", sender: self)
            interstitial = self.createAndLoadInterstitial()
        }
    }
    func interstitialDidReceiveAd(_ ad: GADInterstitial) {
        print("ad has been recieved")
    }
    func interstitial(_ ad: GADInterstitial, didFailToReceiveAdWithError error: GADRequestError) {
        print("This was the error \(error.localizedDescription)")
    }
    func interstitialDidDismissScreen(_ ad: GADInterstitial) {
        performSegue(withIdentifier: "enterURLSegue", sender: self)
        interstitial = self.createAndLoadInterstitial()
    }
    
    @objc func recordVideo(){
        let documentsURL = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0] as URL
        let filePath = documentsURL.appendingPathComponent("tempMovie.mp4")
        if FileManager.default.fileExists(atPath: filePath.absoluteString) {
            do {
                try FileManager.default.removeItem(at: filePath)
            }
            catch {
                // exception while deleting old cached file
                // ignore error if any
            }
        }
        videoFileOutput.startRecording(to: filePath, recordingDelegate: self)
    }

    func fileOutput(_ output: AVCaptureFileOutput, didFinishRecordingTo outputFileURL: URL, from connections: [AVCaptureConnection], error: Error?) {

        if error == nil{
            self.videoLocationURL = outputFileURL
            performSegue(withIdentifier: "previewVideo", sender: self)
            
        } else {
            guard let errorDescription = error?.localizedDescription else {
                return
            }
            self.presentBanner(errorDescription)
        }
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "previewVideo"{
            let viewController = segue.destination as! viewingVideoRecorded
            viewController.urlToPassOver = self.videoLocationURL
            
        }
    }
    func navigateToPlayer(_ url: URL){
        let vc = viewingVideoRecorded()
        vc.urlToPassOver = url
        self.present(vc, animated: true, completion: nil)
    }
}
