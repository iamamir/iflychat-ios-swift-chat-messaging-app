//
//  DataClass.swift
//  iFlyChatGlobalListSwiftView
//
//  Created by iFlyLabs on 04/08/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

import UIKit

class DataClass {
    
    var appData:ApplicationData!
    var updatedUserList:Bool!
    var updatedRoomList:Bool!

    static let sharedInstance = DataClass()
    
    private init()
    {
        appData = ApplicationData.sharedInstance
        //check when the program comes here
    
        updatedUserList = false
        updatedRoomList = false
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "updateGlobalList:",
            name: "iFlyChat.onGlobalListUpdate",
            object: nil)
    }
    
    func initiFlyChatLibrary()
    {
        appData.session = iFlyChatUserSession(IFlyChatUserSessionwithUserName: "userName", userPassword: "userPassword", userSessionKey: "")
        
        appData.config = iFlyChatConfig(IFlyChatConfigwithServerHost: "serverhost.com", authUrl: "http://example.com/auth/url",isHttps: true, userSession: appData.session)
        
        appData.config.setAutoReconnect(true)
        
        appData.authService = iFlyChatUserAuthService(IFlyChatUserAuthServiceWithConfig: appData.config, userSession: appData.session)
        
        if(appData.service != nil)
        {
            if (appData.service.getChatState() as NSString).isEqualToString("closed")
            {
                appData.service.connectChat()
            }
        }
        else
        {
            appData.service = iFlyChatService(IFlyChatServicewithConfig: appData.config, session: appData.session, userAuthService: appData.authService)
            
            appData.service.connectChat()
        }
        
    }
    
    @objc func updateGlobalList(notification: NSNotification)
    {
        var updatedRoster: iFlyChatRoster = notification.object as! iFlyChatRoster
        
        appData.userList = updatedRoster.getUserList()
        updatedUserList = true
            

        appData.roomList = updatedRoster.getRoomList()
        updatedRoomList = true
            
        NSNotificationCenter.defaultCenter().postNotificationName("onUpdatedGlobalList", object: nil)
  
    }
    
    func getUpdatedUserList() -> iFlyChatOrderedDictionary
    {
        updatedUserList=false
        return appData.userList
    }
    
    func getUpdatedRoomList() -> iFlyChatOrderedDictionary
    {
        updatedUserList=false
        return appData.roomList
    }
    
    func setUpdatedUserListBool(updatedUserListBool:Bool)
    {
        self.updatedUserList = updatedUserListBool
    }
    
    func setUpdatedRoomListBool(updatedRoomListBool:Bool)
    {
        self.updatedRoomList = updatedRoomListBool
    }
    
    func sendMessageToUser(message:iFlyChatMessage)
    {
        appData.service.sendMessagetoUser(message);
    }

    
    func sendMessageToRoom(message:iFlyChatMessage)
    {
        appData.service.sendMessagetoRoom(message);
    }
    
    func disconnect()
    {
        appData.service.disconnectChat()
    }
    
    deinit
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
}
