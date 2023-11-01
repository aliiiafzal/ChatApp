//
//  SignupViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 26/10/2022.
//

import UIKit
import FirebaseAuth

@available(iOS 13.4, *)
class SignupViewController: UIViewController {

    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    override func viewDidLoad() {
        super.viewDidLoad()
       setIconAndColourInTextField()
    }
    
    func setIconAndColourInTextField() {
        nameTextField.tintColor = UIColor.lightGray
        nameTextField.setIcon(UIImage(named: "user")!)
        nameTextField.layer.cornerRadius = 15.0
        emailTextField.tintColor = UIColor.lightGray
        emailTextField.setIcon(UIImage(named: "mail")!)
        emailTextField.layer.cornerRadius = 15.0
        passwordTextField.tintColor = UIColor.lightGray
        passwordTextField.setIcon(UIImage(named: "padlock")!)
        passwordTextField.layer.cornerRadius = 15.0
    }
    
    @IBAction func signupButtonPressed(_ sender: UIButton) {
        if let email = emailTextField.text, let password = passwordTextField.text, nameTextField.text != ""
        {
            if password.count > 8 {
                Auth.auth().createUser(withEmail: email, password: password) { authResult, error in
                    if let e = error {
                        let alert = UIAlertController(title: "Signup", message: e.localizedDescription, preferredStyle: UIAlertController.Style.alert)
                        alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                        self.present(alert, animated: true, completion: nil)
                    }
                    else
                    {
                        guard let storyboard = self.storyboard?.instantiateViewController(withIdentifier: "ProfileVC") as? profileViewController else {
                            return
                        }
                        storyboard.name = self.nameTextField.text!
                        storyboard.email = email
                        storyboard.password = password
                        self.navigationController?.pushViewController(storyboard, animated: true)
                    }
                }
            }
            else {
                let alert = UIAlertController(title: "Signup", message: "Password must be greater than 8 characters", preferredStyle: UIAlertController.Style.alert)
                alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
                self.present(alert, animated: true, completion: nil)
            }
        }
        else
        {
            let alert = UIAlertController(title: "Signup", message: "All Fields Must be Filled", preferredStyle: UIAlertController.Style.alert)
            alert.addAction(UIAlertAction(title: "OK", style: UIAlertAction.Style.default, handler: nil))
            self.present(alert, animated: true, completion: nil)
        }
    }
    
    
    @IBAction func loginButtonPressed(_ sender: Any) {
        self.performSegue(withIdentifier: "SignuptoLogin", sender: self)
    }
    
}

extension UITextField {
    func setIcon(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 20, y: 15, width: 30, height: 30))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 20, y: 0, width: 60, height: 60))
        iconContainerView.addSubview(iconView)
        leftView = iconContainerView
        leftViewMode = .always
    }
    
    func setIconOfDob(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 20, y: 15, width: 30, height: 30))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 100, y: 0, width: 70, height: 60))
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .whileEditing
    }
    
    func setIconOfPN(_ image: UIImage) {
        let iconView = UIImageView(frame:
                                    CGRect(x: 20, y: 15, width: 15, height: 15))
        iconView.image = image
        let iconContainerView: UIView = UIView(frame:
                                                CGRect(x: 100, y: 0, width: 55, height: 45))
        iconContainerView.addSubview(iconView)
        rightView = iconContainerView
        rightViewMode = .always
    }
}
