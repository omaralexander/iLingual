//
//  translatingToVC.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 3/22/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import GoogleMobileAds

class translatingToVC: UIViewController,UICollectionViewDelegate,UICollectionViewDataSource, GADBannerViewDelegate {
    
    @IBOutlet weak var backButton:UIButton!
    @IBOutlet weak var collectionView:UICollectionView!
    @IBOutlet weak var bannerView: GADBannerView!
    
    var urlOfVideo: URL?
    var translatingFromLanguage: String?
    var googleCodeTranslatingFromLanguage: String?
    var translatingToLanguage: String?
    var youtubeURLLocation: String?
    var videoHTTPLink: String?
    
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }

    var languagesArray = [
      googleAndSpeechLanguageCode(googleCode: "am", speechCode: "am", languageName: "Amharic"),
      googleAndSpeechLanguageCode(googleCode: "ar", speechCode: "ar", languageName: "العربية"),
      googleAndSpeechLanguageCode(googleCode: "eu", speechCode: "eu", languageName: "Basque"),
      googleAndSpeechLanguageCode(googleCode: "bn", speechCode: "bn", languageName: "Bengali"),
      googleAndSpeechLanguageCode(googleCode: "en-GB", speechCode: "en_GB", languageName: "English(UK)"),
      googleAndSpeechLanguageCode(googleCode: "pt-BR", speechCode: "pt_BR", languageName: "Portuguese(Brazil)"),
      googleAndSpeechLanguageCode(googleCode: "bg", speechCode: "bg", languageName: "Bulgarian"),
      googleAndSpeechLanguageCode(googleCode: "ca", speechCode: "ca", languageName: "Catalan"),
      googleAndSpeechLanguageCode(googleCode: "chr", speechCode: "chr", languageName: "Cherokee"),
      googleAndSpeechLanguageCode(googleCode: "hr", speechCode: "hr", languageName: "Croatian"),
      googleAndSpeechLanguageCode(googleCode: "cs", speechCode: "cs", languageName: "Czech"),
      googleAndSpeechLanguageCode(googleCode: "da", speechCode: "da", languageName: "Danish"),
      googleAndSpeechLanguageCode(googleCode: "nl", speechCode: "nl", languageName: "Dutch"),
      googleAndSpeechLanguageCode(googleCode: "en", speechCode: "en_US", languageName: "English(US)"),
      googleAndSpeechLanguageCode(googleCode: "et", speechCode: "et", languageName: "Estonian"),
      googleAndSpeechLanguageCode(googleCode: "fil", speechCode: "fil", languageName: "Filipino"),
      googleAndSpeechLanguageCode(googleCode: "fi", speechCode: "fi", languageName: "Finnish"),
      googleAndSpeechLanguageCode(googleCode: "fr", speechCode: "fr", languageName: "French"),
      googleAndSpeechLanguageCode(googleCode: "de", speechCode: "de", languageName: "German"),
      googleAndSpeechLanguageCode(googleCode: "el", speechCode: "el", languageName: "Greek"),
      googleAndSpeechLanguageCode(googleCode: "gu", speechCode: "gu", languageName: "Gujarati"),
      googleAndSpeechLanguageCode(googleCode: "iw", speechCode: "he", languageName: "עברית"),
      googleAndSpeechLanguageCode(googleCode: "hi", speechCode: "hi", languageName: "Hindi"),
      googleAndSpeechLanguageCode(googleCode: "hu", speechCode: "hu", languageName: "Hungarian"),
      googleAndSpeechLanguageCode(googleCode: "is", speechCode: "is", languageName: "Icelandic"),
      googleAndSpeechLanguageCode(googleCode: "id", speechCode: "id", languageName: "Bahasa Indonesia"),
      googleAndSpeechLanguageCode(googleCode: "it", speechCode: "it", languageName: "Italian"),
      googleAndSpeechLanguageCode(googleCode: "ja", speechCode: "ja", languageName: "Japanese"),
      googleAndSpeechLanguageCode(googleCode: "kn", speechCode: "kn", languageName: "Kannada"),
      googleAndSpeechLanguageCode(googleCode: "ko", speechCode: "ko", languageName: "Korean"),
      googleAndSpeechLanguageCode(googleCode: "lv", speechCode: "lv", languageName: "Latvian"),
      googleAndSpeechLanguageCode(googleCode: "lt", speechCode: "lt", languageName: "Lithuanian"),
      googleAndSpeechLanguageCode(googleCode: "ms", speechCode: "ms", languageName: "Bahasa Malaysia"),
      googleAndSpeechLanguageCode(googleCode: "ml", speechCode: "ml", languageName: "Malayalam"),
      googleAndSpeechLanguageCode(googleCode: "mr", speechCode: "mr", languageName: "Marathi"),
      googleAndSpeechLanguageCode(googleCode: "no", speechCode: "nn_NO", languageName: "Norwegian"),
      googleAndSpeechLanguageCode(googleCode: "pl", speechCode: "pl", languageName: "Polish"),
      googleAndSpeechLanguageCode(googleCode: "pt-PT", speechCode: "pt_PT", languageName: "Portuguese(Portugal)"),
      googleAndSpeechLanguageCode(googleCode: "ro", speechCode: "ro", languageName: "Romanian"),
      googleAndSpeechLanguageCode(googleCode: "ru", speechCode: "ru", languageName: "Russian"),
      googleAndSpeechLanguageCode(googleCode: "sr", speechCode: "sr", languageName: "Serbian"),
      googleAndSpeechLanguageCode(googleCode: "zh-CN", speechCode: "zh_Hans_CN", languageName: "Chinese(PRC)"),
      googleAndSpeechLanguageCode(googleCode: "sk", speechCode: "sk", languageName: "Slovak"),
      googleAndSpeechLanguageCode(googleCode: "sl", speechCode: "sl", languageName: "Slovenian"),
      googleAndSpeechLanguageCode(googleCode: "es", speechCode: "es", languageName: "Spanish"),
      googleAndSpeechLanguageCode(googleCode: "sw", speechCode: "sw", languageName: "Swahili"),
      googleAndSpeechLanguageCode(googleCode: "sv", speechCode: "sv", languageName: "Swedish"),
      googleAndSpeechLanguageCode(googleCode: "ta", speechCode: "ta", languageName: "Tamil"),
      googleAndSpeechLanguageCode(googleCode: "te", speechCode: "te", languageName: "Telugu"),
      googleAndSpeechLanguageCode(googleCode: "th", speechCode: "th", languageName: "Thai"),
      googleAndSpeechLanguageCode(googleCode: "zh-TW", speechCode: "zh_Hant_TW", languageName: "Chinese(Taiwan)"),
      googleAndSpeechLanguageCode(googleCode: "tr", speechCode: "tr", languageName: "Turkish"),
      googleAndSpeechLanguageCode(googleCode: "ur", speechCode: "ur", languageName: "Urdu"),
      googleAndSpeechLanguageCode(googleCode: "uk", speechCode: "uk", languageName: "Ukrainian"),
      googleAndSpeechLanguageCode(googleCode: "vi", speechCode: "vi", languageName: "Vietnamese"),
      googleAndSpeechLanguageCode(googleCode: "cy", speechCode: "cy", languageName: "Welsh")
      ]

    override func viewDidLoad() {
        super.viewDidLoad()
                
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.allowsMultipleSelection = true
        
        bannerView.frame.origin.y = UIScreen.main.bounds.height - bannerView.frame.height
        bannerView.adUnitID = "ca-app-pub-5917202857375028/2837828903"
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
        print("User has selected ad; moving to full screen")
    }
    func adViewWillDismissScreen(_ bannerView: GADBannerView) {
        print("adViewDidDismissScreen")
    }
    func adViewWillLeaveApplication(_ bannerView: GADBannerView) {
        print("adViewWillLeaveApplication")
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let value = languagesArray[indexPath.row]
        self.translatingToLanguage = value.googleCode
        print("This is the value inside of didSelectItemAt\(value.googleCode)")
        performSegue(withIdentifier: "analyzeVideo", sender: self)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return languagesArray.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! collectionViewLanguagesCell
        
        cell.languagesLabel.text = self.languagesArray[indexPath.row].languageName
        return cell
    }
    
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "analyzeVideo"{
            let viewController = segue.destination as! analyzeVideo
            
            viewController.googleCodeTranslatingFromLanguage = self.googleCodeTranslatingFromLanguage
            viewController.urlPath = self.urlOfVideo
            viewController.translatingFromLanguage = self.translatingFromLanguage
            viewController.translatingToLanguage = self.translatingToLanguage
            viewController.youtubeURLLocation = self.youtubeURLLocation
            viewController.videoHTTPLink = self.videoHTTPLink
            print("This is the value inside of the segue passing over \(self.translatingToLanguage)")
        }
    }
    
}
