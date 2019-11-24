//
//  MatchesNavBar.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 21/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

class MatchesNavBar: UIView {
    
    let backButton = UIButton(image: UIImage(named: "app_icon")!, tintColor: .lightGray)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        backgroundColor = .white // For shadow to show
        
        let iconImageView = UIImageView(image: UIImage(named: "top_messages_icon")?.withRenderingMode(.alwaysTemplate), contentMode: .scaleAspectFit)
        iconImageView.tintColor = #colorLiteral(red: 1, green: 0.3550357039, blue: 0.4449895413, alpha: 1)
        let color = #colorLiteral(red: 1, green: 0.3550357039, blue: 0.4449895413, alpha: 1)
        let messagesLabel = UILabel(text: "Messages", font: UIFont.boldSystemFont(ofSize: 20), textColor: color, textAlignment: .center)
        let feedLabel = UILabel(text: "Feed", font: UIFont.boldSystemFont(ofSize: 20), textColor: .gray, textAlignment: .center)
//        navBar.backgroundColor = .white
//        navBar.layer.shadowOpacity
        setupShadow(opacity: 0.2, radius: 8, offset: .init(width: 0, height: 10), color: .init(white: 0, alpha: 0.3))
        
        stack(iconImageView.withHeight(44), hstack(messagesLabel, feedLabel, distribution: .fillEqually)).padTop(10)
        
        addSubview(backButton)
        backButton.anchor(top: safeAreaLayoutGuide.topAnchor, leading: leadingAnchor, bottom: nil, trailing: nil, padding: .init(top: 12, left: 12, bottom: 0, right: 0), size: .init(width: 34, height: 34))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
