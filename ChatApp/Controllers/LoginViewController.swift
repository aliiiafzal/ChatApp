//
//  LoginViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 26/10/2022.
//

import UIKit
import FirebaseAuth
import FirebaseDatabase

class LoginViewController: UIViewController {

    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    var ref = Database.database().reference()
    override func viewDidLoad() {
        super.viewDidLoad()
        setIconAndColourInTextField()
    }
    
    
    func setIconAndColourInTextField() {
        emailTextField.tintColor = UIColor.lightGray
        emailTextField.setIcon(UIImage(named: "mail")!)
        emailTextField.layer.cornerRadius = 15.0
        passwordTextField.tintColor = UIColor.lightGray
        passwordTextField.setIcon(UIImage(named: "padlock")!)
        passwordTextField.layer.cornerRadius = 15.0
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text {
            Auth.auth().signIn(withEmail: email, password: password) {authResult, error in
                if let e = error {
                    //print(e.localizedDescription)
                    let alert = UIAlertController(title: "Login", message: e.localizedDescription, preferredStyle: .alert)
                    alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
                    self.present(alert, animated: true, completion: nil)
                }
                else {
                    self.performSegue(withIdentifier: "LogintoMain", sender: self)
                    
                    self.ref.child("Users").child(Auth.auth().currentUser!.uid).updateChildValues(["isOnline": "online"])
                }
            }
        }
    }
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "LogintoSignup", sender: self)
    }
}

