
import UIKit

class ChatVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Outlets
  @IBOutlet weak var menuBtn: UIButton!
  @IBOutlet weak var channelNameLbl: UILabel!
  @IBOutlet weak var messageTxtBox: UITextField!
  @IBOutlet weak var sendBtn: UIButton!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var userIsTypingLbl: UILabel!
  
  // Variables
  var isTyping = false
  
  override func viewDidLoad() {
    super.viewDidLoad()
    view.bindToKeyboard()
    
    tableView.delegate = self
    tableView.dataSource = self
    
    tableView.estimatedRowHeight = 80
    tableView.rowHeight = UITableViewAutomaticDimension
    
    displayTitle()
    hideTextbox()
    
    
    
    menuBtn.addTarget(self.revealViewController(),
                      action: #selector(SWRevealViewController.revealToggle(_:)),
                      for: .touchUpInside)
    
    self.view.addGestureRecognizer(self.revealViewController().panGestureRecognizer())
    self.view.addGestureRecognizer(self.revealViewController().tapGestureRecognizer())
    
    NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.userDataDidChange(_:)), name: NOTI_USER_DATA_DID_CHANGE, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(ChatVC.channelSelected(_:)), name: NOTI_CHANNEL_SELECTED, object: nil)
    
    SocketService.instance.getChatMessage { (success) in
      if success {
        self.tableView.reloadData()
        self.scrollToBottom()
      }
    }
    
    SocketService.instance.getTypingUsers { (typingUsers) in
      guard let channelId = MessageService.instance.selectedChannel?._id else { return }
      var names = ""
      var numberOfTypers = 0
      for (typingUser, channel) in typingUsers {
        if typingUser != UserDataService.instance.name && channel == channelId {
          if names == "" {
            names = typingUser
          } else {
            names = "\(names), \(typingUser)"
          }
          numberOfTypers += 1
        }
      }
      
      if numberOfTypers > 0 && AuthService.instance.isLoggedIn {
        var verb = "is"
        if numberOfTypers > 1 {
          verb = "are"
        }
        
        self.userIsTypingLbl.text = "\(names) \(verb) typing..."
        
      } else {
        self.userIsTypingLbl.text = ""
      }
      
    }
    
    if AuthService.instance.isLoggedIn {
      AuthService.instance.findUserByEmail { (success) in
        NotificationCenter.default.post(name: NOTI_USER_DATA_DID_CHANGE, object: nil)
      }
    }
    
    let tap = UITapGestureRecognizer(target: self, action: #selector(ChatVC.handleTap))
    view.addGestureRecognizer(tap)
    
  }
  
  func scrollToBottom() {
    if MessageService.instance.messages.count > 0 {
      let endIndex = IndexPath(row: MessageService.instance.messages.count - 1, section: 0)
      tableView.scrollToRow(at: endIndex, at: .bottom, animated: true)
    }
  }
  
  @objc func handleTap() {
    view.endEditing(true)
  }
  
  @objc func userDataDidChange(_ noti: Notification) {
    if AuthService.instance.isLoggedIn {
      onLoginGetMessages()
    } else {
      tableView.reloadData()
    }
    
    displayTitle()
    
  }
  
  @objc func channelSelected(_ noti: Notification) {
    updateWithChannel()
  }
  
  func updateWithChannel() {
    displayTitle()
    getMessages()
  }
  
  func onLoginGetMessages() {
    MessageService.instance.findAllChannels { (success) in
      if success {
        if MessageService.instance.channels.count > 0 {
          MessageService.instance.selectedChannel = MessageService.instance.channels[0]
          self.updateWithChannel()
          self.showTextbox()
        } else {
          self.channelNameLbl.text = "No channels found."
          self.hideTextbox()
        }
      }
    }
  }
  
  func getMessages() {
    guard let channelId = MessageService.instance.selectedChannel?._id else { return }
    MessageService.instance.findAddMessagesForChannel(channelId: channelId) { (success) in
      if success {
        self.tableView.reloadData()
      }
    }
  }
  
  func displayTitle() {
    if AuthService.instance.isLoggedIn {
      let channelName = MessageService.instance.selectedChannel?.name ?? "Smack"
      channelNameLbl.text = "\(channelName)"
    } else {
      channelNameLbl.text = "Please Log In"
    }
  }
  
  func hideTextbox() {
    messageTxtBox.isHidden = true
    sendBtn.isHidden = true
  }
  
  func showTextbox() {
    messageTxtBox.isHidden = false
  }
  
  @IBAction func messageBoxEditing(_ sender: Any) {
    guard let channelId = MessageService.instance.selectedChannel?._id else { return }
    if messageTxtBox.text == "" {
      isTyping = false
      sendBtn.isHidden = true
      SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelId)
    } else {
      if isTyping == false {
        sendBtn.isHidden = false
      }
      isTyping = true
      SocketService.instance.socket.emit("startType", UserDataService.instance.name, channelId)
    }
  }
  
  @IBAction func onSendBtnPressed(_ sender: Any) {
    if AuthService.instance.isLoggedIn {
      guard let channelId = MessageService.instance.selectedChannel?._id else { return }
      guard let message = messageTxtBox.text else { return }
      
      SocketService.instance.addMessage(messageBody: message, userId: UserDataService.instance.id, channelId: channelId) { (success) in
        if success {
          self.messageTxtBox.text = ""
          self.messageTxtBox.resignFirstResponder()
          SocketService.instance.socket.emit("stopType", UserDataService.instance.name, channelId)
        }
      }
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MessageService.instance.messages.count
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "messageCell", for: indexPath) as? MessageCell {
      let message = MessageService.instance.messages[indexPath.row]
      cell.configureCell(message: message)
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  
}
