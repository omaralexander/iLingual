//
//  formatForLiveCamera.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 12/11/17.
//  Copyright © 2017 Ai-Lingual Team. All rights reserved.
//

import UIKit

class liveCameraFormat{
    var predictionText: String?
    var predictionPercentage: String?
    
    init(PredictionText: String, PredictionPercentage: String){
        self.predictionText = PredictionText
        self.predictionPercentage = PredictionPercentage
    }
}
