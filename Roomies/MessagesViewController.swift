//
//  MessagesViewController.swift
//  Roomies
//
//  Created by Nigel Koh on 5/25/16.
//  Copyright © 2016 Alec Barlow. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class MessagesViewController: JSQMessagesViewController {
    
    let incomingBubble = JSQMessagesBubbleImageFactory().incomingMessagesBubbleImageWithColor(UIColor(red: 77/255, green: 182/255, blue: 172/255, alpha: 1.0))
    let outgoingBubble = JSQMessagesBubbleImageFactory().outgoingMessagesBubbleImageWithColor(UIColor.lightGrayColor())
    var messages = [JSQMessage]()
    let prefs = NSUserDefaults.standardUserDefaults()
    
    var outgoingBubbleImageView: JSQMessagesBubbleImage!
    var incomingBubbleImageView: JSQMessagesBubbleImage!
    var observer: Bool = false
    
    override func viewWillAppear(animated: Bool) {
        let userName = prefs.stringForKey("userName")!
        let currentUser = prefs.stringForKey("currentUser")!
        self.senderId = currentUser
        self.senderDisplayName = userName
        checkForObserver()
        super.viewWillAppear(animated)
    }
    
    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)
        
//        // messages from someone else
//        addMessage("foo", displayName: "Nigel", text: "Hey person!")
//        // messages sent from local sender
//        addMessage(senderId, displayName: "Nigel", text: "Yo!")
//        addMessage(senderId, displayName: "Alec", text: "I like turtles!")
//        // animates the receiving of a new message on the view
        finishReceivingMessage()
    }
    
    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        if observer == true{
            NSNotificationCenter.defaultCenter().removeObserver(self)
            observer = false
        } else {
            observer = true
        }
    }
    
    func checkForObserver() {
        if observer == false {
            NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(MessagesViewController.handleMessageUpdateNotification(_:)), name: "MessageWasAddedNotification", object: nil)
        }
        observer = true
    }
    
    func handleMessageUpdateNotification(notification: NSNotification){
        getMessages()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        checkForObserver()
        title = "Messages"
        getMessages()
        setupBubbles()
        collectionView!.collectionViewLayout.incomingAvatarViewSize = CGSizeZero
        collectionView!.collectionViewLayout.outgoingAvatarViewSize = CGSizeZero

    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageData! {
        return messages[indexPath.item]
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> NSAttributedString! {
        
        let msg: JSQMessage = self.messages[indexPath.item]
        print("message details is: \(msg)")
        if (msg.senderId != prefs.stringForKey("currentUser")!) {
            return NSAttributedString(string: msg.senderDisplayName)
        }
        else {
            return NSAttributedString(string: senderDisplayName)
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAtIndexPath indexPath: NSIndexPath!) -> CGFloat {
        let data = self.collectionView(self.collectionView, messageDataForItemAtIndexPath: indexPath)
        if (self.senderDisplayName == data.senderDisplayName()) {
            return 0.0
        }
        return kJSQMessagesCollectionViewCellLabelHeightDefault
    }
    
    override func collectionView(collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return messages.count
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageBubbleImageDataSource! {
        let message = messages[indexPath.item] // 1
        if message.senderId == prefs.stringForKey("currentUser")! { // 2
            return outgoingBubbleImageView
        } else { // 3
            return incomingBubbleImageView
        }
    }
    
    override func collectionView(collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAtIndexPath indexPath: NSIndexPath!) -> JSQMessageAvatarImageDataSource! {
        return nil
    }
    
    override func collectionView(collectionView: UICollectionView,
                                 cellForItemAtIndexPath indexPath: NSIndexPath) -> UICollectionViewCell {
        let cell = super.collectionView(collectionView, cellForItemAtIndexPath: indexPath)
            as! JSQMessagesCollectionViewCell
        
        let message = messages[indexPath.item]
        
        if message.senderId == prefs.stringForKey("currentUser")! {
            cell.textView!.textColor = UIColor.whiteColor()
        } else {
            cell.textView!.textColor = UIColor.blackColor()
        }
        
        return cell
    }
    
    private func setupBubbles() {
        self.navigationController?.navigationBar.barTintColor = UIColor(red: 77.0/255.0, green: 182.0/255.0, blue: 172.0/255.0, alpha: 1.0)
        let bubbleImageFactory = JSQMessagesBubbleImageFactory()
        outgoingBubbleImageView = bubbleImageFactory.outgoingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleBlueColor())
        incomingBubbleImageView = bubbleImageFactory.incomingMessagesBubbleImageWithColor(UIColor.jsq_messageBubbleLightGrayColor())
    }
    
//    func addMessage(id: String, displayName: String, text: String) {
//        let message = JSQMessage(senderId: id, displayName: displayName, text: text)
//        messages.append(message)
//    }
    
    func getMessages(){
        self.messages = []
        let taskId =  prefs.stringForKey("currentTaskView")
        TaskModel.getSingleTask(taskId!) {
            data, response, error in
            do{
                print("getting single task")
                if let task = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
//                    print(task)
                    let newMessages = task["messages"] as! NSArray
//                    print ("Messages in message table: ")
//                    print (newMessages)
                    for message in newMessages {
                        
                        let senderId = message["_user"]!!["_id"] as! String!
                        let displayName = message["_user"]!!["name"] as! String!
                        let text = message["content"]! as! String
                        let newMessage = JSQMessage(senderId: senderId , displayName: displayName, text: text)
                        self.messages.append(newMessage)
                    }
                    dispatch_async(dispatch_get_main_queue(), {
                        self.collectionView.reloadData()
                        self.scrollToBottom()
                    })
                }
            }catch {
                print("Error")
            }
        }
    }
    
    override func didPressSendButton(button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: NSDate!) {
        var messageData = NSMutableDictionary()
        messageData["content"] = text
        messageData["_room"] =  prefs.stringForKey("currentRoom")
        messageData["_user"] = prefs.stringForKey("currentUser")
        messageData["_task"] = prefs.stringForKey("currentTaskView")
        
        MessageModel.addMessage(messageData) {
            data, response, error in
            do {
                if let jsonResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.MutableContainers) as? NSMutableDictionary {
                    dispatch_async(dispatch_get_main_queue(), {
                        print("successfully added message!")
                        let content = text
                        let room =  self.prefs.stringForKey("currentRoom")!
                        let user = self.prefs.stringForKey("currentUser")!
                        let userName = self.prefs.stringForKey("userName")!
                        let task = self.prefs.stringForKey("currentTaskView")!
                        SocketIOManager.sharedInstance.sendNewMessage(user, displayName: userName, text: text)
                        let newMessage = JSQMessage(senderId: user , displayName: userName, text: content)
                        self.messages.append(newMessage)
                        self.collectionView.reloadData()
                    })
                }
            }catch {
                print(error)
            }
            
        }
        
        
        
        JSQSystemSoundPlayer.jsq_playMessageSentSound()
        
        finishSendingMessage()
//        isTyping = false
    }
    
    func scrollToBottom() {
        let delay = 0.1 * Double(NSEC_PER_SEC)
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, Int64(delay)), dispatch_get_main_queue()) { () -> Void in
            if self.messages.count > 0 {
                let lastRowIndexPath = NSIndexPath(forRow: self.messages.count - 1, inSection: 0)
                self.collectionView.scrollToItemAtIndexPath(lastRowIndexPath, atScrollPosition: UICollectionViewScrollPosition.Bottom, animated: true)
            }
        }
    }
    
}
