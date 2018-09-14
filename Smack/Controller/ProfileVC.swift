
import UIKit

class ProfileVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var profileImg: UIImageView!
  @IBOutlet weak var username: UILabel!
  @IBOutlet weak var userEmail: UILabel!
  @IBOutlet weak var bgView: UIView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    
  }
  
  @IBAction func onClosePressed(_ sender: Any) {
    self.dismiss(animated: true, completion: nil)
    
  }
  
  @IBAction func onLogoutPressed(_ sender: Any) {
    UserDataService.instance.logoutUser()
    NotificationCenter.default.post(name: NOTI_USER_DATA_DID_CHANGE, object: nil)
    dismiss(animated: true, completion: nil)
  }
  
  func setupView() {
    username.text = UserDataService.instance.name
    userEmail.text = UserDataService.instance.email
    profileImg.image = UIImage(named: UserDataService.instance.avatarName)
    profileImg.backgroundColor = UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
    
    let closeTouch = UITapGestureRecognizer(target: self, action: #selector(ProfileVC.closeTap(_:)))
    bgView.addGestureRecognizer(closeTouch)
  }
  
  @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
}
