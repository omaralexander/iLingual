//
//  previewVideoViewController.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 2/3/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit
import AVKit
import AVFoundation

class previewVideoViewController : AVPlayerViewController{
    var videoUrl: URL?
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if let url = videoUrl {            
            let player = AVPlayer(url: url)
            self.player = player
            self.player?.play()
        }
    }
}
