//
//  SignAndLogController.swift
//  ImageFilter
//
//  Manege the events on log-in page.
//

import UIKit
import MBProgressHUD

class SignAndLogController: UIViewController {
    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var userNameTextField: UITextField!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmPasswordTextField: UITextField!
    @IBOutlet weak var clickBtn: UIButton!
    private var type : ControllerType?
    enum ControllerType {
        case SignUp
        case ChangePassword
    }
    override func viewDidLoad() {
        super.viewDidLoad()
        if type == .SignUp{
            titleLabel.text = "Sign Up"
            clickBtn.setTitle("Sign Up", for: .normal)
        }else if type == .ChangePassword{
            titleLabel.text = "Forget password"
            clickBtn.setTitle("Forget password", for: .normal)
        }
        userNameTextField.delegate = self
        passwordTextField.delegate = self
        confirmPasswordTextField.delegate = self
    }
    @IBAction func btnClick(_ sender: Any) {
        if let userName = userNameTextField.text,let password = passwordTextField.text,let confirmPassword = confirmPasswordTextField.text,password == confirmPassword{
            if type == .ChangePassword,let _ = UserDefaults.standard.value(forKey: userName){
                UserDefaults.standard.setValue(password, forKey: userName)
                MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Change password success.", animated: true)
            }else if type == .SignUp{
                UserDefaults.standard.setValue(password, forKey: userName)
                MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Sign Up success.", animated: true)
            }else{
                MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Error occured:please check your inputs.", animated: true)
            }
        }else{
            MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Error occured:please check your inputs.", animated: true)
        }
    }
    @IBAction func backBtnClick(_ sender: Any) {
        self.dismiss(animated: true, completion: nil)
    }
    func changeTitle(type : ControllerType){
        self.type = type
    }
}
extension SignAndLogController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
}
