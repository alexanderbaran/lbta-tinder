//
//  Advertiser.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 13/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit

struct Advertiser: ProducesCardViewModel {
    let title: String
    let brandName: String
    let posterPhotoName: String
    
    func toCardViewModel() -> CardViewModel {
        let attributedString = NSMutableAttributedString(string: title, attributes: [.font: UIFont.systemFont(ofSize: 34, weight: .heavy)])
        attributedString.append(NSAttributedString(string: "\n\(brandName)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .semibold)]))
        return CardViewModel(uid: "", imageNames: [posterPhotoName], attributedString: attributedString, textAlignment: .center)
    }
}
