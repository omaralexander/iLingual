//
//  googleAndSpeechLanguageCode.swift
//  Ai-Lingual
//
//  Created by Omar Abbas on 4/25/18.
//  Copyright © 2018 Ai-Lingual Team. All rights reserved.
//

import UIKit

class googleAndSpeechLanguageCode{
    
    var googleCode: String?
    var speechCode: String?
    var languageName: String?
    
    init(googleCode: String, speechCode: String, languageName: String){
        self.googleCode = googleCode
        self.speechCode = speechCode
        self.languageName = languageName
    }
}
