
import UIKit

class CreateAccountVC: UIViewController {
  
  //Outlets
  @IBOutlet weak var usernameTxt: UITextField!
  @IBOutlet weak var emailTxt: UITextField!
  @IBOutlet weak var passwordTxt: UITextField!
  @IBOutlet weak var userImg: UIImageView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  // Variables
  var avatarName = "profileDefault"
  var avatarColor = "[0.5, 0.5, 0.5, 1]"
  var bgColor: UIColor?
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    if UserDataService.instance.avatarName != "" {
      userImg.image = UIImage(named: UserDataService.instance.avatarName)
      avatarName = UserDataService.instance.avatarName
      if avatarName.contains("light") && bgColor == nil {
        userImg.backgroundColor = UIColor.lightGray
      }
    }
  }
  
  @IBAction func onRegisterPressed(_ sender: Any) {
    spinner.isHidden = false
    spinner.startAnimating()
    guard let name = usernameTxt.text , usernameTxt.text != "" else { return }
    guard let email = emailTxt.text , emailTxt.text != "" else { return }
    guard let password = passwordTxt.text , passwordTxt.text != "" else { return }
    
    AuthService.instance.registerUser(email: email, password: password) { (success) in
      if success {
        AuthService.instance.loginUser(email: email, password: password, completion: { (success) in
          if success {
            AuthService.instance.createUser(name: name, email: email, avatarName: self.avatarName, avatarColor: self.avatarColor, completion: { (success) in
              if success {
                self.spinner.isHidden = true
                self.spinner.stopAnimating()
                self.performSegue(withIdentifier: UNWIND, sender: nil)
                NotificationCenter.default.post(name: NOTI_USER_DATA_DID_CHANGE, object: nil)
              }
            })
          }
        })
      }
    }
  }
  
  @IBAction func onChooseAvatarPressed(_ sender: Any) {
    performSegue(withIdentifier: TO_AVATAR_PICKER, sender: nil)
  }
  
  @IBAction func onGenerateBackgroundPressed(_ sender: Any) {
    let red = CGFloat(arc4random_uniform(255)) / 255
    let green = CGFloat(arc4random_uniform(255)) / 255
    let blue = CGFloat(arc4random_uniform(255)) / 255
    
    bgColor = UIColor(red: red, green: green, blue: blue, alpha: 1)
    avatarColor = "[\(red), \(green), \(blue), 1]"
    UIView.animate(withDuration: 0.2) {
      self.userImg.backgroundColor = self.bgColor
    }
  }
  
  @IBAction func onCloseBtnPressed(_ sender: Any) {
    performSegue(withIdentifier: UNWIND, sender: nil)
  }
  
  func setupView() {
    spinner.isHidden = true
    
    usernameTxt.attributedPlaceholder = NSAttributedString(string: "username", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    emailTxt.attributedPlaceholder = NSAttributedString(string: "email", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    passwordTxt.attributedPlaceholder = NSAttributedString(string: "password", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(CreateAccountVC.handleTap))
    view.addGestureRecognizer(tap)
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
}
