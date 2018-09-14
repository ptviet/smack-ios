
import UIKit

class LoginVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var usernameTxt: UITextField!
  @IBOutlet weak var passwordTxt: UITextField!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    
  }
  @IBAction func onCloseBtnPressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onSignUpPressed(_ sender: Any) {
    performSegue(withIdentifier: TO_CREATE_ACCOUNT, sender: nil)
  }
  
  @IBAction func onLoginBtnPressed(_ sender: Any) {
    spinner.isHidden = false
    spinner.startAnimating()
    guard let email = usernameTxt.text , usernameTxt.text != "" else { return }
    guard let password = passwordTxt.text , passwordTxt.text != "" else { return }
    
    AuthService.instance.loginUser(email: email, password: password, completion: { (success) in
      if success {
        AuthService.instance.findUserByEmail(completion: { (success) in
          NotificationCenter.default.post(name: NOTI_USER_DATA_DID_CHANGE, object: nil)
          self.spinner.isHidden = true
          self.spinner.stopAnimating()
          self.dismiss(animated: true, completion: nil)
        })
        
      }
    })
  }
  
  func setupView() {
    spinner.isHidden = true
    
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(LoginVC.handleTap))
    view.addGestureRecognizer(tap)
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
}
