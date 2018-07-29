//
//  takeAPictureViewController.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 12/6/17.
//  Copyright © 2017 Ai-Lingual Team. All rights reserved.
//

import UIKit
import AVFoundation
import NotificationBannerSwift
class takeAPictureViewController: UIViewController,AVCapturePhotoCaptureDelegate {

    @IBOutlet weak var cameraFlashlightImage: UIImageView!
    @IBOutlet weak var takeAPhotoButton: UIView!
    @IBOutlet weak var flipCameraImage: UIImageView!
    @IBOutlet weak var backButtonImage: UIImageView!
    @IBOutlet weak var imageView: UIView!

    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    let yellowColor = UIColor(red: 243/255, green: 217/255, blue: 106/255, alpha: 1)
   
    var captureSession:AVCaptureSession?
    var videoPreviewLayer: AVCaptureVideoPreviewLayer?
    var capturePhotoOutput: AVCapturePhotoOutput?
    var flashSettings = AVCapturePhotoSettings().flashMode
    var photoTaken = UIImage()

    
    override func viewDidLoad(){
        super.viewDidLoad()

        takeAPhotoButton.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(takeAPhoto)))
        flipCameraImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(swapCamera)))
        cameraFlashlightImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(flashFunction)))



    }
    override func viewDidAppear(_ animated: Bool) {
        let cameraMediaType = AVMediaType.video
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: cameraMediaType)
        
        switch cameraAuthorizationStatus {
        case .denied:
            
            print("it is denied")
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
            let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
            do {
                let input = try AVCaptureDeviceInput(device: captureDevice!)
                captureSession = AVCaptureSession()
                captureSession?.addInput(input)
                captureSession?.startRunning()
                
                videoPreviewLayer = AVCaptureVideoPreviewLayer(session: captureSession!)
                videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                videoPreviewLayer?.frame = view.layer.bounds
                imageView.layer.addSublayer(videoPreviewLayer!)
                
                videoPreviewLayer?.frame = imageView.frame
            }
            catch{
                
                let errorBanner = NotificationBanner(title: "Error",
                                                     subtitle: error.localizedDescription,
                                                     style: .danger)
                errorBanner.show()
                return
            }
            capturePhotoOutput = AVCapturePhotoOutput()
            capturePhotoOutput?.isHighResolutionCaptureEnabled = true
            
            //set the output on the capture session
            captureSession?.addOutput(capturePhotoOutput!)
            
            break
        case .restricted:
            print("it is restricted")
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
            AVCaptureDevice.requestAccess(for: cameraMediaType) { granted in
                if granted {
                    print("Granted access to \(cameraMediaType)")
                    let captureDevice = AVCaptureDevice.default(for: AVMediaType.video)
                    do {
                        let input = try AVCaptureDeviceInput(device: captureDevice!)
                        self.captureSession = AVCaptureSession()
                        self.captureSession?.addInput(input)
                        self.captureSession?.startRunning()
                        
                        self.videoPreviewLayer = AVCaptureVideoPreviewLayer(session: self.captureSession!)
                        self.videoPreviewLayer?.videoGravity = AVLayerVideoGravity.resizeAspectFill
                        self.videoPreviewLayer?.frame = self.view.layer.bounds
                        self.imageView.layer.addSublayer(self.videoPreviewLayer!)
                        
                        self.videoPreviewLayer?.frame = self.imageView.frame
                    }
                    catch{
                        
                        let errorBanner = NotificationBanner(title: "Error",
                                                             subtitle: error.localizedDescription,
                                                             style: .danger)
                        errorBanner.show()
                        return
                    }
                    self.capturePhotoOutput = AVCapturePhotoOutput()
                    self.capturePhotoOutput?.isHighResolutionCaptureEnabled = true
                    
                    //set the output on the capture session
                    self.captureSession?.addOutput(self.capturePhotoOutput!)
                    
                } else {
                    print("Denied access to \(cameraMediaType)")
                }
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
            
            let errorBanner = NotificationBanner(title: "Error",
                                                 subtitle: error.localizedDescription,
                                                 style: .danger)
            errorBanner.show()

            return
        }
        
        // Swap capture device inputs
        captureSession?.removeInput(input)
        captureSession?.addInput(deviceInput)
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
    
    @objc func takeAPhoto(){
        guard let capturePhotoOutput = self.capturePhotoOutput else {
            return
        }
        let photoSettings = AVCapturePhotoSettings()
        photoSettings.isAutoStillImageStabilizationEnabled = true
        photoSettings.flashMode = flashSettings
        photoSettings.isHighResolutionPhotoEnabled = true
        
        capturePhotoOutput.capturePhoto(with: photoSettings, delegate: self)
        
    }

    func photoOutput(_ captureOutput: AVCapturePhotoOutput,
                     didFinishProcessingPhoto photoSampleBuffer: CMSampleBuffer?,
                     previewPhoto previewPhotoSampleBuffer: CMSampleBuffer?,
                     resolvedSettings: AVCaptureResolvedPhotoSettings,
                     bracketSettings: AVCaptureBracketedStillImageSettings?,
                     error: Error?) {
            guard error == nil,
                let photoSampleBuffer = photoSampleBuffer else {
                   
                    let errorBanner = NotificationBanner(title: "Error capturing photo",
                                                         subtitle: error?.localizedDescription,
                                                         style: .danger)
                    errorBanner.show()
                
                    return
            }

        guard let imageData =
            AVCapturePhotoOutput.jpegPhotoDataRepresentation(forJPEGSampleBuffer: photoSampleBuffer, previewPhotoSampleBuffer: previewPhotoSampleBuffer) else {
                return
        }
        
        let dataProvider = CGDataProvider(data: imageData as CFData)
        
        let cgImageRef = CGImage(jpegDataProviderSource: dataProvider!, decode: nil, shouldInterpolate: true, intent: CGColorRenderingIntent.absoluteColorimetric)
        
        
        let image = UIImage(cgImage: cgImageRef!, scale: 1.0, orientation: UIImageOrientation.right)
        photoTaken = image
        performSegue(withIdentifier: "analyzePhoto", sender: self)
        }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "analyzePhoto" {
            let viewController = segue.destination as! analyzePhotoViewController
            viewController.imageToAnalyze = photoTaken
            
        }
    }
}
