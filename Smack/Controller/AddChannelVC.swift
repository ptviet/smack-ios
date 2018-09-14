
import UIKit

class AddChannelVC: UIViewController {
  
  // Outlets
  @IBOutlet weak var nameTxt: UITextField!
  @IBOutlet weak var descTxt: UITextField!
  @IBOutlet weak var bgView: UIView!
  @IBOutlet weak var spinner: UIActivityIndicatorView!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    setupView()
    
  }
  
  
  @IBAction func onClosePressed(_ sender: Any) {
    dismiss(animated: true, completion: nil)
  }
  
  @IBAction func onSubmitPressed(_ sender: Any) {
    spinner.isHidden = false
    spinner.startAnimating()
    
    guard let channelName = nameTxt.text, nameTxt.text != "" else { return }
    guard let channelDesc = descTxt.text, descTxt.text != "" else { return }
    
    SocketService.instance.addChannel(channelName: channelName, channelDescription: channelDesc) { (success) in
      if success {
        self.dismiss(animated: true, completion: nil)
        
        self.spinner.isHidden = true
        self.spinner.stopAnimating()
        
      }
    }
    
  }
  
  func setupView() {
    spinner.isHidden = true
    
    nameTxt.attributedPlaceholder = NSAttributedString(string: "name", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    descTxt.attributedPlaceholder = NSAttributedString(string: "description", attributes: [NSAttributedStringKey.foregroundColor: smackPurplePlaceholder])
    
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.handleTap))
    view.addGestureRecognizer(tap)
    
    let closeTouch = UITapGestureRecognizer(target: self, action: #selector(AddChannelVC.closeTap(_:)))
    bgView.addGestureRecognizer(closeTouch)
    
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  @objc func closeTap(_ recognizer: UITapGestureRecognizer) {
    dismiss(animated: true, completion: nil)
  }
  
  
  
  
}
