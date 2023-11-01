//
//  ProfileUpdateViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 07/11/2022.
//

import UIKit
import iOSDropDown
import FirebaseAuth
import FirebaseDatabase
import MobileCoreServices
import FirebaseStorage

class ProfileUpdateViewController: UIViewController {
    
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var dobTextField: UITextField!
    @IBOutlet weak var phoneNumberTextField: UITextField!
    @IBOutlet weak var selectGenderTextField: DropDown!
    
    var datePicker: UIDatePicker = UIDatePicker()
    var ref = Database.database().reference()
    let userID = Auth.auth().currentUser?.uid
    
    override func viewDidLoad() {
        super.viewDidLoad()
        loadProfileUpdatedData()
        setIconAndColourInTextField()
        selectGender()
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
        //phoneNumberTextField.setIconOfPN(UIImage(named: "caret-down")!)
        phoneNumberTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dobTextField.frame.height))
        phoneNumberTextField.leftViewMode = .always
        selectGenderTextField.layer.cornerRadius = 15.0
        selectGenderTextField.tintColor = UIColor.lightGray
        //selectGenderTextField.setIconOfPN(UIImage(named: "caret-down")!)
        selectGenderTextField.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 20, height: dobTextField.frame.height))
        selectGenderTextField.leftViewMode = .always
    }
    
    func loadProfileUpdatedData() {
            ref.child("Users/").child(userID!).observe(.value, with: { snapshot in
            let value = snapshot.value as? NSDictionary
            let userName = value?["username"] as? String ?? ""
            let userNickName = value?["nickname"] as? String ?? ""
            let userGender = value?["gender"] as? String ?? ""
            let userDob = value?["dob"] as? String ?? ""
            let userPhoneNumber = value?["phonenumber"] as? String ?? ""
            
            self.nameTextField.text = userName
            self.nicknameTextField.text = userNickName
            self.selectGenderTextField.text = userGender
            self.dobTextField.text = userDob
            self.phoneNumberTextField.text = userPhoneNumber
            
        }) { error in
            print(error.localizedDescription)
        }
    }
    
    func selectGender() {
                selectGenderTextField.optionArray = ["Male", "Female", "Other"]
                selectGenderTextField.selectedRowColor = .lightGray
                selectGenderTextField.arrowColor = UIColor.lightGray
                selectGenderTextField.isSearchEnable = false
                selectGenderTextField.didSelect{(selectedText , index ,id) in
                    self.selectGenderTextField.text = selectedText
                }
                selectGenderTextField.resignFirstResponder()
    }
    
    @available(iOS 13.4, *)
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
    
    @IBAction func updateButtonPressed(_ sender: UIButton) {
        
        if nameTextField.text != "" && nicknameTextField.text != "" && dobTextField.text != "" && phoneNumberTextField.text != "" && selectGenderTextField.text != ""
        {
           ref.child("Users").child(userID!).updateChildValues(["username": nameTextField.text!, "nickname": nicknameTextField.text!, "dob": dobTextField.text!, "phonenumber": phoneNumberTextField.text!, "gender":  String(selectGenderTextField.text!)])
            
            _ = navigationController?.popViewController(animated: true)
        }
        else {
            let alert = UIAlertController(title: "Signup", message: "All Fields Must be Filled", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
}
