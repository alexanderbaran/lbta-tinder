//
//  User.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 11/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit

// Struct comes with default structure.
struct User: ProducesCardViewModel {
    // Defining our properties for our model layer.
    var name: String?
    var age: Int?
    var profession: String?
//    let imageNames: [String]
    var imageUrl1: String?
    var imageUrl2: String?
    var imageUrl3: String?
    var uid: String?
    
    var minSeekingAge: Int?
    var maxSeekingAge: Int?
    
    init(dictionary: [String: Any]) {
        // We'll initialize our user here.
        self.name = dictionary["fullName"] as? String ?? ""
        self.age = dictionary["age"] as? Int
        self.profession = dictionary["profession"] as? String
        
        let imageUrl1 = dictionary["imageUrl1"] as? String
        self.imageUrl1 = imageUrl1
//        self.imageNames = [imageUrl1]
        // No need to nil coalesce optional vars
        self.imageUrl2 = dictionary["imageUrl2"] as? String
        self.imageUrl3 = dictionary["imageUrl3"] as? String
        self.uid = dictionary["uid"] as? String ?? ""
        self.minSeekingAge = dictionary["minSeekingAge"] as? Int
        self.maxSeekingAge = dictionary["maxSeekingAge"] as? Int
    }
    
    func toCardViewModel() -> CardViewModel {
        let attributedText = NSMutableAttributedString(string: name ?? "", attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        let ageString = age != nil ? "\(age!)" : "N\\A"
        attributedText.append(NSAttributedString(string: " \(ageString)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        let professionString = profession != nil ? profession! : "Not available"
        attributedText.append(NSAttributedString(string: "\n\(professionString)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        var imageUrls = [String]() // Empty string array.
        if let url = imageUrl1 { imageUrls.append(url) }
        if let url = imageUrl2 { imageUrls.append(url) }
        if let url = imageUrl3 { imageUrls.append(url) }
        return CardViewModel(uid: self.uid ?? "", imageNames: imageUrls, attributedString: attributedText, textAlignment: .left)
    }
}
