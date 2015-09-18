//
//  ApplicationData.swift
//  iFlyChatExampleSwiftChatView
//
//  Created by iFlyLabs on 16/09/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

import UIKit

@objc class ApplicationData {
    
    var config:iFlyChatConfig!
    var session:iFlyChatUserSession!
    var authService:iFlyChatUserAuthService!
    var service:iFlyChatService!
    var loggedUser:iFlyChatUser!
    var sessionKey:String!
    var userList:iFlyChatOrderedDictionary!
    var roomList:iFlyChatOrderedDictionary!
    var userMessages:NSMutableDictionary!
    var roomMessages:NSMutableDictionary!
    
    static let sharedInstance = ApplicationData()
}
