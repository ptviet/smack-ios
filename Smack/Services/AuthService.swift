
import Foundation
import Alamofire
import SwiftyJSON

class AuthService {
  static let instance = AuthService()
  
  let defaults = UserDefaults.standard
  
  var isLoggedIn: Bool {
    get { return defaults.bool(forKey: LOGGED_IN_KEY) }
    
    set { defaults.set(newValue, forKey: LOGGED_IN_KEY) }
  }
  
  var authToken: String {
    get { return defaults.value(forKey: TOKEN_KEY) as! String }
    
    set { defaults.set(newValue, forKey: TOKEN_KEY) }
  }
  
  var userEmail: String {
    get { return defaults.value(forKey: USER_EMAIL) as! String }
    
    set { defaults.set(newValue, forKey: USER_EMAIL) }
  }
  
  func registerUser(email: String, password: String, completion: @escaping CompletionHandler) {
    
    let lowerCaseEmail = email.lowercased()
    
    let body: [String: Any] = [
      "email": lowerCaseEmail,
      "password": password
    ]
    
    Alamofire.request(REGISTER_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER)
      .responseString { (response) in
        if response.result.error == nil {
          completion(true)
        } else {
          completion(false)
          debugPrint(response.result.error as Any)
        }
    }
    
  }
  
  func loginUser(email: String, password: String, completion: @escaping CompletionHandler) {
    let lowerCaseEmail = email.lowercased()
    
    let body: [String: Any] = [
      "email": lowerCaseEmail,
      "password": password
    ]
    
    Alamofire.request(LOGIN_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: HEADER)
      .responseJSON { (response) in
        if response.result.error == nil {
          //          if let json = response.result.value as? Dictionary<String, Any> {
          //
          //            if let email = json["user"] as? String {
          //              self.userEmail = email
          //            }
          //
          //            if let token = json["token"] as? String {
          //              self.authToken = token
          //            }
          //          }
          
          // Rewrite using SwiftyJSON
          guard let data = response.data else { return }
          do {
            let json = try JSON(data: data)
            self.userEmail = json["user"].stringValue
            self.authToken = json["token"].stringValue
            self.isLoggedIn = true
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
  
  func createUser(name: String, email: String, avatarName: String, avatarColor: String, completion: @escaping CompletionHandler) {
    
    let lowerCaseEmail = email.lowercased()
    
    let body: [String: Any] = [
      "name": name,
      "email": lowerCaseEmail,
      "avatarName": avatarName,
      "avatarColor": avatarColor
    ]
    
    Alamofire.request(ADD_USER_URL, method: .post, parameters: body, encoding: JSONEncoding.default, headers: BEARER_HEADER)
      .responseJSON { (response) in
        if response.result.error == nil {
          guard let data = response.data else { return }
          self.setUserInfo(data: data)
          completion(true)
        } else {
          completion(false)
          debugPrint(response.result.error as Any)
        }
        
    }
  }
  
  func findUserByEmail(completion: @escaping CompletionHandler) {
    
    Alamofire.request("\(FIND_USER_BY_EMAIL_URL)\(userEmail)", method: .get, parameters: nil, encoding: JSONEncoding.default, headers: BEARER_HEADER)
      .responseJSON { (response) in
        if response.result.error == nil {
          guard let data = response.data else { return }
          self.setUserInfo(data: data)
          completion(true)
        } else {
          completion(false)
          debugPrint(response.result.error as Any)
        }
        
    }
    
  }
  
  func setUserInfo(data: Data) {
    do {
      let json = try JSON(data: data)
      UserDataService.instance.setUserData(id: json["_id"].stringValue,
                                           avatarColor: json["avatarColor"].stringValue,
                                           avatarName: json["avatarName"].stringValue,
                                           email: json["email"].stringValue,
                                           name: json["name"].stringValue)
      
      
    } catch {
      print(error)
    }
  }

}
