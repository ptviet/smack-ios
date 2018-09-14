
import UIKit
import SocketIO

class SocketService: NSObject {

  static let instance = SocketService()
  
  let manager: SocketManager
  let socket: SocketIOClient
  
  override init() {
    self.manager = SocketManager(socketURL: URL(string: BASE_URL)!)
    self.socket = manager.defaultSocket
    super.init()
  }
  
  func establishConnection() {
    socket.connect()
  }
  
  func closeConnection() {
    socket.disconnect()
  }
  
  func addChannel(channelName: String, channelDescription: String, completion: @escaping CompletionHandler) {
    socket.emit("newChannel", channelName, channelDescription)
    completion(true)
  }
  
  func getChannel(completion: @escaping CompletionHandler) {
    socket.on("channelCreated") { (dataArray, ack) in
      guard let channelName = dataArray[0] as? String else { return }
      guard let channelDesc = dataArray[1] as? String else { return }
      guard let channelID = dataArray[2] as? String else { return }
      
      let newChannel = Channel(_id: channelID, name: channelName, desciption: channelDesc, __v: 0)
      MessageService.instance.channels.append(newChannel)
      completion(true)
    }
  }
  
  func addMessage(messageBody: String, userId: String, channelId: String, completion: @escaping CompletionHandler) {
    let user = UserDataService.instance
    socket.emit("newMessage", messageBody, userId, channelId, user.name, user.avatarName, user.avatarColor)
    completion(true)
  }
  
  func getChatMessage(completion: @escaping CompletionHandler) {
    socket.on("messageCreated") { (dataArray, ack) in

      guard let channelId = dataArray[2] as? String else { return }
      
      if channelId == MessageService.instance.selectedChannel?._id &&
        AuthService.instance.isLoggedIn {
        
        guard let messageBody = dataArray[0] as? String else { return }
        guard let userId = dataArray[1] as? String else { return }
        guard let userName = dataArray[3] as? String else { return }
        guard let userAvatar = dataArray[4] as? String else { return }
        guard let userAvatarColor = dataArray[5] as? String else { return }
        guard let id = dataArray[6] as? String else { return }
        guard let timestamp = dataArray[7] as? String else { return }
        
        let newMessage = Message(_id: id, messageBody: messageBody, userId: userId, channelId: channelId, userName: userName, userAvatar: userAvatar, userAvatarColor: userAvatarColor, __v: 0, timeStamp: timestamp)
        
        MessageService.instance.messages.append(newMessage)
        completion(true)
      } else {
        completion(false)
      }
      
    }
    
  }
  
  func getTypingUsers(_ completionHandler: @escaping (_ typingUsers: [String: String]) -> Void) {
    socket.on("userTypingUpdate") { (dataArray, ack) in
      guard let typingUsers = dataArray[0] as? [String: String] else { return }
      completionHandler(typingUsers)
    }
    
  }
  
}
