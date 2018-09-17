
import Foundation
import Alamofire
import SwiftyJSON

class MessageService {
  static let instance = MessageService()
  
  var channels = [Channel]()
  var selectedChannel: Channel?
  var unreadChannels = [String]()
  var messages = [Message]()
  
  func findAllChannels(completion: @escaping CompletionHandler) {
    Alamofire.request(GET_CHANNELS_URL, method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER)
      .responseJSON { (response) in
        if response.result.error == nil {
          guard let data = response.data else { return }
          do {
            //            if let json = try JSON(data: data).array {
            //              for item in json {
            //                let name = item["name"].stringValue
            //                let desc = item["description"].stringValue
            //                let id = item["_id"].stringValue
            //
            //                let channel = Channel(name: name, desciption: desc, _id: id)
            //                self.channels.append(channel)
            //              }
            //              completion(true)
            //            }
            
            // Rewrite with Swift 4 Decodable
            self.channels = try JSONDecoder().decode([Channel].self, from: data)
            
            NotificationCenter.default.post(name: NOTI_CHANNELS_LOADED, object: nil)
            completion(true)
            
          } catch {
            print(error)
          }
        } else {
          completion(false)
          debugPrint(response.result.error as Any)
        }
    }
  }
  
  func clearChannels() {
    channels.removeAll()
  }
  
  func findAddMessagesForChannel(channelId: String, completion: @escaping CompletionHandler) {
    Alamofire.request("\(GET_MESSAGES_URL)\(channelId)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER)
      .responseJSON { (response) in
        if response.result.error == nil {
          self.clearMessages()
          guard let data = response.data else { return }
          do {
            // Swift 4 Decodable
            self.messages = try JSONDecoder().decode([Message].self, from: data)
            
            NotificationCenter.default.post(name: NOTI_MESSAGES_LOADED, object: nil)
            completion(true)
          } catch {
            print(error)
          }
        } else {
          completion(false)
          debugPrint(response.result.error as Any)
        }
    }
    
  }
  
  func clearMessages() {
    messages.removeAll()
  }
  
}
