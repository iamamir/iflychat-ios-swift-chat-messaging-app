//
//  ChatViewController.m
//  test
//
//  Created by Prateek Grover on 06/04/15.
//  Copyright (c) 2015 Prateek Grover. All rights reserved.
//

#import "ChatViewController.h"
#import "ChatTableViewCell.h"
#import "iFlyChatLibrary/iFlyChatLibrary.h"
#define TimeStamp [NSString stringWithFormat:@"%f",[[NSDate date] timeIntervalSince1970] * 1000]


@interface ChatViewController ()

@property (nonatomic,strong) NSMutableArray *messages;
@property (nonatomic,strong) ChatTableViewCell *chatCell;
@property (nonatomic,strong) iFlyChatUser *loggedUser;


@end

@implementation ChatViewController
{
    iFlyChatUserSession *session;
    iFlyChatConfig *config;
    iFlyChatUserAuthService *authService;
    iFlyChatService *service;
    
    CGSize keyboardSize;
    CGRect originalTable;
    CGRect originalContentView;
}

@synthesize chatTable;
@synthesize sendButton;
@synthesize messageText;
@synthesize userImage;
@synthesize chatCell;
@synthesize loggedUser;
@synthesize messages;


-(void) viewDidLoad
{
    self.navigationItem.title = @"Public Chatroom";
    self.userImage.image = [UIImage imageNamed:@"defaultRoom.png"];
    
    self.messages = [[NSMutableArray alloc] init];
    
    UINib *nib = [UINib nibWithNibName:@"ChatSendCell" bundle:nil];
    
    [[self chatTable] registerNib:nib forCellReuseIdentifier:@"chatSend"];
    
    nib = [UINib nibWithNibName:@"ChatReceiveCell" bundle:nil];
    
    [[self chatTable] registerNib:nib forCellReuseIdentifier:@"chatReceive"];

    [[self chatTable] setSeparatorStyle:UITableViewCellSeparatorStyleNone];
    
    UITapGestureRecognizer *gestureRecognizer = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(dismissKeyboard)];
    
    [self.chatTable addGestureRecognizer:gestureRecognizer];
    
    session = [[iFlyChatUserSession alloc] initIFlyChatUserSessionwithUserName:@"prateek" userPassword:@"prateek" userSessionKey:@""];
    
    config = [[iFlyChatConfig alloc] initIFlyChatConfigwithServerHost:@"iflychatdev.com" authUrl:@"http://web.iflychatdev.com/websites/d7/?q=drupalchat/mobile-auth" userSession:session];
    
    [config setAutoReconnect:YES];
    
    authService = [[iFlyChatUserAuthService alloc] initIFlyChatUserAuthServiceWithConfig:config userSession:session];
    
    service = [[iFlyChatService alloc] initIFlyChatServicewithConfig:config session:session userAuthService:authService];
    
    [service connectChat];
}

-(void) viewWillAppear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatConnect:) name:@"iFlyChat.onChatConnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(chatDisconnect) name:@"iFlyChat.onChatDisconnect" object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(messageFromRoom:) name:@"iFlyChat.onMessagefromRoom" object:nil];
    
    [self registerForKeyboardNotifications];
    
}

-(void) viewDidDisappear:(BOOL)animated
{
    [[NSNotificationCenter defaultCenter] removeObserver:self];
}

- (void) dismissKeyboard
{
    [self.messageText resignFirstResponder];
}

-(void) chatConnect:(NSNotification *)notification
{
    NSDictionary *dict = [notification object];
    loggedUser = [dict objectForKey:@"iFlyChatCurrentUser"];
}

-(void) chatDisconnect
{
    
}

-(void) messageFromRoom:(NSNotification *)notification
{
    
    [self.chatTable beginUpdates];
    
    NSIndexPath *row1 = [NSIndexPath indexPathForRow:[self.messages count] inSection:0];
    
    iFlyChatMessage *msg = [notification object];
    
    [self.messages insertObject:msg atIndex:self.messages.count];
    
    [self.chatTable insertRowsAtIndexPaths:[NSArray arrayWithObjects:row1, nil] withRowAnimation:UITableViewRowAnimationBottom];
    
    [self.chatTable endUpdates];
    
    if([self.chatTable numberOfRowsInSection:0]!=0)
    {
        NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
        [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
    }

}


- (IBAction)send
{
    
    
    iFlyChatMessage *sendMessage = [[iFlyChatMessage alloc] initIFlyChatMessageObjectwithMessage:self.messageText.text fromName:loggedUser.getName toName:@"Public Chatroom" fromId:loggedUser.getId toId:@"0" message_id:@"" color:@"" fromProfileUrl:@"" fromAvatarUrl:@"" fromRole:@"" time:@""];
    

    [self.messageText setText:@""];
    
    
    [service sendMessagetoRoom:sendMessage];
}


#pragma mark - UITableViewDatasource methods

- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView
{
    return 1;
}

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section
{
    return [self.messages count];
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    
    
    
    CGSize Messagesize;
    
    iFlyChatMessage *message = [self.messages objectAtIndex:indexPath.row];
    
    if([loggedUser.getId isEqualToString:message.getFromId])
    {
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatSend"];
        
        if (chatCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatSendCell" owner:self options:nil];
            chatCell = [nib objectAtIndex:0];
        }
        
        [chatCell.chatMessageLabel setNumberOfLines:0];
        [chatCell.chatNameLabel setNumberOfLines:0];
        [chatCell.chatTimeLabel setNumberOfLines:0];
        
        
        chatCell.chatMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        chatCell.chatNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        chatCell.chatTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        chatCell.chatMessageLabel.text = message.getMessage;
        
        chatCell.chatNameLabel.text = message.getFromName;
        
        /*
         *  epoch time to nsdate
         */
        
        // Convert NSString to NSTimeInterval
        NSTimeInterval seconds = [message.getTime doubleValue];
        
        // (Step 1) Create NSDate object
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        
        NSLog (@"Epoch time %@ equates to UTC %@", message.getTime, epochNSDate);
        
        // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        
        NSLog (@"Epoch time %@ equates to %@", message.getTime, [dateFormatter stringFromDate:epochNSDate]);
        
        // (Just for interest) Display your current time zone
        NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
        
        NSLog (@"(Your local time zone is: %@)", currentTimeZone);
        
        
        chatCell.chatTimeLabel.text = [dateFormatter stringFromDate:epochNSDate];
        
        chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser.png"];
        
        chatCell.authorType = STBubbleTableViewCellAuthorTypeSelf;
        
    }
    else
    {
        chatCell = (ChatTableViewCell *)[tableView dequeueReusableCellWithIdentifier:@"chatReceive"];
        
        if (chatCell == nil)
        {
            NSArray *nib = [[NSBundle mainBundle] loadNibNamed:@"ChatReceiveCell" owner:self options:nil];
            chatCell = [nib objectAtIndex:0];
        }
        
        [chatCell.chatMessageLabel setNumberOfLines:0];
        [chatCell.chatNameLabel setNumberOfLines:0];
        [chatCell.chatTimeLabel setNumberOfLines:0];
        
        chatCell.chatMessageLabel.lineBreakMode = NSLineBreakByWordWrapping;
        chatCell.chatNameLabel.lineBreakMode = NSLineBreakByWordWrapping;
        chatCell.chatTimeLabel.lineBreakMode = NSLineBreakByWordWrapping;
        
        chatCell.chatMessageLabel.text = message.getMessage;
        chatCell.chatNameLabel.text = message.getFromName;
        
        /*
         *  epoch time to nsdate
         */
        
        // Convert NSString to NSTimeInterval
        NSTimeInterval seconds = [message.getTime doubleValue];
        
        // (Step 1) Create NSDate object
        NSDate *epochNSDate = [[NSDate alloc] initWithTimeIntervalSince1970:seconds];
        
        NSLog (@"Epoch time %@ equates to UTC %@", message.getTime, epochNSDate);
        
        // (Step 2) Use NSDateFormatter to display epochNSDate in local time zone
        
        NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
        
        //[dateFormatter setDateFormat:@"yyyy-MM-dd HH:mm:ss zzz"];
        [dateFormatter setDateFormat:@"dd/MM HH:mm"];
        
        NSLog (@"Epoch time %@ equates to %@", message.getTime, [dateFormatter stringFromDate:epochNSDate]);
        
        // (Just for interest) Display your current time zone
        NSString *currentTimeZone = [[dateFormatter timeZone] abbreviation];
       
        NSLog (@"(Your local time zone is: %@)", currentTimeZone);
        
        
        chatCell.chatTimeLabel.text = [dateFormatter stringFromDate:epochNSDate];
        
        if([message.getToId rangeOfString:@"c-"].location != NSNotFound)
        {
            chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultUser.png"];
        }
        else
        {
            chatCell.chatUserImage.image = [UIImage imageNamed:@"defaultRoom.png"];
        }
        
        chatCell.authorType = STBubbleTableViewCellAuthorTypeOther;
        
    }
    
    Messagesize = [chatCell.chatMessageLabel.text boundingRectWithSize:CGSizeMake(chatCell.chatMessageLabel.frame.size.width, CGFLOAT_MAX)
                                                               options:NSStringDrawingUsesLineFragmentOrigin
                                                            attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:13]}
                                                               context:nil].size;
    
    [chatCell.chatMessageLabel setFont:[UIFont fontWithName:@"Arial" size:16.0f]];
    [chatCell.chatNameLabel setFont:[UIFont fontWithName:@"Arial" size:13.0f]];
    
    [chatCell.chatTimeLabel setFont:[UIFont fontWithName:@"Arial" size:9.0f]];
    
    
    return chatCell;
}


- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    iFlyChatMessage *message = [self.messages objectAtIndex:indexPath.row];
    
    CGSize size;
    
    CGSize Namesize;
    CGSize Timesize;
    CGSize Messagesize;
    
    Messagesize = [message.getMessage boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                   options:NSStringDrawingUsesLineFragmentOrigin
                                                attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:16]}
                                                   context:nil].size;
    Namesize = [message.getFromName boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                                 options:NSStringDrawingUsesLineFragmentOrigin
                                              attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:13]}
                                                 context:nil].size;
    Timesize = [message.getTime boundingRectWithSize:CGSizeMake(220.0f, CGFLOAT_MAX)
                                             options:NSStringDrawingUsesLineFragmentOrigin
                                          attributes:@{NSFontAttributeName:[UIFont fontWithName:@"Arial" size:14]}
                                             context:nil].size;
    
    
    size.width = fmaxf(fmaxf(Messagesize.width, Namesize.width),Timesize.width);
    
    if(size.width<40.f)
    {
        size.width=40.0f;
    }
    size.height = Messagesize.height + Namesize.height + Timesize.height + 56.0f;
    
    
    return size.height;
}



- (void)keyboardWasShown:(NSNotification *)notification {
    
    NSDictionary* info = [notification userInfo];
    
    keyboardSize = [[info objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue].size;
    
    CGPoint contentViewOrigin = self.contentView.frame.origin;
    
    CGRect visibleRect = self.view.frame;
    
    visibleRect.size.height -= keyboardSize.height;
    BOOL up = CGRectContainsPoint(visibleRect, contentViewOrigin);
    
    if (!up){
        
        originalContentView = self.contentView.frame;
        originalTable = self.chatTable.frame;
        
        self.chatTable.frame = CGRectMake(self.chatTable.frame.origin.x,self.chatTable.frame.origin.y,self.chatTable.frame.size.width,280.0f);
       
        //uncomment this
        self.contentView.frame = CGRectOffset(self.contentView.frame, 0, 0 - keyboardSize.height);
        
        if([self.chatTable numberOfRowsInSection:0]!=0)
        {
            NSIndexPath* ip = [NSIndexPath indexPathForRow:[self.chatTable numberOfRowsInSection:0]-1 inSection:0];
            [self.chatTable scrollToRowAtIndexPath:ip atScrollPosition:UITableViewScrollPositionBottom animated:UITableViewRowAnimationLeft];
        }
        
        
    }
    
}

- (void)keyboardWillBeHidden:(NSNotification *)notification
{
    self.contentView.frame = originalContentView;
    self.chatTable.frame = originalTable;
}

- (void)registerForKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidShowNotification
                                               object:nil];
    
    [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWillBeHidden:)
                                                 name:UIKeyboardWillHideNotification
                                               object:nil];
    
   /* [[NSNotificationCenter defaultCenter] addObserver:self
                                             selector:@selector(keyboardWasShown:)
                                                 name:UIKeyboardDidChangeFrameNotification
                                               object:nil];*/
    
}

- (void)deregisterFromKeyboardNotifications {
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidHideNotification
                                                  object:nil];
    
    [[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardWillHideNotification
                                                  object:nil];
    
    /*[[NSNotificationCenter defaultCenter] removeObserver:self
                                                    name:UIKeyboardDidChangeFrameNotification
                                                  object:nil];*/
    
}

- (void)textViewDidChange:(UITextView *)textView
{
    float maxHeight = ([UIFont systemFontOfSize:14].lineHeight)*3;
    
    CGRect frame = self.messageText.frame;
    //float newHeight = [self.messageText contentSize].height;
    float newHeight = [self.messageText.text boundingRectWithSize:CGSizeMake(self.messageText.frame.size.width, CGFLOAT_MAX)
                                                       options:NSStringDrawingUsesLineFragmentOrigin
                                                    attributes:@{NSFontAttributeName:[UIFont systemFontOfSize:14]}
                                                       context:nil].size.height;
    newHeight = MIN(newHeight, maxHeight)+16;
    
    frame.origin.y = CGRectGetMaxY(frame) - newHeight;
    frame.size.height = newHeight;
    self.messageText.frame = frame;
}



@end
