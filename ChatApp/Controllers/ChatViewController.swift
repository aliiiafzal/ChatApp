//
//  ChatViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 28/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseFirestore
import MobileCoreServices
import FirebaseStorage
import AVFoundation
import AVKit
import FirebaseDatabase
import SDWebImage


class ChatViewController: UIViewController,UINavigationControllerDelegate, UIImagePickerControllerDelegate {
    
    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var messageTextField: UITextField!
    
    let db = Firestore.firestore()
    var messages: [Message] = []
    var recieverEmail: String = ""
	var recieverUid: String = ""
    let userEmail = Auth.auth().currentUser?.email
	
	var ref = Database.database().reference()
	let userUid = Auth.auth().currentUser?.uid
    
    var player: AVPlayer!
    var avpController = AVPlayerViewController()
	var istrue: Bool = false
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
		loadMessages()
        tableView.dataSource = self
		tableView.backgroundView = UIImageView(image: UIImage(named: "download"))
		
        tableView.register(UINib(nibName: "MessageTableViewCell", bundle: nil), forCellReuseIdentifier: "ReusableCell")
		tableView.register(UINib(nibName: "OtherMessageTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherReuseableCell")
        tableView.register(UINib(nibName: "ImageTableViewCell", bundle: nil), forCellReuseIdentifier: "ImageCell")
		tableView.register(UINib(nibName: "OtherImageTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherImageCell")
        tableView.register(UINib(nibName: "VideoTableViewCell", bundle: nil), forCellReuseIdentifier: "VideoCell")
		tableView.register(UINib(nibName: "OtherVideoTableViewCell", bundle: nil), forCellReuseIdentifier: "OtherVideoCell")
    }
    
	func loadMessages() {
		print("Called Once")
		db.collection("messages")
			.order(by: "date")
			.addSnapshotListener() { querySnapshot, error in
				
				if self.istrue == false
				{
					self.messages = []
					if let e = error {
						print("There was an issue retrieving data from firestore, \(e)")
					}
					else
					{
						if let snapshotDocument = querySnapshot?.documents {
							print("SnapShot Document :", snapshotDocument)
							for doc in snapshotDocument {
								let data = doc.data()
								if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String, let messageReciever = data["reciever"] as? String, let messageImage = data["image"] as? String, let messageVideo = data["video"] as? String, let messageType = data["type"] as? String  {
									
									let newMessage = Message(sender: messageSender, body: messageBody, reciever: messageReciever, image: messageImage, video: messageVideo, messageType: messageType)
									
									if newMessage.sender == self.userEmail && newMessage.reciever == self.recieverEmail || newMessage.sender == self.recieverEmail && newMessage.reciever == self.userEmail
									{
										self.messages.append(newMessage)
									}
								}
							}
							DispatchQueue.main.async {
								
								if self.messages.count > 0 {
									self.tableView.reloadData()
									let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
									self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
								}
								self.istrue = true
							}
						}
					}
				}
				else
				{
					print("I am Called")
					self.loading()
				}
			}
	}
	
	func loading() {
		db.collection("messages")
			.order(by: "date")
			.getDocuments() { querySnapshot, error in

				self.messages = []

				if let e = error {
					print("There was an issue retrieving data from firestore, \(e)")
				}
				else
				{
					if let snapshotDocument = querySnapshot?.documents {
						print("SnapShot Document :", snapshotDocument)
						for doc in snapshotDocument {
							let data = doc.data()
							if let messageSender = data["sender"] as? String, let messageBody = data["body"] as? String, let messageReciever = data["reciever"] as? String, let messageImage = data["image"] as? String, let messageVideo = data["video"] as? String, let messageType = data["type"] as? String  {

								let newMessage = Message(sender: messageSender, body: messageBody, reciever: messageReciever, image: messageImage, video: messageVideo, messageType: messageType)

								if newMessage.sender == self.userEmail && newMessage.reciever == self.recieverEmail || newMessage.sender == self.recieverEmail && newMessage.reciever == self.userEmail
								{
									self.messages.append(newMessage)
								}
							}
						}
						DispatchQueue.main.async {
							//self.tableView.reloadData()
							
							if self.messages.count > 0 {
								self.tableView.beginUpdates()
								self.tableView.insertRows(at: [IndexPath(row: self.messages.count - 1, section: 0)], with: .automatic)
								self.tableView.endUpdates()
								let indexPath = IndexPath(row: self.messages.count - 1, section: 0)
								self.tableView.scrollToRow(at: indexPath, at: .top, animated: true)
							}
						}
					}
				}
			}
	}
	

    
    @IBAction func messageSendButtonPressed(_ sender: UIButton) {
        if messageTextField.text != ""
        {
            if let messageBody = messageTextField.text, let messageSender = Auth.auth().currentUser?.email {
                db.collection("messages").addDocument(data: ["sender": messageSender,
                                                             "body": messageBody,
                                                             "date": Date().timeIntervalSince1970,
                                                             "reciever": recieverEmail,
                                                             "image": "",
                                                             "video": "",
                                                             "type": "message"
                                                            ]) { (error) in
                    if let e = error {
                        print("There was an issue saving data to Firestore, \(e)")
                    }
                    else
                    {
                        print("Successfully Saved Data")
                        DispatchQueue.main.async {
                            self.messageTextField.text = ""
                        }
                    }
                }
            }
        }
        else
        {
            let alert = UIAlertController(title: "Signup", message: "Please type message first", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    @IBAction func cameraButtonPressed(_ sender: UIButton) {
        let vc = UIImagePickerController()
        vc.sourceType = .photoLibrary
        vc.allowsEditing = false
        vc.delegate = self
        present(vc, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        picker.dismiss(animated: true)
		
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
        if mediaType == kUTTypeImage {
            let imageURL = (info[UIImagePickerController.InfoKey.imageURL] as? URL)!
            uploadImage(fileUrl: imageURL)
        }
        
        if let selectedVideo: URL = (info[UIImagePickerController.InfoKey.mediaURL] as? URL)
        {
            print("Selected Video :", selectedVideo)
            uploadVideo(fileUrl: selectedVideo)
        }
        picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadVideo(fileUrl: URL) {
        do {
            let fileExtension = fileUrl.pathExtension
            let fileName = "SendVideos/\(fileUrl) Video.\(fileExtension)"
            
            let storageReference = Storage.storage().reference().child(fileName)
            _ = storageReference.putFile(from: fileUrl, metadata: nil) {
                (storageMetaData, error) in
                
                
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    return
                }
                
                print("Image file: \(fileName) is uploaded! View it at Firebase console!")
                
                storageReference.downloadURL { (url, error) in
                    if let error = error  {
                        print("Error on getting download url: \(error.localizedDescription)")
                        return
                    }
                    print("Download url of \(fileName) is \(url!.absoluteString)")
                    print("Download URL is :", url!.absoluteString)
                    
                    if let messageSender = Auth.auth().currentUser?.email {
                        self.db.collection("messages").addDocument(data: ["sender": messageSender,
                                                                          "body": "",
                                                                          "date": Date().timeIntervalSince1970,
                                                                          "reciever": self.recieverEmail,
                                                                          "image": "",
                                                                          "video": url!.absoluteString,
                                                                          "type": "video"
                                                                         ]) { (error) in
                            if let e = error {
                                print("There was an issue saving data to Firestore, \(e)")
                            }
                            else
                            {
                                print("Successfully Saved Data")
								
                                DispatchQueue.main.async {
                                    self.messageTextField.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }

//	func resizeImage(image: UIImage, targetSize: CGSize) -> UIImage? {
//		let size = image.size
//
//		let widthRatio  = targetSize.width  / size.width
//		let heightRatio = targetSize.height / size.height
//
//		var newSize: CGSize
//		if(widthRatio > heightRatio) {
//			newSize = CGSize(width: size.width * heightRatio, height: size.height * heightRatio)
//		} else {
//			newSize = CGSize(width: size.width * widthRatio, height: size.height * widthRatio)
//		}
//		
//		let rect = CGRect(origin: .zero, size: newSize)
//
//		UIGraphicsBeginImageContextWithOptions(newSize, false, 1.0)
//		image.draw(in: rect)
//		let newImage = UIGraphicsGetImageFromCurrentImageContext()
//		UIGraphicsEndImageContext()
//
//		return newImage
//	}
    
    func uploadImage(fileUrl: URL) {
        do {
            let fileExtension = fileUrl.pathExtension
            let fileName = "SendImages/\(fileUrl) Image.\(fileExtension)"
			
            
            let storageReference = Storage.storage().reference().child(fileName)
            _ = storageReference.putFile(from: fileUrl, metadata: nil) {
                (storageMetaData, error) in
                                
                if let error = error {
                    print("Upload error: \(error.localizedDescription)")
                    return
                }
                
                print("Image file: \(fileName) is uploaded! View it at Firebase console!")
                
                storageReference.downloadURL { (url, error) in
                    if let error = error  {
                        print("Error on getting download url: \(error.localizedDescription)")
                        return
                    }
                    print("Download url of \(fileName) is \(url!.absoluteString)")
                    print("Download URL is :", url!.absoluteString)
                    
                    
                    if let messageSender = Auth.auth().currentUser?.email {
                        self.db.collection("messages").addDocument(data: ["sender": messageSender,
                                                                          "body": "",
                                                                          "date": Date().timeIntervalSince1970,
                                                                          "reciever": self.recieverEmail,
                                                                          "image": url!.absoluteString,
                                                                          "video": "",
                                                                          "type": "image"
                                                                         ]) { (error) in
                            if let e = error {
                                print("There was an issue saving data to Firestore, \(e)")
                            }
                            else
                            {
                                print("Successfully Saved Data")
                                DispatchQueue.main.async {
                                    self.messageTextField.text = ""
                                }
                            }
                        }
                    }
                }
            }
        }
    }
    
    
    @IBAction func videoButtonPressed(_ sender: UIButton) {
        let controller = UIImagePickerController()
        
        if UIImagePickerController.isSourceTypeAvailable(.camera) {
            controller.sourceType = .camera
            controller.mediaTypes = [kUTTypeMovie as String]
            controller.delegate = self
            present(controller, animated: true, completion: nil)
        }
        else {
            print("Camera is not available")
        }
    }
}

extension ChatViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let message = messages[indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "ReusableCell", for: indexPath) as! MessageTableViewCell
		let leftCell = tableView.dequeueReusableCell(withIdentifier: "OtherReuseableCell", for: indexPath) as! OtherMessageTableViewCell
        let imageCell = tableView.dequeueReusableCell(withIdentifier: "ImageCell", for: indexPath) as! ImageTableViewCell
		let leftImageCell = tableView.dequeueReusableCell(withIdentifier: "OtherImageCell", for: indexPath) as! OtherImageTableViewCell
        let videoCell = tableView.dequeueReusableCell(withIdentifier: "VideoCell", for: indexPath) as! VideoTableViewCell
		let leftVideoCell = tableView.dequeueReusableCell(withIdentifier: "OtherVideoCell", for: indexPath) as! OtherVideoTableViewCell
            
            if message.sender == Auth.auth().currentUser?.email
            {
                if message.messageType == "message"
                {
                    cell.label.text = message.body
                    return cell
                }
               
                else if message.messageType == "image"
                {
                    //imageCell.messageImageView?.imageFromServerURL(urlString: message.image)
					imageCell.messageImageView.sd_setImage(with: URL(string: "\(message.image)"))
					return imageCell
                }
                else
                {
                    let url = URL(string: message.video)
                    player = AVPlayer(url: url!)
                    avpController.player = player
                    avpController.view.frame.size.height = videoCell.videoView.frame.size.height
                    avpController.view.frame.size.width = videoCell.videoView.frame.size.width
                    videoCell.videoView.addSubview(avpController.view)
                }
                return videoCell
        }
        else
        {
            if message.messageType == "message"
            {
                leftCell.label.text = message.body
                return leftCell
            }
            else if message.messageType == "image"
            {
				//leftImageCell.messageImageView?.imageFromServerURL(urlString: message.image)
				leftImageCell.messageImageView.sd_setImage(with: URL(string: "\(message.image)"))
				return leftImageCell
            }
            else
            {
				let url = URL(string: message.video)
				player = AVPlayer(url: url!)
				avpController.player = player
				avpController.view.frame.size.height = leftVideoCell.videoView.frame.size.height
				avpController.view.frame.size.width = leftVideoCell.videoView.frame.size.width
				leftVideoCell.videoView.addSubview(avpController.view)
            }
            return leftVideoCell
			
        }
    }
}
