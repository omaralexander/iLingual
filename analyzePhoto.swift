//
//  analyzePhoto.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 12/9/17.
//  Copyright © 2017 Ai-Lingual Team. All rights reserved.
//

import UIKit
import Clarifai_Apple_SDK
import NVActivityIndicatorView
import ROGoogleTranslate
import AVFoundation
import NotificationBannerSwift
import ViewAnimator
import StoreKit


class analyzePhotoViewController: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource,UICollectionViewDelegateFlowLayout,UIPickerViewDataSource,UIPickerViewDelegate  {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var collectionView: UICollectionView!
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var activityIndicator: NVActivityIndicatorView!


    @IBOutlet weak var targetLanguageLabel: UITextField!
    @IBOutlet weak var buttonToChangeLanguage: UIButton!
    
    var imageToAnalyze = UIImage()
    var concepts: [Concept] = []
    var customModel: Model!
    var model: Model!
    var collectionViewArray = [valuesForArray]()
    
    var voiceLanguage = String()
    var targetLanguageName = String()
    
    let translationIncrementerSetting = "numberOfTranslations"
    
    var sourceTranslateLanguage = [
        availableLanguageArray(Language: "Arabic", Code: "ar"),
        availableLanguageArray(Language: "Bengali", Code: "bn"),
        availableLanguageArray(Language: "Danish", Code: "da"),
        availableLanguageArray(Language: "German", Code: "de"),
        availableLanguageArray(Language: "English", Code: "en"),
        availableLanguageArray(Language: "Spanish", Code: "es"),
        availableLanguageArray(Language: "Finnish", Code: "fi"),
        availableLanguageArray(Language: "French", Code: "fr"),
        availableLanguageArray(Language: "Hindi", Code: "hi"),
        availableLanguageArray(Language: "Hungarian", Code: "hu"),
        availableLanguageArray(Language: "Italian", Code: "it"),
        availableLanguageArray(Language: "Japanese", Code: "ja"),
        availableLanguageArray(Language: "Korean", Code: "ko"),
        availableLanguageArray(Language: "Dutch", Code: "nl"),
        availableLanguageArray(Language: "Norwegian", Code: "no"),
        availableLanguageArray(Language: "Punjabi", Code: "pa"),
        availableLanguageArray(Language: "Polish", Code: "pl"),
        availableLanguageArray(Language: "Portuguese", Code: "pt"),
        availableLanguageArray(Language: "Russian", Code: "ru"),
        availableLanguageArray(Language: "Swedish", Code: "sv"),
        availableLanguageArray(Language: "Turkish", Code: "tr"),
        availableLanguageArray(Language: "Chinese", Code: "zh")
    ]
    var googleTranslateLanguages = [
        availableLanguageArray(Language: "Arabic", Code: "ar"),
        availableLanguageArray(Language: "Chinese", Code: "zh"),
        availableLanguageArray(Language: "Czech", Code: "cs"),
        availableLanguageArray(Language: "Danish", Code: "da"),
        availableLanguageArray(Language: "Dutch", Code: "nl"),
        availableLanguageArray(Language: "English", Code: "en"),
        availableLanguageArray(Language: "Finnish", Code: "fi"),
        availableLanguageArray(Language: "French", Code: "fr"),
        availableLanguageArray(Language: "German", Code: "de"),
        availableLanguageArray(Language: "Greek", Code: "el"),
        availableLanguageArray(Language: "Hebrew", Code: "he"),
        availableLanguageArray(Language: "Hindi", Code: "hi"),
        availableLanguageArray(Language: "Hungarian", Code: "hu"),
        availableLanguageArray(Language: "Indonesian", Code: "id"),
        availableLanguageArray(Language: "Italian", Code: "it"),
        availableLanguageArray(Language: "Japanese", Code: "ja"),
        availableLanguageArray(Language: "Korean", Code: "ko"),
        availableLanguageArray(Language: "Norwegian", Code: "no"),
        availableLanguageArray(Language: "Polish", Code: "pl"),
        availableLanguageArray(Language: "Portuguese", Code: "pt"),
        availableLanguageArray(Language: "Romanian", Code: "ro"),
        availableLanguageArray(Language: "Russian", Code: "ru"),
        availableLanguageArray(Language: "Slovak", Code: "sk"),
        availableLanguageArray(Language: "Spanish", Code: "es"),
        availableLanguageArray(Language: "Swedish", Code: "sv"),
        availableLanguageArray(Language: "Thai", Code: "th"),
        availableLanguageArray(Language: "Turkish", Code: "tr")]
   
    var translationVoiceLanguages = [
        availableLanguageArray(Language: "Arabic", Code: "ar-SA"),
        availableLanguageArray(Language: "Chinese", Code: "zh-CN"),
        availableLanguageArray(Language: "Czech", Code: "zh-HK"),
        availableLanguageArray(Language: "Danish", Code: "da-DK"),
        availableLanguageArray(Language: "Dutch", Code: "nl-BE"),
        availableLanguageArray(Language: "English", Code: "en-US"),
        availableLanguageArray(Language: "Finnish", Code: "fi-FI"),
        availableLanguageArray(Language: "French", Code: "fr-FR"),
        availableLanguageArray(Language: "German", Code: "de-DE"),
        availableLanguageArray(Language: "Greek", Code: "el-GR"),
        availableLanguageArray(Language: "Hebrew", Code: "he-IL"),
        availableLanguageArray(Language: "Hindi", Code: "hi-IN"),
        availableLanguageArray(Language: "Hungarian", Code: "hu-HU"),
        availableLanguageArray(Language: "Indonesian", Code: "id-ID"),
        availableLanguageArray(Language: "Italian", Code: "it-IT"),
        availableLanguageArray(Language: "Japanese", Code: "ja-JP"),
        availableLanguageArray(Language: "Korean", Code: "ko-KR"),
        availableLanguageArray(Language: "Norwegian", Code: "no-NO"),
        availableLanguageArray(Language: "Polish", Code: "pl-PL"),
        availableLanguageArray(Language: "Portuguese", Code: "pt-BR"),
        availableLanguageArray(Language: "Romanian", Code: "ro-RO"),
        availableLanguageArray(Language: "Russian", Code: "ru-RU"),
        availableLanguageArray(Language: "Slovak", Code: "sk-SK"),
        availableLanguageArray(Language: "Spanish", Code: "es-MX"),
        availableLanguageArray(Language: "Swedish", Code: "sv-SE"),
        availableLanguageArray(Language: "Thai", Code: "th-TH"),
        availableLanguageArray(Language: "Turkish", Code: "tr-TR")
    ]
    
    let generalModelSelected = 0
    let customModelSegment = 1
    var targetLanguageArray = UIPickerView()

    @IBAction func presentPicker(_ sender: UITextField) {
        let usD = UserDefaults()
        let runs = self.getTranslationCounts() + 1
        usD.setValuesForKeys([self.translationIncrementerSetting : runs])
        usD.synchronize()
        
        targetLanguageArray.backgroundColor = UIColor.white
        sender.inputView = targetLanguageArray
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        voiceLanguage = "fr-FR"
        targetLanguageName = "French"

        targetLanguageLabel.text = "French"
        
        targetLanguageArray.delegate = self
        targetLanguageArray.dataSource = self
        
        let swipeDown = UISwipeGestureRecognizer(target: self, action: #selector(endEditing))
        swipeDown.direction = .down
        swipeDown.cancelsTouchesInView = false
        self.view.addGestureRecognizer(swipeDown)

        self.model = Clarifai.sharedInstance().generalModel
        
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        
        collectionView.delegate = self
        collectionView.dataSource = self
        
        collectionView.allowsSelection = true
        
        imageView.image = imageToAnalyze
        imageView.layer.cornerRadius = 5
        predict(selectedImage: imageToAnalyze)
        
        mainView.layer.cornerRadius = 10
        mainView.layer.masksToBounds = false
        mainView.backgroundColor = UIColor.clear

    }
 
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return collectionViewArray.count
    }
    @objc func endEditing(){
        view.endEditing(true)
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! takeAPhotoCollectionView
        
        cell.originalLabel.text = self.collectionViewArray[indexPath.row].name
        cell.translationLabel.text = self.collectionViewArray[indexPath.row].translation
        
        cell.layer.masksToBounds = false
        cell.layer.cornerRadius = 10
        cell.backgroundColor = UIColor.clear
        
        
        cell.viewBackground.layer.cornerRadius = 10
        cell.viewBackground.layer.shadowColor = UIColor(red: 0/255, green: 0/255, blue: 0/255, alpha: 0.6).cgColor
        cell.viewBackground.layer.shadowOpacity = 0.4
        cell.viewBackground.layer.shadowOffset = CGSize(width: 0, height: 1)
        cell.viewBackground.layer.shadowRadius = 4
   
        return cell
    }
    func predict(selectedImage: UIImage){

        self.view.bringSubview(toFront: self.activityIndicator)
        self.activityIndicator.isHidden = false
        self.activityIndicator.startAnimating()
        self.collectionViewArray.removeAll()

        let image = Image(image: selectedImage)

        let dataAsset = DataAsset.init(image: image)

        let input = Input.init(dataAsset:dataAsset)
        let inputs = [input]
        
        var target = String()
        
        for targetCode in self.googleTranslateLanguages{
            if targetCode.languageName == targetLanguageName{
                target = targetCode.code!
            }
        }
//        self.model.output?.configuration.language = source
        DispatchQueue.global(qos: .background).async {
            
        self.model.predict(inputs, completionHandler: {(outputs: [Output]?,error: Error?) -> Void in
        
            for output in outputs! {
               
                //self.concepts.append(contentsOf: output.dataAsset.concepts!)
            
                for concept in output.dataAsset.concepts! {
                    
                    
                    let params = ROGoogleTranslateParams(source: "en", target: target, text: concept.name)
                    
                    let translator = ROGoogleTranslate()
                    translator.apiKey = "AIzaSyDsF3NRWrH_2RltXRmLcjBiuxwId0DfcBA"
                    translator.translate(params: params) { (result) in
                    
                    
                    let structure = valuesForArray(Name: concept.name, Translation: result)
                    self.collectionViewArray.append(structure)
                    let animation = AnimationType.from(direction: .bottom, offset: 50.0)
                    self.collectionView.animateViews(animations: [animation])
                    self.collectionView.reloadData()
                        
                    }
                }
            }
            
            if error != nil{
            
            let errorBanner = NotificationBanner(title: "Error uploading your post",
            subtitle: error?.localizedDescription,
            style: .danger)
            errorBanner.show()
            return
                }
            })
        }
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
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let speakTalk = AVSpeechSynthesizer()
        let speakMSG = AVSpeechUtterance(string: self.collectionViewArray[indexPath.row].translation!)
        speakMSG.voice = AVSpeechSynthesisVoice(language: voiceLanguage)
        speakMSG.pitchMultiplier = 1.2
        speakMSG.rate = 0.5
        speakTalk.speak(speakMSG)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 10
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return self.mainView.frame.size
    }
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
    }
    func collectionView(_ collectionView: UICollectionView, willDisplay cell: UICollectionViewCell, forItemAt indexPath: IndexPath) {
        
        self.activityIndicator.stopAnimating()
        self.activityIndicator.isHidden = true
        
        let animation = AnimationType.from(direction: .bottom, offset: 50.0)
        cell.animate(animations: [animation])
    }

    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        var count = Int()
        if pickerView == targetLanguageArray{
            count = googleTranslateLanguages.count
        }
        return count
    }
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        var value = String()
        if pickerView == targetLanguageArray{
            value = googleTranslateLanguages[row].languageName!
        }
        return value
    }
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let selectedRow = googleTranslateLanguages[row]
        
        if pickerView == targetLanguageArray {
           self.targetLanguageLabel.text = selectedRow.languageName
            self.targetLanguageName = selectedRow.languageName!
            self.predict(selectedImage: imageToAnalyze)
            retrieveTargetCode(languageName: selectedRow.languageName!)
        }
        self.view.endEditing(true)
    }
    func retrieveTargetCode(languageName: String){
        let languages = self.translationVoiceLanguages
        for code in languages {
            if code.languageName == languageName {
                voiceLanguage = code.code!
            }
        }
    }
}
