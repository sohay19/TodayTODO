//
//  FirebaseManager.swift
//  dailytimetable
//
//  Created by 소하 on 2022/09/21.
//

import Foundation
import FirebaseDatabase
import FirebaseCore
import FirebaseAuth
import CryptoKit

struct Response : Codable {
    let success:Bool
    let message:String
    let result:[String:[String:String]]
    
    init(success:Bool, message:String, result:[String:[String:String]]) {
        self.success = success
        self.message = message
        self.result = result
    }
}

class FirebaseManager {
    static let shared = FirebaseManager()
    private init() { }
    
    private var database = Database.database().reference()
    private var currentNonce = ""
    var authUser:User? {
        get {
            guard let auth = Auth.auth().currentUser else {
                return nil
            }
            return auth
        }
    }
}

//MARK: - REST API
extension FirebaseManager {
    //
    func sendToken(_ data:[String:String]) {
        guard let uuid = data["uuid"], let token = data["token"] else {
            return
        }
        requestPost(url: "https://codesoha.com/token/send", param: ["uuid":uuid, "token":token], completion: { isSuccess, data in
            print("send Token is \(isSuccess)")
        })
    }
    //
    func loadNotice(completion: @escaping (Bool, [String:[String:String]]) -> Void) {
        requestGet(url: "https://codesoha.com/notice", completion: completion)
    }
    //
    func loadFAQ(completion: @escaping (Bool, [String:[String:String]]) -> Void) {
        requestGet(url: "https://codesoha.com/faq", completion: completion)
    }
    //GET
    private func requestGet(url: String, completion: @escaping (Bool, [String:[String:String]]) -> Void) {
        guard let url = URL(string: url) else {
            print("URL Error")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "GET"
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("GET Error")
                return
            }
            guard let data = data else {
                print("data is nil")
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("request is failed")
                return
            }
            guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                print("JSON Parsing Error")
                return
            }
            let success = jsonData["success"] as? Bool ?? false
            let message = jsonData["message"] as? String ?? ""
            let result = jsonData["result"] as? [String:[String:String]] ?? [:]
            let responseData = Response(success: success, message: message, result: result)
            
            completion(responseData.success, responseData.result)
        }.resume()
    }
    //POST
    private func requestPost(url: String, param:[String: String], completion: @escaping (Bool, [String:[String:String]]) -> Void) {
        let sendMsg = try! JSONSerialization.data(withJSONObject: param, options: [])
        
        guard let url = URL(string: url) else {
            print("URL Error")
            return
        }
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        request.httpBody = sendMsg
        
        URLSession.shared.dataTask(with: request) { data, response, error in
            guard error == nil else {
                print("POST Error")
                return
            }
            guard let data = data else {
                print("data is nil")
                return
            }
            guard let response = response as? HTTPURLResponse, (200..<300) ~= response.statusCode else {
                print("request is failed")
                return
            }
            guard let jsonData = try? JSONSerialization.jsonObject(with: data, options: []) as? [String:Any] else {
                print("JSON Parsing Error")
                return
            }
            let success = jsonData["success"] as? Bool ?? false
            let message = jsonData["message"] as? String ?? ""
            let result = jsonData["result"] as? [String:[String:String]] ?? [:]
            let responseData = Response(success: success, message: message, result: result)
            
            completion(responseData.success, responseData.result)
        }.resume()
    }
}
//MARK: - Apple Login을 위한 추가 함수
extension FirebaseManager {
    func shaNonce() -> String {
        currentNonce = randomNonce()
        return sha256(currentNonce)
    }
    
    func getNonce() -> String{
        return currentNonce
    }
    
    private func randomNonce(length: Int = 32) -> String {
        precondition(length > 0)
        let charset: [Character] =
        Array("0123456789ABCDEFGHIJKLMNOPQRSTUVXYZabcdefghijklmnopqrstuvwxyz-._")
        var result = ""
        var remainingLength = length
        
        while remainingLength > 0 {
            let randoms: [UInt8] = (0 ..< 16).map { _ in
                var random: UInt8 = 0
                let errorCode = SecRandomCopyBytes(kSecRandomDefault, 1, &random)
                if errorCode != errSecSuccess {
                    fatalError(
                        "Unable to generate nonce. SecRandomCopyBytes failed with OSStatus \(errorCode)"
                    )
                }
                return random
            }
            
            randoms.forEach { random in
                if remainingLength == 0 {
                    return
                }
                
                if random < charset.count {
                    result.append(charset[Int(random)])
                    remainingLength -= 1
                }
            }
        }
        
        return result
    }
    
    @available(iOS 13, *)
    private func sha256(_ input: String) -> String {
        let inputData = Data(input.utf8)
        let hashedData = SHA256.hash(data: inputData)
        let hashString = hashedData.compactMap {
            String(format: "%02x", $0)
        }.joined()
        
        return hashString
    }
}
