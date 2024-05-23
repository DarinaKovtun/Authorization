//
//  ViewController.swift
//  Login
//
//  Created by Darina Kovtun on 04.02.2024.
//

import UIKit

class ViewController: UIViewController, UITextFieldDelegate {
    
    // MARK: - IBOutlet
    @IBOutlet weak var loginButton: UIButton!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var emailLine: UIView!
    @IBOutlet weak var passwordLine: UIView!
    @IBOutlet weak var signUpButton: UIButton!
    @IBOutlet weak var accountLabel: UILabel!
    @IBOutlet weak var envelopeImageView: UIImageView!
    @IBOutlet weak var keyImageView: UIImageView!
     // MARK: - Properties
    var isLogin = true
    private var email: String = "" {
        willSet {
            updateLoginButton()
        }
        didSet {
            updateLoginButton()
        }
    }
    
    private var password: String = "" {
        willSet {
            updateLoginButton()
        }
        didSet {
            updateLoginButton()
        }
    }
    
    private func updateLoginButton() {
        let isButtonEnabled = !(email.isEmpty || password.isEmpty)
        let buttonColor: UIColor = isButtonEnabled ? .systemYellow : .lightGray
        let shadowColor: CGColor = isButtonEnabled ? UIColor.systemYellow.cgColor : UIColor.lightGray.cgColor
        
        loginButton.isUserInteractionEnabled = isButtonEnabled
        loginButton.backgroundColor = buttonColor
        loginButton.layer.shadowColor = shadowColor
    }

    // MARK: - Life cycle
    override func viewDidLoad() {
        super.viewDidLoad()
        signUpButton.isHidden = !isLogin
        accountLabel.isHidden = !isLogin
        
        configureLoginButton()
        emailTextField.delegate = self
        passwordTextField.delegate = self
        
        emailTextField.becomeFirstResponder()
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(hideKeyboard))
               view.addGestureRecognizer(tapGesture)
    }
    
    // MARK: - IBActions
    @IBAction func loginAction(_ sender: Any) {
        emailTextField.resignFirstResponder()
        passwordTextField.resignFirstResponder()
        
        if email.isEmpty {
            errorField(textField: emailTextField)
        }
        
        if password.isEmpty {
            errorField(textField: passwordTextField)
        }
        
        if isLogin {
            if KeychainManager.checkUser(with: email, password: password){
                performSegue(withIdentifier: "goToHomePage", sender: sender)
            } else {
                let alert = UIAlertController(title: "Error".localized ,
                                              message: "Wrong password or email".localized,
                                              preferredStyle: .alert)
                let action = UIAlertAction(title: "OK".localized, style: .default)
                alert.addAction(action)
                present(alert, animated: true)
            }
        } else {
            if KeychainManager.save(email: email, password: password) {
                performSegue(withIdentifier: "goToHomePage", sender: sender)
            } else {
                debugPrint("Error with saving and password")
            }
        }
    }
    
    @IBAction private func signUpAction(_ sender: Any) {
        guard let viewController = UIStoryboard(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "ViewController") as? ViewController else { return }
        viewController.isLogin = false
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    // MARK: - Methods
    @objc
    private func hideKeyboard() {
           view.endEditing(true)
       }
    
    func configureLoginButton() {
        loginButton.layer.shadowColor = UIColor.lightGray.cgColor
        loginButton.layer.shadowOffset = CGSize(width: 0.9, height: 7)
        loginButton.layer.shadowOpacity = 0.3
        loginButton.layer.shadowRadius = 5
        
        loginButton.isUserInteractionEnabled = false
        loginButton.backgroundColor = UIColor.lightGray
        
        loginButton.setTitle(isLogin ? "Login".localized.uppercased() : "Sign Up".localized.uppercased() , for: .normal)
    }
}

    // MARK: - UITextViewDelegate
extension ViewController: UITextViewDelegate {
    func textFieldDidEndEditing(_ textField: UITextField) {
 
        guard let text = textField.text?.trimmingCharacters(in: .whitespacesAndNewlines),
        !text.isEmpty else { return }
        
        switch textField {
        case emailTextField:
          let isValidEmail = check(email: text)
            
            if isValidEmail {
                email = text
                envelopeImageView.tintColor = UIColor.systemGray5
                emailLine.backgroundColor = UIColor.systemGray5
      
            } else {
                email = ""
                errorField(textField: textField)
            }
        case passwordTextField:
        let isValidPassword = check(password: text)
            
            if isValidPassword {
                password = text
                keyImageView.tintColor = UIColor.systemGray5
                passwordLine.backgroundColor = UIColor.systemGray5
                
            } else {
                password = ""
                errorField(textField: textField)
            }
        default:
            print("unknown text field")
        }
    }
    
    private func check(email: String) -> Bool {
       return email.contains("@") && email.contains(".")
    }
    
    private func check(password: String) -> Bool {
        return password.count >= 6
    }
    
    private func errorField(textField: UITextField) {
        switch textField {
        case emailTextField:
            envelopeImageView.tintColor = UIColor.systemRed
            emailLine.backgroundColor = UIColor.systemRed
        case passwordTextField:
            keyImageView.tintColor = UIColor.systemRed
            passwordLine.backgroundColor = UIColor.systemRed
        default:
            print("")
        }
    }
}

