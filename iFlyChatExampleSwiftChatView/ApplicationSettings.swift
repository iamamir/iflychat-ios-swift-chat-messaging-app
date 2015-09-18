//
//  ApplicationSettings.swift
//  iFlyChatExampleSwiftChatView
//
//  Created by Prateek Grover on 16/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

import UIKit

class ApplicationSettings {
    
    var sendButtonText:String!
    
    static let sharedInstance = ApplicationSettings()
    
    private init()
    {
        sendButtonText = "Send";
    }
    
    func setSendButtonText(sendText:String)
    {
        sendButtonText = sendText;
    }
    
    func getSendButtonText()->String
    {
        return sendButtonText;
    }

}
