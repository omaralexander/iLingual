//
//  viewingVideoRecorded.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 2/3/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit

class viewingVideoRecorded: UIViewController {
    @IBOutlet weak var backButton: UIButton!
    @IBOutlet weak var nextButton: UIButton!
    
    var urlToPassOver: URL?
    override var preferredStatusBarStyle: UIStatusBarStyle{
        return .default
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        backButton.addTarget(self, action: #selector(dismissViewController), for: .touchUpInside)
        nextButton.addTarget(self, action: #selector(nextButtonFunction), for: .touchUpInside)
    }
    @objc func dismissViewController(){
        dismiss(animated: true, completion: nil)
    }
    @objc func nextButtonFunction(){
        performSegue(withIdentifier: "selectALanguage", sender: self)
    }
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "selectALanguage"{
            let viewController = segue.destination as! selectingALanguage
            viewController.urlOfVideo = urlToPassOver
            viewController.youtubeURLLocation = ""
            }
        
        if segue.identifier == "childViewController"{
            let viewController = segue.destination as! previewVideoViewController
            viewController.videoUrl = urlToPassOver
        }
    }
}
