//
//  FriendRequestViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 09/11/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase
import SDWebImage

class RequsetTableViewCell : UITableViewCell {
    
    @IBOutlet weak var requestImageView: UIImageView!
    @IBOutlet weak var requestNameLabel: UILabel!
}

class FriendRequestViewController: UIViewController {
    
    @IBOutlet weak var tableView: UITableView!
    var ref = Database.database().reference()
    var ref1 = Database.database().reference()
    let userEmail = Auth.auth().currentUser?.email
    var requests = [Requests]()
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadRequestList()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    func loadRequestList() {
        ref.child("Users/").child(Auth.auth().currentUser!.uid).child("friendRequest").observe(.childAdded) { snapshot, String in
            
            //print("Snapshot is :", snapshot.value)
            let snapshotValue = snapshot.value!
            print("Snapshot value is :", snapshotValue)
            
            self.ref1.child("Users").child(snapshotValue as! String).observeSingleEvent(of: .value, with: { snapshot in
              let value = snapshot.value as? NSDictionary
                let friendName = value?["username"] as? String ?? ""
                let friendImage = value?["image"] as? String ?? ""
                let friendEmail = value?["email"] as? String ?? ""
                let friendUid = snapshotValue

                let obj = Requests(friendName: friendName, friendImage: friendImage, friendEmail: friendEmail, uid: friendUid as! String)
                if obj.friendEmail != self.userEmail
                {
                    self.requests.append(obj)
                }
            self.tableView.reloadData()
            }) { error in
              print(error.localizedDescription)
            }
        
                let alert = UIAlertController(title: "Friend Request", message: "You have a Friend Request", preferredStyle: UIAlertController.Style.alert)
                                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                                self.present(alert, animated: true, completion: nil)
            }
        }
        
        
        @IBAction func accceptFriendRequestPressed(_ sender: UIButton) {
            let point = sender.convert(CGPoint.zero, to: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point)
                    else {
                        return
                    }
            
            ref.child("Users").child(requests[indexPath.row].uid).child("friends").child(userID!).setValue(userID)
            ref.child("Users").child(userID!).child("friendRequest").child(requests[indexPath.row].uid).removeValue()
            ref.child("Users").child(userID!).child("friends").child(requests[indexPath.row].uid).setValue( requests[indexPath.row].uid)
            
            requests.remove(at: indexPath.row)
            tableView.beginUpdates()
            tableView.deleteRows(at: [indexPath], with: .left)
            tableView.endUpdates()
        }
        
        @IBAction func declineFriendRequestPressed(_ sender: UIButton) {
            let point = sender.convert(CGPoint.zero, to: tableView)
            guard let indexPath = tableView.indexPathForRow(at: point)
                    else {
                        return
                    }
                    requests.remove(at: indexPath.row)
                    tableView.beginUpdates()
                    tableView.deleteRows(at: [indexPath], with: .left)
                    tableView.endUpdates()
        }
    }

extension FriendRequestViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return requests.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let list = requests[indexPath.row]
        let cell = tableView.dequeueReusableCell(withIdentifier: "requestCell", for: indexPath) as! RequsetTableViewCell
        cell.requestImageView.clipsToBounds = true
        cell.requestImageView.layer.cornerRadius = cell.requestImageView.frame.size.width / 2
        cell.requestImageView.layer.borderColor = UIColor.white.cgColor
        cell.requestImageView.layer.borderWidth = 2.0
        cell.requestNameLabel.text = list.friendName
        //cell.requestImageView?.imageFromServerURL(urlString: list.friendImage)
        cell.requestImageView.sd_setImage(with: URL(string: "\(list.friendImage)"))
        return cell
    }
}

extension FriendRequestViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
}

struct Requests {
    let friendName: String
    let friendImage: String
    let friendEmail: String
    let uid: String
}
