//
//  UserDetailsViewController.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 17/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import SDWebImage

class UserDetailsViewController: UIViewController, UIScrollViewDelegate {
    
    
    // You should really create a different ViewModel object for UserDetails.
    // ie UserDetailsViewModel
    var cardViewModel: CardViewModel! {
        didSet {
            infoLabel.attributedText = cardViewModel.attributedString
//            guard let firstImageUrl = cardViewModel.imageUrls.first, let url = URL(string: firstImageUrl) else { return }
//            imageView.sd_setImage(with: url)
            swipingPhotosController.cardViewModel = cardViewModel
        }
    }
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
//        sv.backgroundColor = .green
        /* When you set this to true, it slides down the content right below the safe area guide. */
        sv.alwaysBounceVertical = true
        sv.contentInsetAdjustmentBehavior = .never // Fixes "the problem"
        sv.delegate = self
        return sv
    }()
    
//    let imageView: UIImageView = {
//        let iv = UIImageView(image: UIImage(named: "kelly3"))
//        iv.contentMode = .scaleAspectFill
//        iv.clipsToBounds = true
//        return iv
//    }()
    
    // How do I swap out a UIImageView with a UIViewController component?
//    let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal, options: nil)
    let swipingPhotosController = SwipingPhotosController(isCardViewMode: false)
    
    let infoLabel: UILabel = {
        let label = UILabel()
        label.text = "User name 30\nDoctor\nSome biotext down below"
        label.numberOfLines = 0
        return label
    }()
    
    let dismissButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "dismiss_down_arrow")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleTapDismiss), for: .touchUpInside)
        return button
    }()
    
    // 3 bottom control buttons
    lazy var dislikeButton = createButton(image: UIImage(named: "dismiss_circle")!, selector: #selector(handleDislike))
    lazy var superLikeButton = createButton(image: UIImage(named: "super_like_circle")!, selector: #selector(handleDislike))
    lazy var likeButton = createButton(image: UIImage(named: "like_circle")!, selector: #selector(handleDislike))
    
    @objc private func handleDislike() {
        print("Disliking")
    }
    
    private func createButton(image: UIImage, selector: Selector) -> UIButton {
        let button = UIButton(type: .system)
        button.setImage(image.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: selector, for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFill // Make buttons bigger, less gaps in stackView.
        return button
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.backgroundColor = .white
        
        setupLayout()
        setupVisualBlurEffectView()
        setupBottomControls()
    }
    
    private func setupVisualBlurEffectView() {
        let blurEffect = UIBlurEffect(style: .regular)
        let visualEffectView = UIVisualEffectView(effect: blurEffect)
        view.addSubview(visualEffectView)
//        visualEffectView.fillSuperview()
        visualEffectView.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    private func setupBottomControls() {
        let stackView = UIStackView(arrangedSubviews: [dislikeButton, superLikeButton, likeButton])
        stackView.distribution = .fillEqually
        stackView.spacing = -32
        view.addSubview(stackView)
        stackView.anchor(top: nil, leading: nil, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: nil, padding: .init(top: 0, left: 0, bottom: 0, right: 0), size: .init(width: 300, height: 80))
        stackView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
    }
    
    fileprivate func setupLayout() {
        view.addSubview(scrollView)
        scrollView.fillSuperview()
        
        let swipingView = swipingPhotosController.view!
        
        scrollView.addSubview(swipingView)
        // Frame instead of autolayout.
        /* Why frame instead of auto-layout? Whenever we are using auto layout inside of a scrollView, the behaviour of your auto layout
         constraints don't even exactly like they normally do in a UIView. */
        /* Scrollview doesn't exactly know what the frame is, so viewWillLayoutSubviews() */
//        imageView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width)
        
        scrollView.addSubview(infoLabel)
        infoLabel.anchor(top: swipingView.bottomAnchor, leading: scrollView.leadingAnchor, bottom: nil, trailing: scrollView.trailingAnchor, padding: .init(top: 16, left: 16, bottom: 0, right: 16))
        
        //        view.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTapDismiss)))
        scrollView.addSubview(dismissButton)
        dismissButton.anchor(top: swipingView.bottomAnchor, leading: nil, bottom: nil, trailing: view.trailingAnchor, padding: .init(top: -25, left: 0, bottom: 0, right: 25), size: .init(width: 50, height: 50))
    }
    
    private let extraSwipingHeight: CGFloat = 120
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        let swipingView = swipingPhotosController.view!
        /* Nothing wrong with modifying the frame of a view of a UIViewController manually like this. */
        swipingView.frame = CGRect(x: 0, y: 0, width: view.frame.width, height: view.frame.width + extraSwipingHeight)
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let changeY = -scrollView.contentOffset.y
//        print(changeY)
        var width: CGFloat = view.frame.width + changeY * 2
        width = max(view.frame.width, width)
        let imageView = swipingPhotosController.view!
        imageView.frame = CGRect(x: min(0, -changeY), y: min(0, -changeY), width: width, height: width + extraSwipingHeight)
    }
    
    @objc private func handleTapDismiss() {
        dismiss(animated: true)
    }
}
