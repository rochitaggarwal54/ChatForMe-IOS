//
//  RegisterController.swift
//  ChatMe
//
//  Created by Sultan on 01/04/18.
//  Copyright © 2018 Sultan. All rights reserved.
//

import UIKit
import FirebaseAuth

class RegisterController: UIViewController {
    @IBOutlet weak var backBtn: UIButton!
    @IBOutlet weak var registerBtn: UIButton!
    @IBOutlet weak var usernameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var activityIndicator: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialView()
        subscribeToKeyboardNotification()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        unsubscribeFromKeyboardNotifications()
    }
    
    fileprivate func initialView() {
        backBtn.layer.cornerRadius = 10
        backBtn.clipsToBounds = true
        
        registerBtn.layer.cornerRadius = 20
        registerBtn.clipsToBounds = true
        
        usernameTextField.delegate = self
        passwordTextField.delegate = self
        emailTextField.delegate = self
    }
    //MARK: IBACTIONS
    
    @IBAction func backActivity(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func registerUser(_ sender: Any) {
        activityIndicator.startAnimating()
        Auth.auth().createUser(withEmail: emailTextField.text!, password: passwordTextField.text!) { (user, error) in
            if user != nil { //Sign Up Successful
                print("Success")
                DispatchQueue.main.async {
                    let userNameChangeReq = Auth.auth().currentUser?.createProfileChangeRequest()
                    userNameChangeReq?.displayName = self.usernameTextField.text!
                    userNameChangeReq?.commitChanges(completion: { (error) in
                        if error != nil{
                            self.showAlertView(alertMessage: (error?.localizedDescription)!)
                        }
                    })
                }
                self.activityIndicator.stopAnimating()
                self.dismiss(animated: true, completion: nil) //Return To LoginController
            } else { //Sign Up Unsuccessful
                self.showAlertView(alertMessage: (error?.localizedDescription)!)
            }
        }
    }
}

//MARK: UI CHANGES FOR KEYBOARD
extension RegisterController{
    func subscribeToKeyboardNotification(){
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: .UIKeyboardWillShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(returnKeyboardBack), name: .UIKeyboardWillHide, object: nil)
    }
    func unsubscribeFromKeyboardNotifications() {
        NotificationCenter.default.removeObserver(self)
    }
    @objc func keyboardWillShow(_ notification:Notification) {
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            if (passwordTextField.isFirstResponder || emailTextField.isFirstResponder || usernameTextField.isFirstResponder) {
                view.frame.origin.y = (-getKeyboardHeight(notification)+65)
            }
        } else {
            if (passwordTextField.isFirstResponder) {
                view.frame.origin.y = (-getKeyboardHeight(notification)+100)
            }
        }
    }
    @objc func returnKeyboardBack(){
        if UIDeviceOrientationIsLandscape(UIDevice.current.orientation){
            if (passwordTextField.isFirstResponder || emailTextField.isFirstResponder||usernameTextField.isFirstResponder) {
                view.frame.origin.y=0
            }
        } else {
            if (passwordTextField.isFirstResponder) {
                view.frame.origin.y=0
            }
        }
    }
    func getKeyboardHeight(_ notification:Notification) -> CGFloat {
        
        let userInfo = notification.userInfo
        let keyboardSize = userInfo![UIKeyboardFrameEndUserInfoKey] as! NSValue
        return keyboardSize.cgRectValue.height
    }
}
//MARK: ALERTVIEW
extension UIViewController{
    func showAlertView(alertMessage : String){
        let alertController = UIAlertController()
        alertController.title = "Error"
        alertController.message = alertMessage
        let okAction = UIAlertAction(title: "OK", style: .default) { (action) in
            self.dismiss(animated: true, completion: nil)
        }
        alertController.addAction(okAction)
        present(alertController, animated: true, completion: nil)
    }
}
