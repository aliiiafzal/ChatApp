//
//  FriendListViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 01/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class FriendTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var friendName: UILabel!
    @IBOutlet weak var addFriendButton: UIButton!
    @IBOutlet weak var removeFriendButton: UIButton!
}

class FriendListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var ref = Database.database().reference()
    let userEmail = Auth.auth().currentUser?.email
    var friends = [Friends]()
    var filteredFriends = [Friends]()
    var search: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
        loadFriendsList()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }
    
    func loadFriendsList() {
        ref.child("Users/").observeSingleEvent(of: .value) { snapshot in
            for case let child as DataSnapshot in snapshot.children {
                guard let dict = child.value as? [String:Any] else {
                    print("Error")
                    return
                }
                
                let friendName = dict["username"] as? String ?? ""
                let friendImage = dict["image"] as? String ?? ""
                let friendEmail = dict["email"] as? String ?? ""
                let friendUid = child.key

                let obj = Friends(friendName: friendName, friendImage: friendImage, friendEmail: friendEmail, uid: friendUid, friendRequest: "")
                
                if obj.friendEmail != self.userEmail
                {
                    self.friends.append(obj)
                }
            }
            self.tableView.reloadData()
        }
    }
    
    
    @IBAction func addFriendPressed(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point)
                else {
                    return
                }
        let cell = tableView.cellForRow(at: indexPath) as! FriendTableViewCell
        let userID = Auth.auth().currentUser?.uid
        _ = Auth.auth().currentUser?.email
        
        if sender.titleLabel?.text == "Add Friend"
        {
            ref.child("Users").child(friends[indexPath.row].uid).child("friendRequest").child(userID!).setValue(userID)
            
            cell.addFriendButton.setTitle("Cancel Request", for: .normal)
        }
        else if sender.titleLabel?.text == "Cancel Request" {
            cell.addFriendButton.setTitle("Add Friend", for: .normal)
            
            ref.child("Users").child(friends[indexPath.row].uid).child("friendRequest").child(userID!).removeValue()
        }
    }
    
    @IBAction func RemoveFriendPressed(_ sender: UIButton) {
        let point = sender.convert(CGPoint.zero, to: tableView)
        guard let indexPath = tableView.indexPathForRow(at: point)
                else {
                    return
                }
                friends.remove(at: indexPath.row)
                tableView.beginUpdates()
                tableView.deleteRows(at: [indexPath], with: .left)
                tableView.endUpdates()
    }
}

extension FriendListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search == true
        {
            return filteredFriends.count
        }
        else
        {
            return friends.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "friendCell", for: indexPath) as! FriendTableViewCell
        if search == true
        {
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.layer.borderColor = UIColor.white.cgColor
            cell.profileImageView.layer.borderWidth = 2.0
            cell.friendName.text = filteredFriends[indexPath.row].friendName
            //cell.profileImageView?.imageFromServerURL(urlString: filteredFriends[indexPath.row].friendImage)
            cell.profileImageView.sd_setImage(with: URL(string: "\(filteredFriends[indexPath.row].friendImage)"))
        }
        else
        {
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.layer.borderColor = UIColor.white.cgColor
            cell.profileImageView.layer.borderWidth = 2.0
            cell.friendName.text = friends[indexPath.row].friendName
            //cell.profileImageView?.imageFromServerURL(urlString: friends[indexPath.row].friendImage)
            cell.profileImageView.sd_setImage(with: URL(string: "\(friends[indexPath.row].friendImage)"))
        }
        return cell
    }
}

extension FriendListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        print("Data is :", friends[indexPath.row].uid)
        
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "VisitProfileVC") as? VisitProfileViewController else {
            return
        }
        storyboard.userUID = friends[indexPath.row].uid
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
}

extension FriendListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){
        
        if(searchText.isEmpty){
            filteredFriends = friends
        }else{
            filteredFriends = friends.filter{$0.friendName.contains(searchText)}
        }
        search = true
        tableView.reloadData()
    }
}

struct Friends {
    let friendName: String
    let friendImage: String
    let friendEmail: String
    let uid: String
    let friendRequest: String
}
