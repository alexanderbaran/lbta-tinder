//
//  CustomInputAccessoryView.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 24/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

// Input accessory view.
// Need this to bump it up on iPhone X and plus.
class CustomInputAccessoryView: UIView {
    
    let textView = UITextView()
    let sendButton = UIButton(title: "Send", titleColor: .black, font: UIFont.boldSystemFont(ofSize: 14), backgroundColor: .white, target: nil, action: nil)
    
    let placeholderLabel = UILabel(text: "Enter Message", font: .systemFont(ofSize: 16), textColor: .lightGray, textAlignment: .left, numberOfLines: 1)
    
    override var intrinsicContentSize: CGSize {
        return .zero
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
//            textView.text = "MAKE SURE TO SEE THIS"
        textView.isScrollEnabled = false
        textView.font = .systemFont(ofSize: 16)
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleTextChange), name: UITextView.textDidChangeNotification, object: nil)
        
        backgroundColor = .white
        setupShadow(opacity: 0.1, radius: 8, offset: .init(width: 0, height: -8), color: .lightGray)
        autoresizingMask = .flexibleHeight
        
        hstack(
            textView,
            sendButton.withSize(.init(width: 60, height: 60)),
            alignment: .center
        ).withMargins(.init(top: 0, left: 16, bottom: 0, right: 16))
        
        //        let stackView = UIStackView(arrangedSubviews: [textView, sendButton])
        //        stackView.alignment = .center
        //        sendButton.constrainHeight(60)
        //        sendButton.constrainWidth(60)
        //
        //        redView.addSubview(stackView)
        //        stackView.fillSuperview()
        //        //
        //        stackView.isLayoutMarginsRelativeArrangement = true
        
        addSubview(placeholderLabel)
        placeholderLabel.anchor(top: nil, leading: leadingAnchor, bottom: nil, trailing: sendButton.leadingAnchor, padding: .init(top: 0, left: 21, bottom: 0, right: 0))
        placeholderLabel.centerYAnchor.constraint(equalTo: sendButton.centerYAnchor).isActive = true
    }
    
    @objc private func handleTextChange() {
        placeholderLabel.isHidden = textView.text.count != 0
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
