//
//  profileViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 26/10/2022.
//

import UIKit
import iOSDropDown
import FirebaseAuth
import FirebaseDatabase
import MobileCoreServices
import FirebaseStorage

@available(iOS 13.4, *)
class profileViewController: UIViewController, UIImagePickerControllerDelegate & UINavigationControllerDelegate {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectGenderTextField: DropDown!
    //@IBOutlet weak var countryCodeTextField: DropDown!
    @IBOutlet weak var selectImage: UIImageView!
    @IBOutlet weak var activtyIndicator: UIActivityIndicatorView!
    var datePicker: UIDatePicker = UIDatePicker()
    var name: String =  ""
    var email : String = ""
    var password : String = ""
    //var ref: DatabaseReference!
    var ref = Database.database().reference()
    let user = Auth.auth().currentUser
    var imageURL: URL!
    var downloadUrl: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setIconAndColourInTextField()
        selectGender()
        //selectCountryCode()
        
        let tapGestureRecognizer = UITapGestureRecognizer(target: self, action: #selector(imageTapped(tapGestureRecognizer:)))
           selectImage.isUserInteractionEnabled = true
           selectImage.addGestureRecognizer(tapGestureRecognizer)
    }
    
    func setIconAndColourInTextField() {
        nameTextField.layer.cornerRadius = 15.0
        nameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: nameTextField.frame.height))
        nameTextField.leftViewMode = .always
        nicknameTextField.layer.cornerRadius = 15.0
        nicknameTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: nicknameTextField.frame.height))
        nicknameTextField.leftViewMode = .always
        dobTextField.layer.cornerRadius = 15.0
        dobTextField.tintColor = UIColor.lightGray
        dobTextField.setIconOfDob(UIImage(named: "calendar")!)
        dobTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dobTextField.frame.height))
        dobTextField.leftViewMode = .always
        phoneNumberTextField.layer.cornerRadius = 15.0
        phoneNumberTextField.tintColor = UIColor.lightGray
        phoneNumberTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dobTextField.frame.height))
        phoneNumberTextField.leftViewMode = .always
        selectGenderTextField.layer.cornerRadius = 15.0
        selectGenderTextField.tintColor = UIColor.lightGray
        selectGenderTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dobTextField.frame.height))
        selectGenderTextField.leftViewMode = .always
        selectImage.clipsToBounds = true
        selectImage.layer.cornerRadius = selectImage.frame.size.width / 2
        selectImage.layer.borderColor = UIColor.white.cgColor
        selectImage.layer.borderWidth = 2.0
        activtyIndicator.style = .large
        activtyIndicator.color = .black
        activtyIndicator.isHidden = true
        activtyIndicator.hidesWhenStopped = true
    }
    
    func selectGender() {
                //selectGenderTextField.optionArray = ["🙊 Male", "👩🏻‍🦳 Female", "🥞 Other"]
                selectGenderTextField.optionArray = ["Male", "Female", "Other"]
                selectGenderTextField.selectedRowColor = .lightGray
                selectGenderTextField.arrowColor = UIColor.lightGray
                selectGenderTextField.isSearchEnable = false
                selectGenderTextField.didSelect{(selectedText , index ,id) in
                    self.selectGenderTextField.text = selectedText
                }
                selectGenderTextField.resignFirstResponder()
    }
    
//    func selectCountryCode() {
//        var countries: [String] = []
//        let constants = Constants()
//        for (_, value) in constants.flags {
//            countries.append(value)
//        }
//
//        countryCodeTextField.optionArray = countries
//        countryCodeTextField.selectedRowColor = .lightGray
//        countryCodeTextField.arrowColor = UIColor.lightGray
//        countryCodeTextField.isSearchEnable = false
//        countryCodeTextField.didSelect{(selectedText , index ,id) in
//        //print("Selected String: \(selectedText) \n index: \(index)")
//            self.countryCodeTextField.text = selectedText
//        }
//        countryCodeTextField.resignFirstResponder()
//    }
    
    @IBAction func dobTextFieldPressed(_ sender: UITextField) {
        datePicker.datePickerMode = .date
        datePicker.preferredDatePickerStyle = .wheels
        datePicker.backgroundColor = .white
        
        let toolbar = UIToolbar();
        toolbar.sizeToFit()
        let doneButton = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(donedatePicker));
        let spaceButton = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.flexibleSpace, target: nil, action: nil)
        let cancelButton = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(cancelDatePicker));
        toolbar.setItems([doneButton,spaceButton,cancelButton], animated: true)
        dobTextField.inputAccessoryView = toolbar
        dobTextField.inputView = datePicker
    }
    
    @objc func donedatePicker(){
        let dateFormatter: DateFormatter = DateFormatter()
        dateFormatter.dateFormat = "dd/MM/yyyy"
        let selectedDate: String = dateFormatter.string(from: datePicker.date)
        dobTextField.text = selectedDate
        self.view.endEditing(true)
    }
    
    @objc func cancelDatePicker(){
        self.view.endEditing(true)
    }
    
    @objc func imageTapped(tapGestureRecognizer: UITapGestureRecognizer)
    {
        _ = tapGestureRecognizer.view as! UIImageView
        let imagePickerVC = UIImagePickerController()
                imagePickerVC.sourceType = .photoLibrary
                imagePickerVC.delegate = self
                present(imagePickerVC, animated: true)
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
       
        let mediaType = info[UIImagePickerController.InfoKey.mediaType] as! CFString
            if mediaType == kUTTypeImage {
                imageURL = info[UIImagePickerController.InfoKey.imageURL] as? URL
                if let image = info[.originalImage] as? UIImage {
                    selectImage.image = image
                 }
            }
            picker.dismiss(animated: true, completion: nil)
    }
    
    func uploadFile(fileUrl: URL) {
        do {
           let fileExtension = fileUrl.pathExtension
            let fileName = "Images/\(name) Image.\(fileExtension)"

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
                 self.downloadUrl = url!.absoluteString
             }
           }
         }
    }
    
    @IBAction func continueButtonPressed(_ sender: Any) {
        
        if nameTextField.text != "" && nicknameTextField.text != "" && dobTextField.text != "" && phoneNumberTextField.text != "" && selectGenderTextField.text != "" && imageURL != nil
        {
            uploadFile(fileUrl: imageURL)
            self.activtyIndicator.isHidden = false
            self.activtyIndicator.startAnimating()
            DispatchQueue.main.asyncAfter(deadline: .now() + 8) {
               
                self.ref.child("Users").child(self.user!.uid).setValue(["username": self.name, "email": self.email, "password": self.password, "nickname": self.nicknameTextField.text!, "dob": self.dobTextField.text!, "phonenumber": self.phoneNumberTextField.text!, "gender":  String(self.selectGenderTextField.text!), "image": self.downloadUrl, "isOnline": "online"])
                    self.activtyIndicator.stopAnimating()
                self.performSegue(withIdentifier: "ProfileToMain", sender: self)
            }
        }
        else {
            let alert = UIAlertController(title: "Signup", message: "All Fields Must be Filled", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
