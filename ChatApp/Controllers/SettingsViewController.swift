//
//  SettingsViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 02/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class SettingsViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    
    var ref = Database.database().reference()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUserProfile()
       imageView.clipsToBounds = true
        imageView.layer.cornerRadius = imageView.frame.size.width / 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.layer.borderWidth = 2.0
    }
    
    func loadUserProfile() {
        let userID = Auth.auth().currentUser?.uid
        ref.child("Users/").child(userID!).observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let userName = value?["username"] as? String ?? ""
            let userImage = value?["image"] as? String ?? ""
            let userEmail = value?["email"] as? String ?? ""
            let userNickName = value?["nickname"] as? String ?? ""
            let userGender = value?["gender"] as? String ?? ""
            let userDob = value?["dob"] as? String ?? ""
            let userPhoneNumber = value?["phonenumber"] as? String ?? ""
            
            //self.imageView.imageFromServerURL(urlString: userImage)
            self.imageView.sd_setImage(with: URL(string: "\(userImage)"))
            self.nameLabel.text = userName
            self.emailLabel.text = userEmail
            self.nickNameLabel.text = userNickName
            self.genderLabel.text = userGender
            self.dobLabel.text = userDob
            self.phoneNumberLabel.text = userPhoneNumber
            
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    
    @IBAction func logoutButtonPressed(_ sender: UIButton) {
        print("I am Logout")
        let firebaseAuth = Auth.auth()
        do {
            try firebaseAuth.signOut()
            navigationController?.popToRootViewController(animated: true)
        } catch let signOutError as NSError {
            print("Error signing out: %@", signOutError)
        }
    }
    
    @IBAction func editButtonPressed(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "MianToUpdate", sender: self)
    }
}
