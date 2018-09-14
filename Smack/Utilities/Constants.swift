
import Foundation

typealias CompletionHandler = (_ Success: Bool) -> ()

// URL
let BASE_URL = "https://spsmack.herokuapp.com/v1/"
let REGISTER_URL = "\(BASE_URL)account/register"
let LOGIN_URL = "\(BASE_URL)account/login"
let ADD_USER_URL = "\(BASE_URL)user/add"
let FIND_USER_BY_EMAIL_URL = "\(BASE_URL)user/byEmail/"
let GET_CHANNELS_URL = "\(BASE_URL)channel/"
let GET_MESSAGES_URL = "\(BASE_URL)message/byChannel/"

// Colors
let smackPurplePlaceholder = #colorLiteral(red: 0.2588235294, green: 0.3294117647, blue: 0.7254901961, alpha: 0.5)

// Notification Constants
let NOTI_USER_DATA_DID_CHANGE = Notification.Name("notiUserDataChanged")
let NOTI_CHANNELS_LOADED = Notification.Name("notiChannelsLoaded")
let NOTI_CHANNEL_SELECTED = Notification.Name("notiChannelSelected")
let NOTI_MESSAGES_LOADED = Notification.Name("notiMessagesLoaded")

// Segues
let TO_LOGIN = "toLogin"
let TO_CREATE_ACCOUNT = "toCreateAccount"
let TO_AVATAR_PICKER = "toAvatarPicker"
let UNWIND = "unwindToChannel"

// User Defaults
let TOKEN_KEY = "token"
let LOGGED_IN_KEY = "loggedIn"
let USER_EMAIL = "userEmail"

// Headers

let HEADER = [
  "Content-Type": "application/json; charset=utf-8"
]

let BEARER_HEADER = [
  "Authorization": "Bearer \(AuthService.instance.authToken)",
  "Content-Type": "application/json; charset=utf-8"
]
