//
//  MatchView.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 20/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import Firebase

/* We use a UIView instead of a UIViewController because we don't need access to viewDidLoad and viewDidAppear, much more light weight and easier
 to perform certain functions. */
class MatchView: UIView {
    
    var currentUser: User! {
        didSet {
//            guard let url = URL(string: currentUser.imageUrl1 ?? "") else { return }
//            currentUserImageView.sd_setImage(with: url)
        }
    }
    
    // You're almost always guaranteed to have this variable set up.
    var cardUID: String! {
        didSet {
            // Either fetch current user inside here or pass in our current user if we have it.
            
            
            // Fetch the cardUID information.
            let query = Firestore.firestore().collection("users")
            query.document(cardUID).getDocument { (snapshot: DocumentSnapshot?, err: Error?) in
                if let err = err {
                    print("Failed to fetch card user:", err)
                    return
                }
                guard let dictionary = snapshot?.data() else { return }
                let user = User(dictionary: dictionary)
                guard let url = URL(string: user.imageUrl1 ?? "") else { return }
                // Maybe even set alpha in callback of sd_setimage?
//                self.cardUserImageView.alpha = 1
//                self.cardUserImageView.sd_setImage(with: url)
                self.cardUserImageView.sd_setImage(with: url) { (_, _, _, _) in
//                    self.cardUserImageView.alpha = 1
                    guard let currentUserImageUrl = URL(string: self.currentUser.imageUrl1 ?? "") else { return }
                    self.currentUserImageView.sd_setImage(with: currentUserImageUrl) { (_, _, _, _) in
                        // Can even setup animations here.
                        self.setupAnimations()
                    }
                }
                
                // Setup the description label text correctly somewhere inside of here.
                self.descriptionLabel.text = "You and \(user.name ?? "") have liked\neach other"
            }
        }
    }
    
    private let itsAMatchImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(named: "itsamatch"))
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private let descriptionLabel: UILabel = {
        let label = UILabel()
        label.text = "You and X have liked\neach other"
        label.textAlignment = .center
        label.textColor = .white
        label.font = UIFont.systemFont(ofSize: 20)
        label.numberOfLines = 0
        return label
    }()
    
    private let currentUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "kelly1"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        return imageView
    }()

    private let cardUserImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(named: "jane2"))
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.layer.borderWidth = 2
        imageView.layer.borderColor = UIColor.white.cgColor
        imageView.alpha = 0
        return imageView
    }()
    
    private let sendMessageButton: SendMessageButton = {
        let button = SendMessageButton(type: .system)
        button.setTitle("SEND MESSAGE", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    private let keepSwipingButton: KeepSwipingButton = {
        let button = KeepSwipingButton(type: .system)
        button.setTitle("Keep Swiping", for: .normal)
        button.setTitleColor(.white, for: .normal)
        return button
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupBlurView()
        setupLayout()
//        setupAnimations()
    }
    
    private func setupAnimations() {
        // Starting positions.
        views.forEach { (v: UIView) in
            v.alpha = 1
        }
        
        let angle = 30 * CGFloat.pi / 180
        currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle).concatenating(CGAffineTransform(translationX: 200, y: 0))
        cardUserImageView.transform = CGAffineTransform(rotationAngle: angle).concatenating(CGAffineTransform(translationX: -200, y: 0))
        
        sendMessageButton.transform = CGAffineTransform(translationX: -500, y: 0)
        keepSwipingButton.transform = CGAffineTransform(translationX: 500, y: 0)
        
        // Keyframe animations for segmented animations.
        UIView.animateKeyframes(withDuration: 1.3, delay: 0, options: .calculationModeCubic, animations: {
            
            // Animation 1 - translation back to original position
            // relativeDuration of 0.5 gives 0.6 because of withDuration 1.2
            UIView.addKeyframe(withRelativeStartTime: 0, relativeDuration: 0.45) {
                self.currentUserImageView.transform = CGAffineTransform(rotationAngle: -angle)
                self.cardUserImageView.transform = CGAffineTransform(rotationAngle: angle)
            }
            
            // Animation 1 - rotation
            UIView.addKeyframe(withRelativeStartTime: 0.6, relativeDuration: 0.4) {
                self.currentUserImageView.transform = .identity
                self.cardUserImageView.transform = .identity
                
//                self.sendMessageButton.transform = .identity
//                self.keepSwipingButton.transform = .identity
            }
            
        }) { (_) in
            
        }
        
        UIView.animate(withDuration: 0.75, delay: 0.6 * 1.3, usingSpringWithDamping: 0.5, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
            self.sendMessageButton.transform = .identity
            self.keepSwipingButton.transform = .identity
        }) { (_) in
            
        }
        
//        UIView.animate(withDuration: 0.7, animations: {
//            self.currentUserImageView.transform = .identity
//            self.cardUserImageView.transform = .identity
//        }) { (_) in
//
//        }
    }
    
    lazy var views = [
        itsAMatchImageView,
        descriptionLabel,
        currentUserImageView,
        cardUserImageView,
        sendMessageButton,
        keepSwipingButton
    ]
    
    private func setupLayout() {
        views.forEach { (v: UIView) in
            addSubview(v)
            v.alpha = 0
        }
//        addSubview(itsAMatchImageView)
//        addSubview(descriptionLabel)
//        addSubview(currentUserImageView)
//        addSubview(cardUserImageView)
//        addSubview(sendMessageButton)
//        addSubview(keepSwipingButton)
        let imageWidth: CGFloat = 140
        itsAMatchImageView.anchor(top: nil, leading: nil, bottom: descriptionLabel.topAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 16, right: 0), size: .init(width: 300, height: 80))
        itsAMatchImageView.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
        descriptionLabel.anchor(top: nil, leading: self.leadingAnchor, bottom: currentUserImageView.topAnchor, trailing: self.trailingAnchor, padding: .init(top: 0, left: 0, bottom: 32, right: 0), size: .init(width: 0, height: 50))
        currentUserImageView.anchor(top: nil, leading: nil, bottom: nil, trailing: centerXAnchor, padding: .init(top: 0, left: 0, bottom: 0, right: 16), size: .init(width: imageWidth, height: imageWidth))
        currentUserImageView.layer.cornerRadius = 140 / 2
        currentUserImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        cardUserImageView.anchor(top: nil, leading: centerXAnchor, bottom: nil, trailing: nil, padding: .init(top: 0, left: 16, bottom: 0, right: 0), size: .init(width: imageWidth, height: imageWidth))
        cardUserImageView.layer.cornerRadius = 140 / 2
        cardUserImageView.centerYAnchor.constraint(equalTo: currentUserImageView.centerYAnchor).isActive = true
        sendMessageButton.anchor(top: currentUserImageView.bottomAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 32, left: 48, bottom: 0, right: 48), size: .init(width: 0, height: 60))
        keepSwipingButton.anchor(top: sendMessageButton.bottomAnchor, leading: sendMessageButton.leadingAnchor, bottom: nil, trailing: sendMessageButton.trailingAnchor, padding: .init(top: 16, left: 0, bottom: 0, right: 0), size: .init(width: 0, height: 60))
    }
    
    let visualEffectView = UIVisualEffectView(effect: UIBlurEffect(style: .dark))
    
    private func setupBlurView() {
        visualEffectView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        addSubview(visualEffectView)
        visualEffectView.fillSuperview()
        visualEffectView.alpha = 0
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.visualEffectView.alpha = 1
        })
    }
    
    @objc private func handleTapDismiss() {
        UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 1, initialSpringVelocity: 1, options: .curveEaseOut, animations: {
            self.alpha = 0
        }) { (_) in
            self.removeFromSuperview()
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
