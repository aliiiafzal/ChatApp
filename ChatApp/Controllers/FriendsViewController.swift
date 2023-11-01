//
//  FriendsViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 10/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class MyFriends: UITableViewCell
{
    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var friendImage: UIImageView!
}

class FriendsViewController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    var ref = Database.database().reference()
    var ref1 = Database.database().reference()
    var checkfriends = [CheckFriends]()
    let userEmail = Auth.auth().currentUser?.email
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadMyFriends()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadMyFriends() {
        ref.child("Users").child(Auth.auth().currentUser!.uid).child("friends").observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            //let friendName = value?["friends"] as? NSDictionary
            let check = value?.allKeys
            guard let check1 = check else
            {
                print("Error")
                return
            }
            
            print("Check1 is :", check1)
           
            for requests in check1 {
                print("Checking is :", requests)
                self.checkfriends = []
                self.ref1.child("Users").child(requests as! String).observeSingleEvent(of: .value, with: { snapshot1 in
                    let value1 = snapshot1.value as? NSDictionary
                    let friendName = value1?["username"] as? String ?? ""
                    let friendImage = value1?["image"] as? String ?? ""
                    let friendEmail = value1?["email"] as? String ?? ""
                    let uid = requests
                    //print("UID od friend is :", requests)
                    
                    let obj = CheckFriends(friendName: friendName, friendImage: friendImage, friendEmail: friendEmail, uid: uid as! String)
                        self.checkfriends.append(obj)
                        self.tableView.reloadData()
                })
                self.checkfriends = []
            }
        })
    }
}

extension FriendsViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return checkfriends.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = checkfriends[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "MyFriendsCell", for: indexPath) as! MyFriends
        cell.friendImage.clipsToBounds = true
        cell.friendImage.layer.cornerRadius = cell.friendImage.frame.size.width / 2
        cell.friendImage.layer.borderColor = UIColor.white.cgColor
        cell.friendImage.layer.borderWidth = 2.0
        cell.nameLabel.text = list.friendName
        //cell.friendImage?.imageFromServerURL(urlString: list.friendImage)
        cell.friendImage.sd_setImage(with: URL(string: "\(list.friendImage)"))
        return cell
    }
}

extension FriendsViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = checkfriends[indexPath.row]
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatViewController else {
            return
        }
        storyboard.recieverEmail = item.friendEmail
        storyboard.recieverUid = item.uid
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
}


struct CheckFriends {
    let friendName: String
    let friendImage: String
    let friendEmail: String
    let uid: String
}
