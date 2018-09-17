
import UIKit

class ChannelVC: UIViewController, UITableViewDelegate, UITableViewDataSource {
  
  // Outlets
  @IBOutlet weak var loginBtn: UIButton!
  @IBOutlet weak var userImage: CircleImage!
  @IBOutlet weak var tableView: UITableView!
  @IBOutlet weak var addChannelBtn: UIButton!
  
  override func viewDidLoad() {
    super.viewDidLoad()
    tableView.delegate = self
    tableView.dataSource = self
    self.revealViewController().rearViewRevealWidth = self.view.frame.size.width - 60
    
    NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.userDataDidChange(_:)), name: NOTI_USER_DATA_DID_CHANGE, object: nil)
    
    NotificationCenter.default.addObserver(self, selector: #selector(ChannelVC.channelsLoaded(_:)), name: NOTI_CHANNELS_LOADED, object: nil)
    
    SocketService.instance.getChannel { (success) in
      if success {
        self.tableView.reloadData()
      }
    }
    
    SocketService.instance.getChatMessage { (newMessage) in
      if newMessage.channelId != MessageService.instance.selectedChannel?._id && AuthService.instance.isLoggedIn {
        MessageService.instance.unreadChannels.append(newMessage.channelId)
        self.tableView.reloadData()
      }
    }
    
  }
  
  override func viewDidAppear(_ animated: Bool) {
    setupUserInfo()
  }
  
  @IBAction func onAddChannelPressed(_ sender: Any) {
    if AuthService.instance.isLoggedIn {
      let addChannel = AddChannelVC()
      addChannel.modalPresentationStyle = .custom
      present(addChannel, animated: true, completion: nil)
    }
  }
  
  @IBAction func onLoginBtnPressed(_ sender: Any) {
    if AuthService.instance.isLoggedIn {
      // Show profile page
      let profile = ProfileVC()
      profile.modalPresentationStyle = .custom
      present(profile, animated: true, completion: nil)
    } else {
      // Go to login
      performSegue(withIdentifier: TO_LOGIN, sender: nil)
    }
    
  }
  
  @IBAction func prepareForUnwind(segue: UIStoryboardSegue) {
    
  }
  
  @objc func userDataDidChange(_ noti: Notification) {
    setupUserInfo()
  }
  
  @objc func channelsLoaded(_ noti: Notification) {
    tableView.reloadData()
  }
  
  func setupUserInfo() {
    if AuthService.instance.isLoggedIn {
      loginBtn.setTitle(UserDataService.instance.name, for: .normal)
      userImage.image = UIImage(named: UserDataService.instance.avatarName)
      userImage.backgroundColor = UserDataService.instance.returnUIColor(components: UserDataService.instance.avatarColor)
      addChannelBtn.isHidden = false
    } else {
      loginBtn.setTitle("Login", for: .normal)
      userImage.image = UIImage(named: "menuProfileIcon")
      userImage.backgroundColor = UIColor.clear
      addChannelBtn.isHidden = true
      tableView.reloadData()
    }
  }
  
  func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
    if let cell = tableView.dequeueReusableCell(withIdentifier: "channelCell", for: indexPath) as? ChannelCell {
      let channel = MessageService.instance.channels[indexPath.row]
      cell.configureCell(channel: channel)
      return cell
    } else {
      return UITableViewCell()
    }
  }
  
  func numberOfSections(in tableView: UITableView) -> Int {
    return 1
  }
  
  func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
    return MessageService.instance.channels.count
  }
  
  func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
    let channel = MessageService.instance.channels[indexPath.row]
    MessageService.instance.selectedChannel = channel
    
    if MessageService.instance.unreadChannels.count > 0 {
      MessageService.instance.unreadChannels = MessageService.instance.unreadChannels.filter{$0 != channel._id}
    }
    
    let index = IndexPath(row: indexPath.row, section: 0)
    tableView.reloadRows(at: [index], with: .none)
    tableView.selectRow(at: index, animated: false, scrollPosition: .none)
    
    NotificationCenter.default.post(name: NOTI_CHANNEL_SELECTED, object: nil)
    
    self.revealViewController().revealToggle(animated: true)
  }
  
}
