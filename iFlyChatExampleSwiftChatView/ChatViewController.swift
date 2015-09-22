//
//  ChatViewController.swift
//  iFlyChatExampleSwiftChatView
//
//  Created by iFlyLabs on 05/08/15.
//  Copyright (c) 2015 iFlyLabs. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController, UITableViewDataSource, UITableViewDelegate, UITextViewDelegate{
    
    let TimeStamp = String.localizedStringWithFormat("%f", NSDate().timeIntervalSince1970 * 1000)
    
    @IBOutlet weak var chatTable: UITableView!
    @IBOutlet weak var userImage: UIImageView!
    
    @IBOutlet weak var messageText: UITextView!
    
    @IBOutlet weak var contentView: ContentView!
    @IBOutlet weak var sendButton: UIButton!
    
    @IBOutlet weak var chatStatusView: UIView!
    @IBOutlet weak var chatStatusHeight: NSLayoutConstraint!
    
    @IBOutlet weak var contentViewBottomConstraint: NSLayoutConstraint!
    @IBOutlet weak var contentViewHeightConstraint: NSLayoutConstraint!
    @IBOutlet weak var messageTextHeightConstraint: NSLayoutConstraint!

    @IBOutlet weak var chatStatus: UILabel!
    @IBOutlet weak var userImageHeight: NSLayoutConstraint!
    
    @IBOutlet weak var userImageWidth: NSLayoutConstraint!
    
    var chatCell:ChatTableViewCell!
    var messageUser:iFlyChatUser!
    
    var handler:ContentView!
    
    var dtclass: DataClass!
    var fetchImage: dispatch_queue_t!
    var userImageCache: NSCache!
    
    var appData:ApplicationData!
    var appSettings:ApplicationSettings!
    var chatCellSettings:ChatCellSettings!
    
    var imageAlreadySetFlag:Bool!
    
    var USERID: NSString!
    var ROOMID: NSString!
    var USERNAME: NSString!
    var ROOMNAME: NSString!
    
    var currentMessages:iFlyChatOrderedDictionary!
    
    override func viewDidLoad()
    {
        //Getting singleton instances of the required classes
        dtclass = DataClass.sharedInstance
        appData = ApplicationData.sharedInstance
        appSettings = ApplicationSettings.sharedInstance
        chatCellSettings = ChatCellSettings.getInstance()
        
        /**
        *  Set settings for Application
        */
        
        //chatCellSettings.setSenderBubbleColor(UIColor(red: 0, green: (122.0/255.0), blue: 1.0, alpha: 1.0))
        //chatCellSettings.setSenderBubbleColor(UIColor(red: (223.0/255.0), green: (222.0/255.0), blue: (229.0/255.0), alpha: 1.0))
        //chatCellSettings.setSenderBubbleNameTextColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        //chatCellSettings.setReceiverBubbleNameTextColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))
        //chatCellSettings.setSenderBubbleMessageTextColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        //chatCellSettings.setReceiverBubbleMessageTextColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))
        //chatCellSettings.setSenderBubbleTimeTextColor(UIColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0))
        //chatCellSettings.setReceiverBubbleTimeTextColor(UIColor(red: 0, green: 0, blue: 0, alpha: 1.0))
        
        chatCellSettings.setSenderBubbleColorHex("007AFF")
        chatCellSettings.setReceiverBubbleColorHex("DFDEE5")
        chatCellSettings.setSenderBubbleNameTextColorHex("FFFFFF")
        chatCellSettings.setReceiverBubbleNameTextColorHex("000000")
        chatCellSettings.setSenderBubbleMessageTextColorHex("FFFFFF")
        chatCellSettings.setReceiverBubbleMessageTextColorHex("000000")
        chatCellSettings.setSenderBubbleTimeTextColorHex("FFFFFF")
        chatCellSettings.setReceiverBubbleTimeTextColorHex("000000")
        
        chatCellSettings.setSenderBubbleFontWithSizeForName(UIFont.boldSystemFontOfSize(11))
        chatCellSettings.setReceiverBubbleFontWithSizeForName(UIFont.boldSystemFontOfSize(11))
        chatCellSettings.setSenderBubbleFontWithSizeForMessage(UIFont.systemFontOfSize(14))
        chatCellSettings.setReceiverBubbleFontWithSizeForMessage(UIFont.systemFontOfSize(14))
        chatCellSettings.setSenderBubbleFontWithSizeForTime(UIFont.systemFontOfSize(11))
        chatCellSettings.setReceiverBubbleFontWithSizeForTime(UIFont.systemFontOfSize(11))
        
        chatCellSettings.senderBubbleTailRequired(true)
        chatCellSettings.receiverBubbleTailRequired(true)
        
        //Setting the send button text. This is available in ApplicationSettings class
        appSettings.setSendButtonText("Send")
        
        //Initializing the NSMutableDictionaries to save messages for user and room
        appData.userMessages = NSMutableDictionary()
        appData.roomMessages = NSMutableDictionary()
        currentMessages = iFlyChatOrderedDictionary()
        
        /**
        *  Configure chat here. Keep the USERID and USERNAME empty and fill in ROOMID and ROOMNAME if you need to chat in a room and vice-versa
        */
        
        USERID = ""
        ROOMID = "0"
        USERNAME = ""
        ROOMNAME = "Public Chatroom"
        
        if(!USERID.isEqualToString(""))
        {
            self.navigationItem.title = USERNAME as String
            self.userImage.image = UIImage(named: "defaultUser")
            
            //If the message dictionary is not set for this particular room then set it otherwise assign the already set message dictionary
            if(appData.userMessages.objectForKey(USERID)==nil)
            {
                appData.userMessages.setObject(currentMessages, forKey: USERID)
            }
            else
            {
                currentMessages = appData.userMessages.objectForKey(USERID) as! iFlyChatOrderedDictionary
            }
        }
        else
        {
            self.navigationItem.title = ROOMNAME as String
            self.userImage.image = UIImage(named: "defaultRoom")
            
            //If the message dictionary is not set for this particular room then set it otherwise assign the already set message dictionary
            if(appData.roomMessages.objectForKey(ROOMID)==nil)
            {
                appData.roomMessages.setObject(currentMessages, forKey: ROOMID)
            }
            else
            {
                currentMessages = appData.roomMessages.objectForKey(ROOMID) as! iFlyChatOrderedDictionary
            }
        }
        
        //Setting the flag that checks if the image on the navigation bar is set or not
        imageAlreadySetFlag=false
        
        //Setting the send button title
        sendButton.setTitle(appSettings.getSendButtonText(), forState: UIControlState.Normal)

        sendButton.enabled = false
        
        self.messageText.delegate = self
        
        self.chatStatusView.backgroundColor = UIColor.redColor()
        self.chatStatus.text = "Not Connected"
        
        //Registering custom Chat table view cell for both sending and receiving
        self.chatTable.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: "chatSend")
        self.chatTable.registerClass(ChatTableViewCell.self, forCellReuseIdentifier: "chatReceive")
        
        self.chatTable.separatorStyle = UITableViewCellSeparatorStyle.None
        
        //Instantiating custom view that adjusts itself to keyboard show/hide
        self.handler = ContentView(textView: self.messageText, chatTextViewHeightConstraint: self.messageTextHeightConstraint, contentView: self.contentView, contentViewHeightConstraint: self.contentViewHeightConstraint, andContentViewBottomConstraint: self.contentViewBottomConstraint)
        
        //Setting the minimum and maximum number of lines for the textview vertical expansion
        self.handler.updateMinimumNumberOfLines(1, andMaximumNumberOfLine: 3)
        
        //Tap gesture on table view so that when someone taps on it, the keyboard is hidden
        let gestureRecognizer:UITapGestureRecognizer = UITapGestureRecognizer(target: self, action: "dismissKeyboard")
        
        self.chatTable.addGestureRecognizer(gestureRecognizer)
        
        fetchImage = dispatch_queue_create("fetchImage", DISPATCH_QUEUE_SERIAL);
        
        userImageCache = NSCache()
        
        self.chatStatusView.backgroundColor = UIColor.yellowColor()
        self.chatStatus.text = "Authenticating and retrieving session key..."
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
            selector: "chatDisconnect",
            name: "iFlyChat.onChatDisconnect",
            object: nil)

        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "messageFromRoom:",
            name: "iFlyChat.onMessagefromRoom",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "messageFromUser:",
            name: "iFlyChat.onMessagefromUser",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "setUserImage",
            name: "onUpdatedGlobalList",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "gotSessionKey:",
            name: "iFlyChat.onGetSessionKey",
            object: nil)
        
        NSNotificationCenter.defaultCenter().addObserver(
            self,
            selector: "detectOrientation",
            name: UIDeviceOrientationDidChangeNotification,
            object: nil)
    }
    
    func textViewDidChange(textView: UITextView)
    {
        //Resizing the textview according to the text
        self.handler.resizeTextViewWithAnimation(false)
        
        //Enable and disable send button based on whether there is any text in textview or not
        if(messageText.text.isEmpty)
        {
            sendButton.enabled = false
        }
        else
        {
            sendButton.enabled = true
        }
    }

    override func viewDidAppear(animated: Bool)
    {
        //Initialise chat only if chat state from iFlyChatLibrary is not open
        if(appData.service == nil)
        {
            dtclass.initiFlyChatLibrary()
        }
        else if(!(appData.service.getChatState() as NSString).isEqualToString("open"))
        {
            dtclass.initiFlyChatLibrary()
        }
        else
        {
            self.chatStatusView.backgroundColor = UIColor.greenColor()
            self.chatStatus.text = "Connected"
            
            UIView.animateWithDuration(0.5, animations: { () -> Void in
                self.chatStatusHeight.constant = 2
                self.chatStatusView.superview?.layoutIfNeeded()
            })
            
            self.chatStatus.text = ""
            self.setUserImage()
        }
    }
    
    
    override func viewDidDisappear(animated: Bool)
    {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewWillDisappear(animated: Bool)
    {
        //Disconnect chat when the view disappears
        dtclass.disconnect()
    }
    
    
    func dismissKeyboard()
    {
        self.messageText.resignFirstResponder()
    }
    
    func detectOrientation()
    {
        //Change the height and width of the navigation bar image according to the orientation of the device
        if(UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeLeft || UIDevice.currentDevice().orientation == UIDeviceOrientation.LandscapeRight)
        {
            if(self.userImageWidth.constant != 25)
            {
                self.userImageHeight.constant = 25;
                self.userImageWidth.constant = 25;
                self.userImage.layer.cornerRadius = 12.5;
            }
        }
        else if(UIDevice.currentDevice().orientation == UIDeviceOrientation.Portrait || UIDevice.currentDevice().orientation == UIDeviceOrientation.PortraitUpsideDown)
        {
            if(self.userImageWidth.constant != 35)
            {
                self.userImageHeight.constant = 35;
                self.userImageWidth.constant = 35;
                self.userImage.layer.cornerRadius = 17.5;
            }
        }
    }
    
    func chatConnect(notification:NSNotification)
    {
        //When the chat is connected, save the logged in user's information in a variable
        let dict:NSDictionary = notification.object! as! NSDictionary
        appData.loggedUser = dict.objectForKey("iFlyChatCurrentUser") as! iFlyChatUser
        
        self.chatStatusView.backgroundColor = UIColor.greenColor()
        self.chatStatus.text = "Connected"
        
        UIView.animateWithDuration(0.5, animations: { () -> Void in
            self.chatStatusHeight.constant = 2
            self.chatStatusView.superview?.layoutIfNeeded()
        })
        
        self.chatStatus.text = "";
    }
    
    func gotSessionKey(notification:NSNotification)
    {
        //After getting the session key, save the session key as well so that it can be used again later
        appData.sessionKey = notification.object! as! String
        self.chatStatus.text = "Connecting to iFlyChat servers..."
    }
    
    func chatDisconnect()
    {
        self.chatStatus.text = "Not connected"
        self.chatStatusHeight.constant = 49
    }
    
    func setUserImage()
    {
        //If image is not set already
        if(!imageAlreadySetFlag)
        {
            //If you are talking to a user and not a room
            if(!USERID.isEqualToString(""))
            {
                if let chatUser = appData.userList.objectForKey(USERID) as? iFlyChatUser
                {
                    //If avatar url is not empty
                    if !chatUser.getAvatarUrl().isEmpty
                    {
                        //Download and set the image
                        let url: NSURL = NSURL(string: String(format: "%@%@","http:", chatUser.getAvatarUrl()))!
                        let data = NSData(contentsOfURL: url)!
                        let img = UIImage(data: data)
                        self.userImage.image = img
                    }
                }
            }
            imageAlreadySetFlag=true
        }
    }
    
    func messageFromRoom(notification:NSNotification)
    {
        //If we are chatting in a room then go ahead
        if(!ROOMID.isEqualToString(""))
        {
            let msg:iFlyChatMessage = notification.object! as! iFlyChatMessage
            
            //If the message that is received here is sent to the room I am currently chatting in then go ahead
            if(ROOMID.isEqualToString(msg.getToId()))
            {
                //If the message sender is not me or if the message sender is myself and I have not yet updated the message in my dictionary and view then go ahead
                if(!(msg.getFromId() as NSString).isEqualToString(appData.loggedUser.getId()) || ((msg.getFromId() as NSString).isEqualToString(appData.loggedUser.getId()) && currentMessages.objectForKey(msg.getMessageId()) == nil))
                {
                    self.updateTableView(msg)
                }
            }
        }
    }
    
    
    func messageFromUser(notification:NSNotification)
    {
        //Same as rooms comments
        if(!USERID.isEqualToString(""))
        {
            let msg:iFlyChatMessage = notification.object! as! iFlyChatMessage
            
            if(USERID.isEqualToString(msg.getToId()) || USERID.isEqualToString(msg.getFromId()))
            {
                if(!(msg.getFromId() as NSString).isEqualToString(appData.loggedUser.getId()) || ((msg.getFromId() as NSString).isEqualToString(appData.loggedUser.getId()) && currentMessages.objectForKey(msg.getMessageId()) == nil))
                {
                    self.updateTableView(msg)
                }
            }
        }
    }
    
    func updateTableView(msg:iFlyChatMessage)
    {
        //Check which are the visible paths and how many messages are there. If the user is on last message then if a message is received, scroll the table view. If the user is not on the last message and a message is received then do not scroll the table view.
        let paths: NSArray = self.chatTable.indexPathsForVisibleRows!
        let lastVisibleRow: Int
        let messageLastRow: Int
        
        if(paths.count == 0)
        {
            lastVisibleRow = 0;
            messageLastRow = 0;
        }
        else
        {
            let lastVisibleRowIndexPath:NSIndexPath = paths.objectAtIndex((paths.count - 1)) as! NSIndexPath
        
            lastVisibleRow = lastVisibleRowIndexPath.row
        
            messageLastRow = currentMessages.count - 1
        }
        
        //Update the table view
        self.chatTable.beginUpdates()
        
        let row1:NSIndexPath = NSIndexPath(forRow: currentMessages.count, inSection: 0)
        
        //Insert the newly received message in the dictionary
        currentMessages.insertObject(msg, forKey: msg.getMessageId() as NSString, atIndex: currentMessages.count())
        
        self.chatTable.insertRowsAtIndexPaths([row1], withRowAnimation: UITableViewRowAnimation.Bottom)
        
        self.chatTable.endUpdates()
        
        if lastVisibleRow == messageLastRow
        {
            let ip:NSIndexPath = NSIndexPath(forRow: self.chatTable.numberOfRowsInSection(0)-1, inSection: 0)
            
            self.chatTable.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    @IBAction func send()
    {
        var sendMessage:iFlyChatMessage
        
        //Make iFlyChatMessage objects according to where/with whom the user is chatting
        if(!USERID.isEqualToString(""))
        {
            sendMessage = iFlyChatMessage(IFlyChatMessageObjectwithMessage: self.messageText.text, fromName: appData.loggedUser.getName(), toName: USERNAME as String, fromId: appData.loggedUser.getId(), toId: USERID as String, message_id: "", color: "", fromProfileUrl: "", fromAvatarUrl: "", fromRole: "", time: "", type:"user")
            
            dtclass.sendMessageToUser(sendMessage)
        }
        else
        {
            sendMessage = iFlyChatMessage(IFlyChatMessageObjectwithMessage: self.messageText.text, fromName: appData.loggedUser.getName(), toName: ROOMNAME as String, fromId: appData.loggedUser.getId(), toId: ROOMID as String, message_id: "", color: "", fromProfileUrl: "", fromAvatarUrl: "", fromRole: appData.loggedUser.getRole(), time: "", type:"room")
            
            dtclass.sendMessageToRoom(sendMessage)
        }
        
        
        self.messageText.text = ""
        
        self.textViewDidChange(self.messageText)
        
        self.chatTable.beginUpdates()
        
        let row1:NSIndexPath = NSIndexPath(forRow: currentMessages.count, inSection: 0)
        
        currentMessages.insertObject(sendMessage, forKey: sendMessage.getMessageId() as NSString, atIndex: currentMessages.count())
        
        self.chatTable.insertRowsAtIndexPaths([row1], withRowAnimation: UITableViewRowAnimation.Bottom)
        
        self.chatTable.endUpdates()
        
        //Always scroll the chat table when the user sends the message
        if self.chatTable.numberOfRowsInSection(0) != 0
        {
            let ip:NSIndexPath = NSIndexPath(forRow: self.chatTable.numberOfRowsInSection(0)-1, inSection: 0)
            
            self.chatTable.scrollToRowAtIndexPath(ip, atScrollPosition: UITableViewScrollPosition.Bottom, animated: true)
        }
    }
    
    // MARK: - Table view data source
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int
    {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int
    {
        return currentMessages.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell
    {
        let message:iFlyChatMessage = currentMessages.objectAtIndex(UInt(indexPath.row)) as! iFlyChatMessage
        
        if(appData.loggedUser.getId() == message.getFromId())
        {
            chatCell = self.chatTable.dequeueReusableCellWithIdentifier("chatSend") as? ChatTableViewCell
            
            chatCell.chatMessageLabel.text = message.getMessage()
            chatCell.chatNameLabel.text = message.getFromName()
            
            /*
            *  epoch time to nsdate
            *  Show date only when the date is not current date otherwise show only time
            */
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM"
            
            let epochMessageDateTime = (message.getTime() as NSString).doubleValue as NSTimeInterval
            
            let messageDateTime = NSDate(timeIntervalSince1970: epochMessageDateTime)
            
            let currentDateTime = NSDate()
            
            if((dateFormatter.stringFromDate(currentDateTime) as NSString).isEqualToString(dateFormatter.stringFromDate(messageDateTime)))
            {
                dateFormatter.dateFormat = "HH:mm"
            }
            else
            {
                dateFormatter.dateFormat = "dd/MM HH:mm"
            }
            
            chatCell.chatTimeLabel.text = dateFormatter.stringFromDate(messageDateTime)
            
            //Asynchronously downloading images after checking if they are available in cache
            if userImageCache.objectForKey(appData.loggedUser.getId()) == nil
            {
                if(!appData.loggedUser.getAvatarUrl().isEmpty)
                {
                    dispatch_async(fetchImage, { () -> Void in
                        
                        self.loadImagesWithURL("http:"+self.appData.loggedUser.getAvatarUrl(), indexPath: indexPath, activeTableView:tableView, userId:self.appData.loggedUser.getId())
                        
                    })
                }
                
                chatCell.chatUserImage.image = UIImage(named: "defaultUser.png")
            }
            else
            {
                chatCell.chatUserImage.image = (userImageCache.objectForKey(appData.loggedUser.getId()) as! UIImage)
            }
            
            chatCell.authorType = AuthorType.iFlyChatBubbleTableViewCellAuthorTypeSender;
        }
        else
        {
            chatCell = self.chatTable.dequeueReusableCellWithIdentifier("chatReceive") as? ChatTableViewCell
            
            chatCell.chatMessageLabel.text = message.getMessage()
            chatCell.chatNameLabel.text = message.getFromName()
            
            let dateFormatter = NSDateFormatter()
            
            dateFormatter.dateFormat = "dd/MM"
            
            let epochMessageDateTime = (message.getTime() as NSString).doubleValue as NSTimeInterval
            
            let messageDateTime = NSDate(timeIntervalSince1970: epochMessageDateTime)
            
            let currentDateTime = NSDate()
            
            if((dateFormatter.stringFromDate(currentDateTime) as NSString).isEqualToString(dateFormatter.stringFromDate(messageDateTime)))
            {
                dateFormatter.dateFormat = "HH:mm"
            }
            else
            {
                dateFormatter.dateFormat = "dd/MM HH:mm"
            }
            
            chatCell.chatTimeLabel.text = dateFormatter.stringFromDate(messageDateTime)
            
            if appData.userList.objectForKey(message.getFromId()) != nil
            {
                messageUser = appData.userList.objectForKey(message.getFromId()) as! iFlyChatUser
            
                if userImageCache.objectForKey(messageUser.getId()) == nil
                {
                    if(!messageUser.getAvatarUrl().isEmpty)
                    {
                        dispatch_async(fetchImage, { () -> Void in
                            
                            self.loadImagesWithURL("http:"+self.messageUser.getAvatarUrl(), indexPath: indexPath, activeTableView:tableView, userId:self.messageUser.getId())
                            
                        })
                    }
            
                    chatCell.chatUserImage.image = UIImage(named: "defaultUser.png")
                }
                else
                {
                    chatCell.chatUserImage.image = (userImageCache.objectForKey(messageUser.getId()) as! UIImage)
                }
            }

            chatCell.authorType = AuthorType.iFlyChatBubbleTableViewCellAuthorTypeReceiver
        }
        
        return chatCell;
    }
    
    
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat
    {
        
        let message:iFlyChatMessage = currentMessages.objectAtIndex(UInt(indexPath.row)) as! iFlyChatMessage
        
        var size:CGSize = CGSizeZero
        var Namesize:CGSize
        var Timesize:CGSize
        var Messagesize:CGSize
        
        var fontArray:NSArray = NSArray()
        
        //Get the chal cell font settings. This is to correctly find out the height of each of the cell according to the text written in those cells which change according to their fonts and sizes.
        //If you want to keep the same font sizes for both sender and receiver cells then remove this code and manually enter the font name with size in Namesize, Messagesize and Timesize.
        if((message.getFromId() as NSString).isEqualToString(appData.loggedUser.getId()))
        {
            fontArray = chatCellSettings.getSenderBubbleFontWithSize();
        }
        else
        {
            fontArray = chatCellSettings.getReceiverBubbleFontWithSize();
        }
        
        Namesize = ("Name" as NSString).boundingRectWithSize(CGSizeMake(220.0, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : fontArray[0]], context: nil).size
        
        
        
        Messagesize = (message.getMessage() as NSString).boundingRectWithSize(CGSizeMake(220.0, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName:fontArray[1]], context: nil).size
        
        
        Timesize = ("Time" as NSString).boundingRectWithSize(CGSizeMake(220.0, CGFloat.max), options: NSStringDrawingOptions.UsesLineFragmentOrigin, attributes: [NSFontAttributeName : fontArray[2]], context: nil).size
        
        
        size.height = Messagesize.height + Namesize.height + Timesize.height + 48.0
        
        
        return size.height

    }
    
    func loadImagesWithURL(imageURL:NSString,indexPath:NSIndexPath, activeTableView:UITableView, userId:NSString)
    {
        let url:NSURL = NSURL(string: imageURL as String)!
        
        let data:NSData = NSData(contentsOfURL: url)!
        
        let img:UIImage = UIImage(data: data)!
        
        //Caching the downloaded image
        userImageCache.setObject(img, forKey: userId)
        
        dispatch_async(dispatch_get_main_queue(), { () -> Void in
            
            //Setting the image in the view
            if let cell = activeTableView.cellForRowAtIndexPath(indexPath) as? ChatTableViewCell
            {
                cell.chatUserImage.image = img
            }
        })
        
        
    }
}
