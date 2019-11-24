//
//  MessagesNavBar.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 23/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

class MessagesNavBar: UIView {
    
//    let userProfileImageView = UIImageView(image: UIImage(named: "kelly1"), contentMode: .scaleAspectFill)
    let userProfileImageView = CircularImageView(width: 44, image: UIImage(named: "kelly1"))
    let nameLabel = UILabel(text: "USERNAME", font: .systemFont(ofSize: 16))
    
    let backButton = UIButton(image: UIImage(named: "back")!, tintColor: .red)
    let flagButton = UIButton(image: UIImage(named: "flag")!, tintColor: .red)
    
    private let match: Match
    
//    init(match: Match) {
//        self.match = match
//        super.init()
//    }
    
//    override init(frame: CGRect) {
    init(match: Match) {
        self.match = match
//        super.init(frame: frame)
        super.init(frame: .zero) // Since we are using autolayout we don't need to pass a frame.
        
        nameLabel.text = match.name
        userProfileImageView.sd_setImage(with: URL(string: match.profileImageUrl))
        
        backgroundColor = .white
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
//        userProfileImageView.constrainWidth(44)
//        userProfileImageView.constrainHeight(44)
//        userProfileImageView.clipsToBounds = true
//        userProfileImageView.layer.cornerRadius = 44 / 2
        
        let middleStack = hstack(
            stack(
                userProfileImageView,
                nameLabel,
                spacing: 8,
                alignment: .center
            ),
            alignment: .center
        )
        
        hstack(
            backButton.withWidth(50),
            middleStack,
            flagButton
        ).withMargins(.init(top: 0, left: 4, bottom: 0, right: 12))
        

    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
