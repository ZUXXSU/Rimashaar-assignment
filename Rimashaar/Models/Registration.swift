import Foundation

struct RegistrationRequest: Codable, Hashable {
    let appVersion: String
    let deviceModel: String
    let deviceToken: String
    let deviceType: String
    let dob: String
    let email: String
    let firstName: String
    let gender: String
    let lastName: String
    let newsletterSubscribed: Int
    let osVersion: String
    let password: String
    let phone: String
    let phoneCode: String

    enum CodingKeys: String, CodingKey {
        case appVersion = "app_version"
        case deviceModel = "device_model"
        case deviceToken = "device_token"
        case deviceType = "device_type"
        case dob, email, gender, password, phone
        case firstName = "first_name"
        case lastName = "last_name"
        case newsletterSubscribed = "newsletter_subscribed"
        case osVersion = "os_version"
        case phoneCode = "phone_code"
    }
}

struct RegistrationResponse: Codable {
    let success: Bool
    let status: Int
    let message: String?
    let data: UserData?

    struct UserData: Codable, Hashable {
        let id: Int?
        let firstName: String?
        let lastName: String?
        let gender: String?
        let dob: String?
        let email: String?
        let image: String?
        let phoneCode: String?
        let phone: String?
        let code: String?
        var isPhoneVerified: FlexibleBool?
        var isEmailVerified: FlexibleBool?
        let isSocialRegister: Int?
        let socialRegisterType: String?
        let deviceToken: String?
        let deviceType: String?
        let deviceModel: String?
        let appVersion: String?
        let osVersion: String?
        var pushEnabled: FlexibleBool?
        let newsletterSubscribed: Int?
        let createDate: String?

        enum CodingKeys: String, CodingKey {
            case id, gender, dob, email, image, phone, code
            case firstName = "first_name"
            case lastName = "last_name"
            case phoneCode = "phone_code"
            case isPhoneVerified = "is_phone_verified"
            case isEmailVerified = "is_email_verified"
            case isSocialRegister = "is_social_register"
            case socialRegisterType = "social_register_type"
            case deviceToken = "device_token"
            case deviceType = "device_type"
            case deviceModel = "device_model"
            case appVersion = "app_version"
            case osVersion = "os_version"
            case pushEnabled = "push_enabled"
            case newsletterSubscribed = "newsletter_subscribed"
            case createDate = "create_date"
        }
    }
}
