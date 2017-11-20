//
//  ViewController.swift
//  Tellomee
//
//  Created by Michael Miller on 11/13/17.
//  Copyright © 2017 Tellomee. All rights reserved.
//

import UIKit
import JSQMessagesViewController

class ChatViewController: JSQMessagesViewController {
    
    var selectedUser:User?
    
    lazy var outgoingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.outgoingMessagesBubbleImage(with: UIColor.jsq_messageBubbleBlue())
    }()
    
    lazy var incomingBubble: JSQMessagesBubbleImage = {
        return JSQMessagesBubbleImageFactory()!.incomingMessagesBubbleImage(with: UIColor.jsq_messageBubbleLightGray())
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Start with an empty message list. It shows for a split second.
        PostManager.clearPosts()
        
        senderId = FirebaseManager.currentUser?.uid
        senderDisplayName = ""
        
        // Remove the "attachment" button
        inputToolbar.contentView.leftBarButtonItem = nil
        
        inputToolbar.contentView!.textView.returnKeyType = UIReturnKeyType.send
        
        // Remove avatars
        collectionView.collectionViewLayout.incomingAvatarViewSize = CGSize.zero
        collectionView.collectionViewLayout.outgoingAvatarViewSize = CGSize.zero
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        PostManager.fillPosts(uid: FirebaseManager.currentUser?.uid, toId:(selectedUser?.uid)!, completion: {_ in
            print("Completed filling posts")
            self.finishReceivingMessage()
        })
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageDataForItemAt indexPath: IndexPath!) -> JSQMessageData!
    {
        return PostManager.messages[indexPath.item]
    }
    
    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int
    {
        return PostManager.messages.count
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, messageBubbleImageDataForItemAt indexPath: IndexPath!) -> JSQMessageBubbleImageDataSource!
    {
        return PostManager.messages[(indexPath?.item)!].senderId == senderId ? outgoingBubble : incomingBubble
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, avatarImageDataForItemAt indexPath: IndexPath!) -> JSQMessageAvatarImageDataSource!
    {
        return nil
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, attributedTextForMessageBubbleTopLabelAt indexPath: IndexPath!) -> NSAttributedString!
    {
        return NSAttributedString()
    }
    
    override func collectionView(_ collectionView: JSQMessagesCollectionView!, layout collectionViewLayout: JSQMessagesCollectionViewFlowLayout!, heightForMessageBubbleTopLabelAt indexPath: IndexPath!) -> CGFloat
    {
        return 0
    }
    
    override func didPressSend(_ button: UIButton!, withMessageText text: String!, senderId: String!, senderDisplayName: String!, date: Date!)
    {
        PostManager.addPost(username: senderDisplayName, text: text, toId: (selectedUser?.uid)!, fromId: senderId)
        finishSendingMessage()
    }
    
    // Send the message when the user presses return
    override func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            self.didPressSend(nil, withMessageText:self.keyboardController.textView?.text , senderId:self.senderId , senderDisplayName: self.senderDisplayName, date: NSDate() as Date!)
        }
        
        return true
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}