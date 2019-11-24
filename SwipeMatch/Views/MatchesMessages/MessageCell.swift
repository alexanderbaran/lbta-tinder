//
//  MessageCell.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 24/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

class MessageCell: LBTAListCell<Message> {
    
    /* The reason for UITextView is because it is top aligned, whereas the UILabel are vertically centered aligned. */
    let textView: UITextView = {
        let tv = UITextView()
        tv.backgroundColor = .clear
        tv.font = .systemFont(ofSize: 20)
        tv.isScrollEnabled = false
        tv.isEditable = false
        return tv
    }()
    
    let bubbleContainer = UIView(backgroundColor: #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1))
    
    override var item: Message! {
        didSet {
            textView.text = item.text
            if item.isFromCurrentLoggedUser {
                // Right edge
                anchoredConstraints.leading?.isActive = false
                anchoredConstraints.trailing?.isActive = true
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
                textView.textColor = .white
            } else {
                // Left edge
                anchoredConstraints.leading?.isActive = true
                anchoredConstraints.trailing?.isActive = false
                bubbleContainer.backgroundColor = #colorLiteral(red: 0.8039215803, green: 0.8039215803, blue: 0.8039215803, alpha: 1)
                textView.textColor = .black
            }
        }
    }
    
    var anchoredConstraints: AnchoredConstraints!
    
    override func setupViews() {
        super.setupViews()
        
        addSubview(bubbleContainer)
        bubbleContainer.layer.cornerRadius = 12
        anchoredConstraints = bubbleContainer.anchor(top: topAnchor, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor)
        anchoredConstraints.leading?.constant = 20
        anchoredConstraints.trailing?.isActive = false
        anchoredConstraints.trailing?.constant = -20
        
//        // Example of switching sides of bubble.
//        anchoredConstraints.leading?.isActive = false
//        anchoredConstraints.trailing?.isActive = true
        
        /* If the text is going to take up more space it's going to go all the way to 250. */
        bubbleContainer.widthAnchor.constraint(lessThanOrEqualToConstant: 250).isActive = true
        
        bubbleContainer.addSubview(textView)
        textView.fillSuperview(padding: .init(top: 4, left: 12, bottom: 4, right: 12))
    }
    
}
