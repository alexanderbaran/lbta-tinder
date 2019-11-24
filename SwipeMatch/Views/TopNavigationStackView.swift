//
//  TopNavigationStackView.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 11/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit

class TopNavigationStackView: UIStackView {
    
    let settingsButton = UIButton(type: .system)
    let messagesButton = UIButton(type: .system)
    let fireImageView = UIImageView(image: UIImage(named: "app_icon"))
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        heightAnchor.constraint(equalToConstant: 80).isActive = true
        
        fireImageView.contentMode = .scaleAspectFit
        
        settingsButton.setImage(UIImage(named: "top_left_profile")?.withRenderingMode(.alwaysOriginal), for: .normal)
        messagesButton.setImage(UIImage(named: "top_right_messages")?.withRenderingMode(.alwaysOriginal), for: .normal)
        
        [settingsButton, UIView(), fireImageView, UIView(), messagesButton].forEach { (view: UIView) in
            addArrangedSubview(view)
        }
        
        distribution = .equalCentering
        
        isLayoutMarginsRelativeArrangement = true
        layoutMargins = .init(top: 0, left: 16, bottom: 0, right: 16)
        
        //        let buttons = [UIImage(named: "top_left_profile"), UIImage(named: "app_icon"), UIImage(named: "top_right_messages")].map { (image: UIImage?) -> UIView in
        //            let button = UIButton(type: .system)
        //            button.setImage(image?.withRenderingMode(.alwaysOriginal), for: .normal)
        //            return button
        //        }
        //
        //        buttons.forEach { (view: UIView) in
        //            addArrangedSubview(view)
        //        }
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
