//
//  PostManager.swift
//  tellomee
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit
import Firebase
import FirebaseDatabase
import FirebaseAuth

class PostManager: NSObject {
    static let databaseRef = Database.database().reference()
    static var posts = [Post]()
    
    static func addPost(username:String, text:String, toId:String, fromId:String) {
        let p = Post(username: username, text: text, toId: toId)
        if (p.text != "") {
            let uid = Auth.auth().currentUser?.uid
            let post = ["uid":uid!,
                        "username":p.username,
                        "text":p.text,
                        "toId":p.toId]
            databaseRef.child("posts").childByAutoId().setValue(post)
        }
    }    
    
    static func fillPosts(uid:String?, toId:String, completion: @escaping(_ result:String) -> Void) {
        
        databaseRef.child("posts").queryOrdered(byChild: "uid").queryEqual(toValue: FirebaseManager.currentUser?.uid).observe(.childAdded, with:{
            snapshot in
            print(snapshot)
            if let result = snapshot.value as? [String:AnyObject]{
                let toIdCloud = result["toId"]! as! String
                if(toIdCloud == toId){
                    let p = Post(username: result["username"]! as! String, text: result["text"]! as! String, toId: result["toId"]! as! String)
                    PostManager.posts.append(p)
                }
            }
            completion("")
        })
    }
}

class Post {
    var username = ""
    var text = ""
    var toId = ""
    
    init(username:String, text:String, toId:String) {
        self.username = username
        self.text = text
        self.toId = toId
    }
}
