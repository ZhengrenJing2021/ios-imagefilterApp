//
//  ViewController.swift
//  ImageFilter
//
//  UI: Manage the interface using view controllers and facilitate navigation around the app's content.
//

import UIKit
import MBProgressHUD
import GuidePageView
class ViewController: UIViewController {

    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var userNameTextField: UITextField!
    private let imageArray = ["test_1","test_2"]
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        passwordTextField.delegate = self
        userNameTextField.delegate = self
        let guideView = GuidePageView.init(images: imageArray, loginRegistCompletion: nil, startCompletion: nil)
        guideView.startButton.isHidden = true
        guideView.skipButton.setTitle("Skip", for: .normal)
        guideView.logtinButton.setTitle("Register/Login", for: .normal)
        self.view.addSubview(guideView)
    }

    @IBAction func forgetPasswordClick(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SignAndLogController") as! SignAndLogController
        vc.changeTitle(type: .ChangePassword)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func signupClick(_ sender: Any) {
        let vc = UIStoryboard(name: "Main", bundle: nil)
            .instantiateViewController(withIdentifier: "SignAndLogController") as! SignAndLogController
        vc.changeTitle(type: .SignUp)
        self.present(vc, animated: true, completion: nil)
    }
    
    @IBAction func loginClick(_ sender: Any) {
        if let userName = userNameTextField.text,let password = passwordTextField.text,let p = UserDefaults.standard.value(forKey: userName) as? String ,password == p{
            let vc = UIStoryboard(name: "Main", bundle: nil)
                .instantiateViewController(withIdentifier: "ImageFilterViewController") as! ImageFilterViewController
            self.present(vc, animated: true, completion: nil)
            MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Login success!", animated: true)
            print("Login success!")
        }else{
            MBProgressHUD.showAdded(view: self.view, duration: 0.5, withText: "Login error!", animated: true)
            print("Login error!")
        }
    }
}
extension ViewController : UITextFieldDelegate{
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}


