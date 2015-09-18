//
//  ViewController.swift
//  iFlyChatExampleSwiftChatView
//
//  Created by Prateek Grover on 09/09/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

import UIKit

class ViewController: UIViewController {
    
    
    var appData:ApplicationData!
    
    
    override func viewDidLoad()
    {
        appData = ApplicationData.sharedInstance
    }
    
    override func viewWillAppear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "chatConnect:",
            name: "iFlyChat.onChatConnect",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "gotSessionKey:",
            name: "iFlyChat.onGetSessionKey",
            object: nil)
    }
    
    override func viewDidDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    func chatConnect(notification:NSNotification)
    {
        var dict:NSDictionary = notification.object! as! NSDictionary
        appData.loggedUser = dict.objectForKey("iFlyChatCurrentUser") as! iFlyChatUser
    }
    
    func gotSessionKey(notification:NSNotification)
    {
        appData.sessionKey = notification.object! as! String
    }
    
    @IBAction func send()
    {
        let cvc: ChatViewController = self.storyboard?.instantiateViewControllerWithIdentifier("ChatViewController") as! ChatViewController

        self.navigationController?.pushViewController(cvc, animated: true)
    }

}
