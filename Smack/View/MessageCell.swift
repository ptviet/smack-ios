
import UIKit

class MessageCell: UITableViewCell {
  
  // Outlets
  @IBOutlet weak var userImage: CircleImage!
  @IBOutlet weak var usernameLbl: UILabel!
  @IBOutlet weak var timestampLbl: UILabel!
  @IBOutlet weak var messageLbl: UILabel!
  
  override func awakeFromNib() {
    super.awakeFromNib()

  }
  
  func configureCell(message: Message) {
    messageLbl.text = message.messageBody
    usernameLbl.text = message.userName
    userImage.image = UIImage(named: message.userAvatar)
    userImage.backgroundColor = UserDataService.instance.returnUIColor(components: message.userAvatarColor)
    
  }

  
}
