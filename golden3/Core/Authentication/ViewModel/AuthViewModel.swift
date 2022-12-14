//
//  AuthViewModel.swift
//  golden3
//
//  Created by Everette, Nathan (Student) on 10/24/22.
//

import SwiftUI
import Firebase

class AuthViewModel: ObservableObject{
    @Published var userSession: FirebaseAuth.User?
    @Published var currentUser: User?
    @Published var recentPost: PostImage?
    
    private var tempUserSession: FirebaseAuth.User?
    
    private let service = UserService()
    private let postService = PostService()
    
    init() {
        self.userSession = Auth.auth().currentUser
        self.fetchUser()
        self.fetchPost()
        
    }
    
    // Login function
    func login(withEmail email: String, withPassword password: String) {
        Auth.auth().signIn(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to login with error \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            self.userSession = user
            print("DEBUG: Did log user in")
            
            
        }
    }
    
    // Register function
    func register(withEmail email: String, password: String, fullname: String, username: String) {
        Auth.auth().createUser(withEmail: email, password: password) { result, error in
            if let error = error {
                print("DEBUG: Failed to register with error \(error.localizedDescription)")
                return
            }
            
            guard let user = result?.user else { return }
            self.tempUserSession = user

            
            
            // Data dictionary
            let data = ["email": email,
                        "username": username.lowercased(),
                        "fullname": fullname,
                        "uid": user.uid]
            print("DEBUG: Data - \(data)")
            
            Firestore.firestore().collection("users")
                .document(user.uid)
                .setData(data) { error in
                    if let error = error {
                        print("DEBUG Registration Failed \(error.localizedDescription)")
                    }
                    print("DEBUG: Registration Successful")
                }
        }
    }
    
    // signout user
    func signOut() {
        // signs user out on device
        userSession = nil
        // signs user out on firebase
        try? Auth.auth().signOut()
    }
    
    func uploadProfileImage(_ image: UIImage) {
        
        guard let uid = tempUserSession?.uid else { return }
        
        ImageUploader.uploadProfileImageURL(image: image) { profileImageUrl in
            Firestore.firestore().collection("users")
                .document(uid)
                .updateData(["profileImageUrl": profileImageUrl]) { error in
                    if let error = error {
                        print("DEBUG: Failed to upload profileImageUrl with error \(error.localizedDescription)")
                        return
                    }
                    self.userSession = self.tempUserSession
                }
        }
    }
    
    func uploadPostImage(_ image: UIImage) {
        print("DEBUG: uploadpostimage function start")
        guard let uid = userSession?.uid else { return }
        
        service.fetchUser(withUId: uid) { User in
            self.currentUser = User
        }
        
        
        let currentDateTime = Date()
        
        ImageUploader.uploadPostImageUrl(image: image) { postImageUrl in
            Firestore.firestore().collection("posts")
                .document(uid)
                .setData(["uid" : uid,
                          "postImageUrl" : postImageUrl,
                          "date_uploaded" : currentDateTime
                         ]) { error in
                    if let error = error {
                        print("DEBUG: Failed to upload postImageUrl with error \(error.localizedDescription)")
                        return
                    }
                }
        }
    }
    
    
    
    
    
    
    func fetchUser(){
        guard let uid = self.userSession?.uid else {return}
        service.fetchUser(withUId: uid) { User in
            self.currentUser = User
        }
    }
    
    func fetchPost(){
        guard let uid = self.userSession?.uid else { return }
        postService.fetchPost(withUId: uid) { PostImage in
            self.recentPost = PostImage
        }
    }
    
//    func followUser(withUID uid: String, completion: @escaping (Error?) -> ()) {
//
//        //guard let uid = self.userSession?.uid else {return}
//        guard let currentLoggedInUserId = Auth.auth().currentUser?.uid else { return }
//
//        let values = [uid: 1]
//        Database.database().reference().child("following").child(currentLoggedInUserId).updateChildValues(values) { (err, ref) in
//            if let err = err {
//                completion(err)
//                return
//            }
//
//            let values = [currentLoggedInUserId: 1]
//            Database.database().reference().child("followers").child(uid).updateChildValues(values) { (err, ref) in
//                if let err = err {
//                    completion(err)
//                    return
//                }
//                completion(nil)
//            }
//        }
//    }
    
}
