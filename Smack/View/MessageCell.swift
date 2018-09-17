
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
    
    guard var isoDate = message.timeStamp else { return }
    let end = isoDate.index(isoDate.endIndex, offsetBy: -5)
    isoDate = String(isoDate[..<end])
    
    let isoFormater = ISO8601DateFormatter()
    let chatDate = isoFormater.date(from: isoDate.appending("Z"))
    
    let newFormatter = DateFormatter()
    newFormatter.dateFormat = "MMM d, h:mm a"
    
    if let finalTimestamp = chatDate {
      let final = newFormatter.string(from: finalTimestamp)
      timestampLbl.text = final
      
    }
    
  }

  
}
