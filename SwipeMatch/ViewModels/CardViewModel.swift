//
//  CardViewModel.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 11/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit

protocol ProducesCardViewModel {
    func toCardViewModel() -> CardViewModel
}

// View Model is supposed to represent the State of our View.
class CardViewModel {
    // We'll define the properties that our view will display/render out.
    let uid: String
    let imageUrls: [String]
    let attributedString: NSAttributedString
    let textAlignment: NSTextAlignment
    
    // class requires init, struct has by default.
    init(uid: String, imageNames: [String], attributedString: NSAttributedString, textAlignment: NSTextAlignment) {
        self.uid = uid
        self.imageUrls = imageNames
        self.attributedString = attributedString
        self.textAlignment = textAlignment
    }
    
    private var imageIndex = 0 {
        didSet {
//            let imageName = imageNames[imageIndex]
//            let image = UIImage(named: imageName)
            //            imageIndexObserver?(image ?? UIImage())
            let imageURL = imageUrls[imageIndex]
            imageIndexObserver?(imageIndex, imageURL)
        }
    }
    
    // Reactive Programming
    //    var imageIndexObserver: ((UIImage) -> ())?
//    var imageIndexObserver: ((Int, UIImage?) -> ())? // Does not work anymore because urls from firestore instead of images
    var imageIndexObserver: ((Int, String?) -> ())?
    
    /* Whenever you modify the struct properties inside of your struct CardViewModel here Swift wants you to apply this mutating bit of syntax, now this mutating
     syntax is actually really difficult to work with, to really get a sense of how CardViewModels work or ViewModels in general it is much easier to specify
     your objects as a class instead. */
    func advanceToNextPhoto() {
        imageIndex = min(imageIndex + 1, imageUrls.count - 1)
    }
    
    func goToPreviousPhoto() {
        imageIndex = max(imageIndex - 1, 0)
    }
}
