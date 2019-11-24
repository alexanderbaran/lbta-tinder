//
//  MatchesHeader.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 24/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

class MatchesHeader: UICollectionReusableView {
    
    let newMatchesLabel = UILabel(text: "New Matches", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 1, green: 0.3550357039, blue: 0.4449895413, alpha: 1), textAlignment: .left, numberOfLines: 1)
    
    let matchesHorizontalController = MatchesHorizontalController()
    
    let messagesLabel = UILabel(text: "Messages", font: .boldSystemFont(ofSize: 18), textColor: #colorLiteral(red: 1, green: 0.3550357039, blue: 0.4449895413, alpha: 1), textAlignment: .left, numberOfLines: 1)
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        stack(
            stack(newMatchesLabel).padLeft(20),
            matchesHorizontalController.view,
            stack(messagesLabel).padLeft(20),
            spacing: 20
        ).withMargins(.init(top: 20, left: 0, bottom: 8, right: 0))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
