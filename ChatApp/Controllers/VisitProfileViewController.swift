//
//  VisitProfileViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 09/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class VisitProfileViewController: UIViewController {
    
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var genderLabel: UILabel!
    @IBOutlet weak var dobLabel: UILabel!
    @IBOutlet weak var phoneNumberLabel: UILabel!
    @IBOutlet weak var emailLabel: UILabel!
    @IBOutlet weak var nickNameLabel: UILabel!
    
    
    var userUID: String =  ""
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
        ref.child("Users/").child(userUID).observe(.value, with: { snapshot in
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
}
