//
//  LoginViewController.swift
//  Messenger
//
//  Created by MAC on 17/02/22.
//

import UIKit
import Firebase
import FBSDKLoginKit

class LoginViewController: UIViewController {

    private let scrollView: UIScrollView = {
       let scrollView = UIScrollView()
        scrollView.clipsToBounds = true
        return scrollView
    }()
    private let imageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "chat")
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    private let emailField: UITextField = {
       let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "Email Address"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        return field
    }()
    
    private let passwordField: UITextField = {
       let field = UITextField()
        field.autocorrectionType = .no
        field.autocapitalizationType = .none
        field.returnKeyType = .continue
        field.layer.cornerRadius = 12
        field.layer.borderWidth = 1
        field.layer.borderColor = UIColor.lightGray.cgColor
        field.placeholder = "password"
        field.leftView = UIView(frame: CGRect(x: 0, y: 0, width: 10, height: 0))
        field.leftViewMode = .always
        field.backgroundColor = .white
        field.isSecureTextEntry = true
        return field
    }()
    
    private let loginButton: UIButton = {
        let button = UIButton()
        button.setTitle("Log In", for: .normal)
        button.backgroundColor = .link
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 12
        button.layer.masksToBounds = true
        button.titleLabel?.font = .systemFont(ofSize: 20, weight: .bold)
        return button
    }()
    private let facebookLoginButton : FBLoginButton = {
        let button = FBLoginButton()
        button.permissions = ["email","public_profile"]
        return button

    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        print("----> Login screen loaded")
        title = "Log In"
        view.backgroundColor = .white
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Register",
                                                            style: .done,
                                                            target: self,
                                                            action: #selector(didTapRegister))
        loginButton.addTarget(self, action: #selector(loginButtonTapped), for: .touchUpInside)
        emailField.delegate = self
        passwordField.delegate = self
        facebookLoginButton.delegate = self
        
        view.addSubview(scrollView)
        scrollView.addSubview(imageView)
        scrollView.addSubview(emailField)
        scrollView.addSubview(passwordField)
        scrollView.addSubview(loginButton)
        scrollView.addSubview(facebookLoginButton)
    }
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        scrollView.frame = view.bounds
        let size = scrollView.width/3
        imageView.frame = CGRect(x: (scrollView.width-size)/2,
                                 y: 20,
                                 width: size,
                                 height: size)
        
        emailField.frame = CGRect(x: 30,
                                  y: imageView.bottom+30,
                                  width: scrollView.width-60,
                                  height: 52)
        
        passwordField.frame = CGRect(x: 30,
                                  y: emailField.bottom+20,
                                  width: scrollView.width-60,
                                  height: 52)
        loginButton.frame = CGRect(x: 30,
                                  y: passwordField.bottom+40,
                                  width: scrollView.width-60,
                                  height: 52)
        facebookLoginButton.frame = CGRect(x: 30,
                                  y: loginButton.bottom+40,
                                  width: scrollView.width-60,
                                  height: 52)
        facebookLoginButton.frame.origin.y = loginButton.bottom+20
    }
    
    @objc private func didTapRegister()
    {
        let vc = RegisterViewController()
        vc.title = "Create Account"
        navigationController?.pushViewController(vc, animated: true)
    }
    
    @objc private func loginButtonTapped(){
        emailField.resignFirstResponder()
        passwordField.resignFirstResponder()
        guard let email = emailField.text,let password = passwordField.text,
              !email.isEmpty,!password.isEmpty,password.count >= 6 else {
                  alertUserLoginError()
                  
                  return
              }
        // firebase sign in
        
        Auth.auth().signIn(withEmail: email, password: password, completion: {[weak self] (authResult , error) in
            
            guard let stronSelf = self else {
                return
            }
            guard let result = authResult,error == nil else {
                print("Failed to login in user email address : \(email)")
                return
            }
            let user = result.user
            print("Logged in User--> \(String(describing: user.email))")
            stronSelf.navigationController?.dismiss(animated: true, completion: nil);
            
        })
    }
    
    private func alertUserLoginError() {
        let alert = UIAlertController(title: "Woops", message: "please enter all information to log in ", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Dismiss", style: .cancel, handler: nil))
        present(alert, animated: true)
    }

}

extension LoginViewController : UITextFieldDelegate{
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if textField == emailField{
            passwordField.becomeFirstResponder()
        }
        else if textField == passwordField {
            loginButtonTapped()
        }
        return true
    }
}

 
extension LoginViewController : LoginButtonDelegate {
    func loginButtonDidLogOut(_ loginButton: FBLoginButton) {
        // no operation..
    }
    
    
    func loginButton(_ loginButton: FBLoginButton, didCompleteWith result: LoginManagerLoginResult?, error: Error?) {
        guard let token = result?.token?.tokenString else{
            print("---> user failed to log in with facebook")
            return
        }
        
        let facebookRequest = FBSDKLoginKit.GraphRequest(graphPath: "me", parameters: ["fields":"email,name"],tokenString: token,version: nil, httpMethod: .get)
        facebookRequest.start { _, result, error in
            guard let result = result as? [String: Any],error == nil else {
                print("failed to make facebook graph request")
                return
            }
            print("--> result : \(result)")
            let credential = FacebookAuthProvider.credential(withAccessToken: token)
            Firebase.Auth.auth().signIn(with: credential) {[weak self] authResult, error in
                guard let stronSelf = self else {
                    return
                }
                guard  authResult != nil,error == nil else {
                    if let error = error {
                        print("---> facebook credential login failed...\(error.localizedDescription)")

                    }
                    return
                }
                print("---> successfully logged user in ")
                stronSelf.navigationController?.dismiss(animated: true, completion: nil);
            }
            guard let userName = result["name"] as? String,
                  let email = result["email"] as? String else {
                      print("failed to get email and name from fb results")
                      return
                  }
            let nameComponents = userName.components(separatedBy: " ")
            guard nameComponents.count == 2 else {
                return
            }
            let firstName = nameComponents[0]
            let lastName = nameComponents[1]
            DataBaseManager.shared.userExists(with: email) { exist in
                if !exist
                {
                    DataBaseManager.shared.insertUser(with: ChatAppUser(firstName: firstName,
                                                                        lastName: lastName, emailAddress: email))
                }
                
            }
        }
        
    
    }
    
    
}
    

