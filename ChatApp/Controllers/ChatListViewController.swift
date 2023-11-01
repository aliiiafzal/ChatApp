//
//  ChatListViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 31/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class YourTableViewCell: UITableViewCell {
    @IBOutlet weak var profileImageView: UIImageView!
    @IBOutlet weak var userName: UILabel!
    @IBOutlet weak var isOnline: UILabel!
}

@available(iOS 13.0, *)
class ChatListViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var searchBar: UISearchBar!
    var ref = Database.database().reference()
    var ref1 = Database.database().reference()
    let user = Auth.auth().currentUser?.uid
    let userEmail = Auth.auth().currentUser?.email
    var Users = [CheckData]()
    var filteredUsers = [CheckData]()
    var search: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadUsers()
        tableView.dataSource = self
        tableView.delegate = self
        searchBar.delegate = self
    }

    func loadUsers() {
            ref.child("Users").child(Auth.auth().currentUser!.uid).child("friends").observe(.value, with: { snapshot in
                let value = snapshot.value as? NSDictionary
                //let friendName = value?["friends"] as? NSDictionary
                let check = value?.allKeys
                guard let check1 = check else
                {
                    print("Error")
                    return
                }
                
                //print("Checking is :", check1)
                
                for requests in check1
                {
                    print("My friends are :", requests)
                    self.Users = []
                    self.ref1.child("Users").child(requests as! String).observeSingleEvent(of: .value, with: { snapshot1 in
                        let value1 = snapshot1.value as? NSDictionary
                        let friendName = value1?["username"] as? String ?? ""
                        let friendImage = value1?["image"] as? String ?? ""
                        let friendEmail = value1?["email"] as? String ?? ""
                        let onlineStatus = value1?["isOnline"] as? String ?? "offline"
                        //let onlineStatus = value1?["isOnline"] as? NSDictionary
                        //let status = onlineStatus?.allValues
//                        guard let checkStatus = status else
//                        {
//                            print("Error")
//                            return
                       // }
                        let uid = requests
                        //print("CheckStatus is:", checkStatus[0])
                        
                        let obj = CheckData(username: friendName, image: friendImage, email: friendEmail, onlineStatus: onlineStatus, uid: uid as! String)
                        
                        self.Users.append(obj)
                        self.tableView.reloadData()
                    })
                    self.Users = []
                }
            }
            )
    }
}

@available(iOS 13.0, *)
extension ChatListViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if search == true
        {
            return filteredUsers.count
        }
        else
        {
            return Users.count
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath) as! YourTableViewCell
        if search == true {
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.layer.borderColor = UIColor.white.cgColor
            cell.profileImageView.layer.borderWidth = 2.0
            cell.userName.text = filteredUsers[indexPath.row].username
            //cell.profileImageView?.imageFromServerURL(urlString: filteredUsers[indexPath.row].image)
            cell.profileImageView.sd_setImage(with: URL(string: "\(filteredUsers[indexPath.row].image)"))
            cell.isOnline.text = filteredUsers[indexPath.row].onlineStatus
        }
        else
        {
            cell.profileImageView.clipsToBounds = true
            cell.profileImageView.layer.cornerRadius = cell.profileImageView.frame.size.width / 2
            cell.profileImageView.layer.borderColor = UIColor.white.cgColor
            cell.profileImageView.layer.borderWidth = 2.0
            cell.userName.text = Users[indexPath.row].username
            //cell.profileImageView?.imageFromServerURL(urlString: Users[indexPath.row].image)
            cell.isOnline.text = Users[indexPath.row].onlineStatus
            cell.profileImageView.sd_setImage(with: URL(string: "\(Users[indexPath.row].image)")) //placeholderImage: UIImage(named: "placeholder.jpeg"), options: [.continueInBackground, .progressiveLoad])
        }
        return cell
    }
    
}

@available(iOS 13.0, *)
extension ChatListViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let item = Users[indexPath.row]
        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ChatVC") as? ChatViewController else {
            return
        }
        storyboard.recieverEmail = item.email
        storyboard.recieverUid = item.uid
        self.navigationController?.pushViewController(storyboard, animated: true)
    }
}

extension UIImageView {
    
    public func imageFromServerURL(urlString: String) {
        URLSession.shared.dataTask(with: NSURL(string: urlString)! as URL, completionHandler: { (data, response, error) -> Void in
            
            if error != nil {
                print(error ?? "No Error")
                return
            }
            DispatchQueue.main.async(execute: { () -> Void in
                let image = UIImage(data: data!)
                self.image = image
            })
            
        }).resume()
    }}

@available(iOS 13.0, *)
extension ChatListViewController: UISearchBarDelegate {
    
    func searchBar(_ searchBar: UISearchBar, textDidChange searchText:String){
        
        if(searchText.isEmpty){
            filteredUsers = Users
        }else{
            filteredUsers = Users.filter{$0.username.contains(searchText)}
        }
        search = true
        tableView.reloadData()
    }
}


struct CheckData {
    let username: String
    let image: String
    let email: String
    let onlineStatus: String
    let uid: String
}

struct OnlineOfflineService {
   
    static func online(for uid: String, status: Bool, success: @escaping (Bool) -> Void) {
         let onlinesRef = Database.database().reference()
        if status == true
        {
            onlinesRef.child("Users").child(uid).updateChildValues(["isOnline": "online"])
            print("I am status true")
            print("UID :", uid)
            print("status :", status)
        }
        else if status == false {
            onlinesRef.child("Users").child(uid).updateChildValues(["isOnline": "offline"])
            //onlinesRef.child("Users").child(uid).child("isOnline").updateChildValues(["isOnline": "offline"])
            print("I am in")
            print("Status is :", status)
            print("UID is :", uid)
        }
    }
}
