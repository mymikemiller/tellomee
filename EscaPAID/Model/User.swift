//
//  User.swift
//  EscaPAID
//
//  Created by Michael Miller on 11/11/17.
//  Copyright © 2017 Michael Miller. All rights reserved.
//

import UIKit

class User: NSObject {
    var uid:String
    var city:String
    var email:String
    var firstName:String
    var lastName:String
    var profileImageUrl:String
    var aboutMe:String
    var stripeCuratorId:String? // nil when the user is not a connected curator
    var stripeCustomerId:String? // nil when the user has not yet been given a stripe customer ID, which happens right when the user is created so this shouldn't be nil for long
    
    init(uid:String, city:String, email:String, firstName:String, lastName:String, aboutMe:String, profileImageUrl:String) {
        self.uid = uid
        self.city = city
        self.firstName = firstName
        self.lastName = lastName
        self.email = email
        self.aboutMe = aboutMe
        self.profileImageUrl = profileImageUrl
    }
    
    var fullName:String {
        return self.firstName + (self.lastName.isEmpty ? "" : " " + self.lastName)
    }
    
    func getProfileImage() -> UIImage {
        if let url = NSURL(string: profileImageUrl) {
            if let data = NSData(contentsOf: url as URL) {
                return UIImage(data: data as Data)!
            }
        }
        return #imageLiteral(resourceName: "ic_account_circle")
    }
    
    func updateProfileImageUrl(_ url:String) {
        
        profileImageUrl = url
        
        // Immediately save it to the database
        FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues(["profileImageUrl":url])
    }
    
    func addFCMToken(token: String) {
        FirebaseManager.databaseRef.child("users").child(self.uid).child("notificationTokens").child(token).setValue(true)
    }
    
    // This function is static so the we don't need to create a user just to remove its FCM token
    static func removeFCMToken(uid: String, token: String) {
         FirebaseManager.databaseRef.child("users").child(uid).child("notificationTokens").child(token).removeValue()
    }
    
    func update() {
        FirebaseManager.databaseRef.child("users").child(self.uid).updateChildValues([
            "city":city,
            "firstName":firstName,
            "lastName":lastName,
            "aboutMe":aboutMe,
            "profileImageUrl":profileImageUrl,
            "stripeCuratorId":stripeCuratorId ?? NSNull(), // null out the stripeCuratorId if the user doesn't have one
            "stripeCustomerId":stripeCustomerId ?? NSNull()]) // null out the stripeCustomerId if the user doesn't have one
    }
}
