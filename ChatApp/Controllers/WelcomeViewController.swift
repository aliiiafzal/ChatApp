//
//  ViewController.swift
//  ChatApp
//
//  Created by Ali Afzal on 25/10/2022.
//

import UIKit
import FirebaseCore
import FirebaseAuth
import GoogleSignIn
import FirebaseDatabase
import FacebookLogin
import FBSDKCoreKit
import FBSDKLoginKit
import CryptoKit
import AuthenticationServices

@available(iOS 13.0, *)
class WelcomeViewController: UIViewController, LoginButtonDelegate, ASAuthorizationControllerDelegate, ASAuthorizationControllerPresentationContextProviding
{
    
    @IBOutlet weak var appleButton: UIButton!
    @IBOutlet weak var facebookButton: FBLoginButton!
    fileprivate var currentNonce: String?
    var ref: DatabaseReference!
    //var ref = Database.database().reference()
   
    
    override func viewDidLoad() {
        super.viewDidLoad()
        facebookButton.delegate = self
        ref = Database.database().reference()
//        let loginButton = FBLoginButton()
//        loginButton.delegate = self
//        loginButton.center = view.center
//        view.addSubview(loginButton)
//        loginButton.permissions = ["public_profile","email"]
    }
    
    
    @IBAction func createAccountButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "WelcometoSignup", sender: self)
    }
    
    @IBAction func loginButtonPressed(_ sender: UIButton) {
        self.performSegue(withIdentifier: "WelcometoLogin", sender: self)
    }
    
    
    @IBAction func googleSigninPressed(_ sender: Any) {
        guard let clientID = FirebaseApp.app()?.options.clientID else { return }
        let config = GIDConfiguration(clientID: clientID)
        GIDSignIn.sharedInstance.signIn(with: config, presenting: self) { [unowned self] user, error in
            
            if let error = error {
                print("Error\(error)")
                return
            }
            guard
                let authentication = user?.authentication,
                let idToken = authentication.idToken
            else {
                return
            }
            
            let credential = GoogleAuthProvider.credential(withIDToken: idToken,
                                                           accessToken: authentication.accessToken)
            Auth.auth().signIn(with: credential) { authResult, error in
                if let error = error {
                    let authError = error as NSError
                    if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                        let resolver = authError
                            .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                        var displayNameString = ""
                        for tmpFactorInfo in resolver.hints {
                            displayNameString += tmpFactorInfo.displayName ?? ""
                            displayNameString += " "
                        }
                        self.showTextInputPrompt(
                            withMessage: "Select factor to sign in\n\(displayNameString)",
                            completionBlock: { userPressedOK, displayName in
                                var selectedHint: PhoneMultiFactorInfo?
                                for tmpFactorInfo in resolver.hints {
                                    if displayName == tmpFactorInfo.displayName {
                                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                                    }
                                }
                                PhoneAuthProvider.provider()
                                    .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                                       multiFactorSession: resolver
                                        .session) { verificationID, error in
                                            if error != nil {
                                                print(
                                                    "Multi factor start sign in failed. Error: \(error.debugDescription)"
                                                )
                                            } else {
                                                self.showTextInputPrompt(
                                                    withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                                                    completionBlock: { userPressedOK, verificationCode in
                                                        let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                                            .credential(withVerificationID: verificationID!,
                                                                        verificationCode: verificationCode!)
                                                        let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                                            .assertion(with: credential!)
                                                        resolver.resolveSignIn(with: assertion!) { authResult, error in
                                                            if error != nil {
                                                                print(
                                                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                                                )
                                                            } else {
                                                                self.navigationController?.popViewController(animated: true)
                                                            }
                                                        }
                                                    }
                                                )
                                            }
                                        }
                            }
                        )
                    } else {
                        self.showMessagePrompt(error.localizedDescription)
                        return
                    }
                    return
                }
            }
            
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                let photoURL = user.photoURL?.absoluteString
                let name = user.displayName
                let email = user.email
                let phoneNumber = user.phoneNumber
                
                
                var multiFactorString = "MultiFactor: "
                for info in user.multiFactor.enrolledFactors {
                    multiFactorString += info.displayName ?? "[DispayName]"
                    multiFactorString += " "
                }
                print("UID", uid)
                print("email", email ?? "Not have Email")
                print("photoURL", photoURL ?? "Not have Photo URL")
                print("Name", name ?? "Not have Name")
                print("phoneNumber", phoneNumber ?? "Not have Phone Number")
                
                ref.child("Users").child(user.uid).setValue(["username": name ?? "", "email": email ?? "", "password": "", "nickname": "", "dob": "", "phonenumber": phoneNumber ?? "", "gender": "", "image": photoURL ?? "", "isOnline": "online"])
                
                self.performSegue(withIdentifier: "WelcometoMain", sender: self)
            }
        }
    }
    
    func showMessagePrompt(_ message: String) {
        let alert = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default, handler: nil)
        alert.addAction(okAction)
        present(alert, animated: false, completion: nil)
    }
    
    func showTextInputPrompt(withMessage message: String,
                             completionBlock: @escaping ((Bool, String?) -> Void)) {
        let prompt = UIAlertController(title: nil, message: message, preferredStyle: .alert)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { _ in
            completionBlock(false, nil)
        }
        weak var weakPrompt = prompt
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            guard let text = weakPrompt?.textFields?.first?.text else { return }
            completionBlock(true, text)
        }
        prompt.addTextField(configurationHandler: nil)
        prompt.addAction(cancelAction)
        prompt.addAction(okAction)
        present(prompt, animated: true, completion: nil)
    }
    
    @IBAction func facebookButtonPressed(_ sender: FBLoginButton) {
        facebookButton.permissions = ["public_profile","email"]
        }
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        if let error = error {
            print(error.localizedDescription)
        return
        }
        let credential = FacebookAuthProvider.credential(withAccessToken: AccessToken.current?.tokenString ?? "")
        
        Auth.auth().signIn(with: credential) { authResult, error in
            if let error = error {
              let authError = error as NSError
              if authError.code == AuthErrorCode.secondFactorRequired.rawValue {
                // The user is a multi-factor user. Second factor challenge is required.
                let resolver = authError
                  .userInfo[AuthErrorUserInfoMultiFactorResolverKey] as! MultiFactorResolver
                var displayNameString = ""
                for tmpFactorInfo in resolver.hints {
                  displayNameString += tmpFactorInfo.displayName ?? ""
                  displayNameString += " "
                }
                self.showTextInputPrompt(
                  withMessage: "Select factor to sign in\n\(displayNameString)",
                  completionBlock: { userPressedOK, displayName in
                    var selectedHint: PhoneMultiFactorInfo?
                    for tmpFactorInfo in resolver.hints {
                      if displayName == tmpFactorInfo.displayName {
                        selectedHint = tmpFactorInfo as? PhoneMultiFactorInfo
                      }
                    }
                    PhoneAuthProvider.provider()
                      .verifyPhoneNumber(with: selectedHint!, uiDelegate: nil,
                                         multiFactorSession: resolver
                                           .session) { verificationID, error in
                        if error != nil {
                          print(
                            "Multi factor start sign in failed. Error: \(error.debugDescription)"
                          )
                        } else {
                          self.showTextInputPrompt(
                            withMessage: "Verification code for \(selectedHint?.displayName ?? "")",
                            completionBlock: { userPressedOK, verificationCode in
                              let credential: PhoneAuthCredential? = PhoneAuthProvider.provider()
                                .credential(withVerificationID: verificationID!,
                                            verificationCode: verificationCode!)
                              let assertion: MultiFactorAssertion? = PhoneMultiFactorGenerator
                                .assertion(with: credential!)
                              resolver.resolveSignIn(with: assertion!) { authResult, error in
                                if error != nil {
                                  print(
                                    "Multi factor finanlize sign in failed. Error: \(error.debugDescription)"
                                  )
                                } else {
                                  self.navigationController?.popViewController(animated: true)
                                }
                              }
                            }
                          )
                        }
                      }
                  }
                )
              } else {
                self.showMessagePrompt(error.localizedDescription)
                return
              }
              return
            }
            let user = Auth.auth().currentUser
            if let user = user {
                let uid = user.uid
                let photoURL = user.photoURL?.absoluteString
                let name = user.displayName
                let email = user.email
                let phoneNumber = user.phoneNumber
                
                
                var multiFactorString = "MultiFactor: "
                for info in user.multiFactor.enrolledFactors {
                    multiFactorString += info.displayName ?? "[DispayName]"
                    multiFactorString += " "
                }
                print("UID", uid)
                print("email", email ?? "Not have Email")
                print("photoURL", photoURL ?? "Not have Photo URL")
                print("Name", name ?? "Not have Name")
                print("phoneNumber", phoneNumber ?? "Not have Phone Number")
                
                self.ref.child("Users").child(user.uid).setValue(["username": name ?? "", "email": email ?? "", "password": "", "nickname": "", "dob": "", "phonenumber": phoneNumber ?? "", "gender": "", "image": photoURL ?? "", "isOnline": "online"])
                
                self.performSegue(withIdentifier: "WelcometoMain", sender: self)
            }
        }
            
    }

    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
       print("Logged out")
    }
    
    private func randomNonceString(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: Array<Character> =
            Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError("Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)")
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        return result
    }

    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            return String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
   
    @IBAction func appleButtonPressed(_ sender: UIButton) {
        let appleIDProvider = ASAuthorizationAppleIDProvider()
        let request = appleIDProvider.createRequest()
        request.requestedScopes = [.fullName, .email]
        self.currentNonce = randomNonceString()
        request.nonce = sha256(currentNonce!)
        let authorizationController = ASAuthorizationController(authorizationRequests: [request])
        authorizationController.delegate = self
        authorizationController.presentationContextProvider = self
        authorizationController.performRequests()
    }
    
    func authorizationController(controller: ASAuthorizationController, didCompleteWithAuthorization authorization: ASAuthorization) {
        
        if let appleIDCredential = authorization.credential as? ASAuthorizationAppleIDCredential {
            UserDefaults.standard.set(appleIDCredential.user, forKey: "appleAuthorizedUserIdKey")
            guard let nonce = self.currentNonce else {
                fatalError("Invalid state: A login callback was received, but no login request was sent.")
            }
            guard let appleIDToken = appleIDCredential.identityToken else {
                print("Failed to fetch identity token")
                return
            }
            guard let idTokenString = String(data: appleIDToken, encoding: .utf8) else {
                print("Failed to decode identity token")
                return
            }
            let firebaseCredential = OAuthProvider.credential(withProviderID: "apple.com",
                                                              idToken: idTokenString,
                                                              rawNonce: nonce)
            Auth.auth().signIn(with: firebaseCredential) { (authResult, error) in
                if let error = error {
                    print(error.localizedDescription)
                    return
                }
                let changeRequest = authResult?.user.createProfileChangeRequest()
                changeRequest?.displayName = appleIDCredential.fullName?.givenName
                changeRequest?.commitChanges(completion: { (error) in

                    if let error = error {
                        print(error.localizedDescription)
                    } else {
                        let user = Auth.auth().currentUser
                        if let user = user {
                            let uid = user.uid
                            let photoURL = user.photoURL?.absoluteString
                            let name = user.displayName
                            let email = user.email
                            let phoneNumber = user.phoneNumber
                            
                            
                            var multiFactorString = "MultiFactor: "
                            for info in user.multiFactor.enrolledFactors {
                                multiFactorString += info.displayName ?? "[DispayName]"
                                multiFactorString += " "
                            }
                            print("UID", uid)
                            print("email", email ?? "Not have Email")
                            print("photoURL", photoURL ?? "Not have Photo URL")
                            print("Name", name ?? "Not have Name")
                            print("phoneNumber", phoneNumber ?? "Not have Phone Number")
                            
                            self.ref.child("Users").child(user.uid).setValue(["username": name ?? "", "email": email ?? "", "password": "", "nickname": "", "dob": "", "phonenumber": phoneNumber ?? "", "gender": "", "image": photoURL ?? "", "isOnline": "online"])
                            self.performSegue(withIdentifier: "WelcometoMain", sender: self)
                        }
                    }
                })
            }
        }
    }
    
    func presentationAnchor(for controller: ASAuthorizationController) -> ASPresentationAnchor {
        return self.view.window!
    }
}

