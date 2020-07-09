/// Copyright (c) 2018 Razeware LLC
///
/// Permission is hereby granted, free of charge, to any person obtaining a copy
/// of this software and associated documentation files (the "Software"), to deal
/// in the Software without restriction, including without limitation the rights
/// to use, copy, modify, merge, publish, distribute, sublicense, and/or sell
/// copies of the Software, and to permit persons to whom the Software is
/// furnished to do so, subject to the following conditions:
///
/// The above copyright notice and this permission notice shall be included in
/// all copies or substantial portions of the Software.
///
/// Notwithstanding the foregoing, you may not use, copy, modify, merge, publish,
/// distribute, sublicense, create a derivative work, and/or sell copies of the
/// Software in any work that is designed, intended, or marketed for pedagogical or
/// instructional purposes related to programming, coding, application development,
/// or information technology.  Permission for such use, copying, modification,
/// merger, publication, distribution, sublicensing, creation of derivative works,
/// or sale is expressly withheld.
///
/// THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR
/// IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY,
/// FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE
/// AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER
/// LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM,
/// OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN
/// THE SOFTWARE.

import FirebaseFirestore

struct Channel {
  
  let id: String?
  let name: String
  let createrName:String
  let createrId:String
  let createrProfilePicUrl:String
  let createUserName:String
  let profilePicUrl:String
  let userName:String
  let timeStamp:Date
  var userIds = Array<String>()
    init(name: String,createrName:String,createrId:String,userIds: Array<String>, userName:String, profilePicUrl:String, createrProfilePicUrl:String, createUserName:String) {
    id = nil
    
    self.userIds = userIds
    self.name = name
    self.userName = userName
    self.profilePicUrl = profilePicUrl
    self.timeStamp = Date()
    self.createrProfilePicUrl = createrProfilePicUrl
    self.createUserName = createUserName
    self.createrName = createrName
    self.createrId = createrId
  }
  
  init?(document: QueryDocumentSnapshot) {
    let data = document.data()

    guard let name = data["name"] as? String else {
      return nil
    }
    
    createrId = data["createrId"] as! String
    createrName = data["createrName"] as! String
    userIds = data["userIds"] as! Array<String>
    self.userName = data["userName"] as! String
    self.profilePicUrl = data["profilePicUrl"] as! String
    self.timeStamp = (data["timeStamp"] as! Timestamp).dateValue()
    self.createrProfilePicUrl = data["createrProfilePicUrl"] as! String
    self.createUserName = data["createrUserName"] as! String
    id = document.documentID
    self.name = name
  }
}

extension Channel: DatabaseRepresentation {
  
  var representation: [String : Any] {
    var rep = [String : Any]()
    rep["name"] = name
    rep["createrName"] = createrName
    rep["createrId"] = createrId
    
    rep["userName"] = userName
    rep["profilePicUrl"] = profilePicUrl
    rep["timeStamp"] = timeStamp
    rep["createrProfilePicUrl"] = createrProfilePicUrl
    rep["createrUserName"] = createUserName
    
    if let id = id {
      rep["id"] = id
    }
    rep["userIds"] = userIds
    return rep
  }
  
}

extension Channel: Comparable {
  
  static func == (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.id == rhs.id
  }
  
  static func < (lhs: Channel, rhs: Channel) -> Bool {
    return lhs.name < rhs.name
  }

}
