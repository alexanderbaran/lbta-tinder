//
//  CardView.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 11/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import SDWebImage

protocol CardViewDelegate {
    func didTapMoreInfo(cardViewModel: CardViewModel)
    func didRemoveCard(cardView: CardView)
}

class CardView: UIView {
    
    var nextCardView: CardView?
    
    var delegate: CardViewDelegate?
    
    var cardViewModel: CardViewModel! {
        didSet {
            //            let imageName = cardViewModel.imageNames[0]
//            let imageName = cardViewModel.imageUrls.first ?? "" // So it does not crash if array empty.
//            imageView.image = UIImage(named: imageName)
            // Load our image using some kind of url instead.
//            if let url = URL(string: imageName) {
////                imageView.sd_setImage(with: url)
//                imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "photo_placeholder"), options: .continueInBackground)
//            }
            
            swipingPhotosController.cardViewModel = self.cardViewModel
            
            informationLabel.attributedText = cardViewModel.attributedString
            informationLabel.textAlignment = cardViewModel.textAlignment
            
            (0..<cardViewModel.imageUrls.count).forEach { (_) in
                let barView = UIView()
                barView.backgroundColor = barDeselectedColor
                barsStackView.addArrangedSubview(barView)
            }
            barsStackView.arrangedSubviews.first?.backgroundColor = .white
            setupImageIndexObserver()
        }
    }
    
    private func setupImageIndexObserver() {
        /* Might want to use [unowned self] to prevent possible retain cycle that will occur if you don't manage this correctly. Can also use [weak self]
         but the syntax is a little but more tedious, you will need questionmark after self? inside closure.  */
//        cardViewModel.imageIndexObserver = { [unowned self] (imageIndex, image: UIImage?) in
        cardViewModel.imageIndexObserver = { [unowned self] (imageIndex, imageURL: String?) in
            print("Changing photo from view model")
//            self.imageView.image = image
//            if let url = URL(string: imageURL ?? "") {
////                self.imageView.sd_setImage(with: url)
//                self.imageView.sd_setImage(with: url, placeholderImage: UIImage(named: "photo_placeholder"), options: .continueInBackground)
//            }
            self.barsStackView.arrangedSubviews.forEach { (v) in
                v.backgroundColor = self.barDeselectedColor
            }
            self.barsStackView.arrangedSubviews[imageIndex].backgroundColor = .white
        }
    }
    
    // Encapsulation
//    private var imageView = UIImageView(image: #imageLiteral(resourceName: "lady5c")) // If expect an image, start typing image and "image Literal" will show up.
    // Replacing imageView with UIPageViewController component which is our SwipingPhotosController, to preload images to prevent flashing.
//    private let swipingPhotosController = SwipingPhotosController(transitionStyle: .scroll, navigationOrientation: .horizontal)
    private let swipingPhotosController = SwipingPhotosController(isCardViewMode: true)
    private let gradientLayer = CAGradientLayer()
    private let informationLabel = UILabel()
    
    // Configurations
    private let threshold: CGFloat = 120
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setupLayout()
        
        /* Bug fix: During the drag and drop phase all of that code is being handled through the panGesture inside of our initializer, it is being handled
         with the handlePan() code and whenever we are ending the gesture we are actually animating the card further to the right or left for the next card
         and what is really going on is you are executing multiple animations at the same time and the result of the animaiton becomes really unpredictable. */
        
        let panGesture = UIPanGestureRecognizer(target: self, action: #selector(handlePan))
        addGestureRecognizer(panGesture)
        
        addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleTap)))
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //    var imageIndex = 0
    private let barDeselectedColor = UIColor(white: 0, alpha: 0.1)
    
    @objc private func handleTap(gesture: UITapGestureRecognizer) {
        //        print("Handling tap and cycling photos.")
        let tapLocation = gesture.location(in: nil)
        let shouldAdvanceNextPhoto = tapLocation.x > frame.width / 2 ? true : false
        if shouldAdvanceNextPhoto {
            cardViewModel.advanceToNextPhoto()
        } else {
            cardViewModel.goToPreviousPhoto()
        }
        //        if shouldAdvanceNextPhoto {
        //            imageIndex = min(imageIndex + 1, cardViewModel.imageNames.count - 1)
        //        } else {
        //            imageIndex = max(imageIndex - 1, 0)
        //        }
        //        let imageName = cardViewModel.imageNames[imageIndex]
        //        imageView.image = UIImage(named: imageName)
        //        barsStackView.arrangedSubviews.forEach { (v) in
        //            v.backgroundColor = barDeselectedColor
        //        }
        //        barsStackView.arrangedSubviews[imageIndex].backgroundColor = .white
    }
    
    private let moreInfoButton: UIButton = {
        let button = UIButton(type: .system)
        button.setImage(UIImage(named: "info_icon")?.withRenderingMode(.alwaysOriginal), for: .normal)
        button.addTarget(self, action: #selector(handleMoreInfo), for: .touchUpInside)
        return button
    }()
    
    @objc private func handleMoreInfo() {
//        print("Present User Details Page")
        // Present is missing here because UIView and not UIViewController
        // Hack solution.
//        let rootViewController = UIApplication.shared.keyWindow?.rootViewController
//        let userDetailsController = UIViewController()
//        userDetailsController.view.backgroundColor = .yellow
//        rootViewController?.present(userDetailsController, animated: true)
        // Use a delegate instead, much more elegant solution.
        delegate?.didTapMoreInfo(cardViewModel: self.cardViewModel)
    }
    
    private func setupLayout() {
        // Custom drawing code
        // In order for the radius to work need to remove the blue background in the Viewcontroller for CardsDeckView. It works but does not show
        layer.cornerRadius = 10
        clipsToBounds = true
        
        let swipingPhotosView = swipingPhotosController.view!
        
        addSubview(swipingPhotosView)
        swipingPhotosView.fillSuperview()
        
//        addSubview(imageView)
//        imageView.contentMode = .scaleAspectFill
//        /* Watch out for z indexes, imageView first, then gradientLayer, then informationLabel */
//        imageView.fillSuperview()
        
//        setupBarsStackView()
        
        // Add a gradient layer
        setupGradientLayer()
        
        addSubview(informationLabel)
        informationLabel.anchor(top: nil, leading: leadingAnchor, bottom: bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 16, bottom: 16, right: 16))
        informationLabel.text = "TEST NAME TEST NAME AGE"
        informationLabel.textColor = .white
        //        informationLabel.font = UIFont.systemFont(ofSize: 34, weight: .heavy) // Using attributed string so no use for it here.
        informationLabel.numberOfLines = 0
        
        addSubview(moreInfoButton)
        moreInfoButton.anchor(top: nil, leading: nil, bottom: self.bottomAnchor, trailing: trailingAnchor, padding: .init(top: 0, left: 0, bottom: 16, right: 16), size: .init(width: 44, height: 44))
    }
    
    //    var snappedBack: Bool = true
    
    func removeAllAnimations() {
        // The superview is the deck view that contains all of our cards here.
        superview?.subviews.forEach({ (subView: UIView) in
            // subView should be the CardViews.
            //            print("Removing all animations.")
            subView.layer.removeAllAnimations()
        })
    }
    
    @objc private func handlePan(gesture: UIPanGestureRecognizer) {
        switch gesture.state {
        case .began:
            //            print(".began")
            removeAllAnimations()
        case .changed:
            //            print(".changed")
            handleChanged(gesture: gesture)
        case .ended:
            //            print(".ended")
            handleEnded(gesture)
        default:
            break;
        }
    }
    
    private func handleEnded(_ gesture: UIPanGestureRecognizer) {
        let translationDirection: CGFloat = gesture.translation(in: nil).x > 0 ? 1 : -1
        let shouldDismissCard = abs(gesture.translation(in: nil).x) > threshold
        
        if shouldDismissCard {
            // Hack solution
            guard let homeController = self.delegate as? HomeController else { return }
            
            if translationDirection == 1 {
                homeController.handleLike()
            } else {
                homeController.handleDislike()
            }
        } else {
            UIView.animate(withDuration: 0.3, delay: 0, usingSpringWithDamping: 0.7, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
                self.transform = .identity // Back to origin
            })
        }
        
        
        

        
        
        
        
        
        
//        if shouldDismissCard {
//            UIView.animate(withDuration: 2, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
////                self.frame = CGRect(x: 1000 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
//                self.layer.frame = CGRect(x: 1000 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
//            }) { (_) in
//                self.removeFromSuperview()
//                self.transform = .identity // Not sure if we need this here
//                self.delegate?.didRemoveCard(cardView: self)
//            }
//        } else {
//            //            self.snappedBack = false
//            UIView.animate(withDuration: 0.5, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
//                self.transform = .identity // Back to origin
//            }) { (_) in
//                //                self.snappedBack = true
//                //                print("Snapped back")
//            }
//        }
        
        
        
        
        
        //        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
        //            if shouldDismissCard {
        //                // A bug, jumpy effect.
        //                //                let offScreenTransform = self.transform.translatedBy(x: 1000, y: 0)
        //                //                self.transform = offScreenTransform
        //                self.frame = CGRect(x: 500 * translationDirection, y: 0, width: self.frame.width, height: self.frame.height)
        //            } else {
        //                self.transform = .identity // Back to origin
        //            }
        //        }) { (_) in
        ////            print("Completed animation, let's bring our card back")
        //            self.transform = .identity
        //            if shouldDismissCard {
        //                self.removeFromSuperview()
        //            }
        ////            self.frame = CGRect(x: 0, y: 0, width: self.superview!.frame.width, height: self.superview!.frame.height)
        //        }
    }
    
    private func handleChanged(gesture: UIPanGestureRecognizer) {
        let translation = gesture.translation(in: nil)
        let degrees: CGFloat = translation.x / 20
        let angle = degrees * .pi/180
        let rotationalTransformation = CGAffineTransform(rotationAngle: angle)
        //        self.transform = rotationalTransformation.translatedBy(x: translation.x/1.2, y: translation.y/1.8)
        self.transform = rotationalTransformation.translatedBy(x: translation.x, y: translation.y)
        //        self.transform = CGAffineTransform(translationX: translation.x, y: translation.y)
    }
    
    private let barsStackView = UIStackView()
    
    private func setupBarsStackView() {
        addSubview(barsStackView)
        barsStackView.anchor(top: topAnchor, leading: leadingAnchor, bottom: nil, trailing: trailingAnchor, padding: .init(top: 8, left: 8, bottom: 0, right: 8), size: .init(width: 0, height: 4))
        barsStackView.spacing = 4
        barsStackView.distribution = .fillEqually
    }
    
    private func setupGradientLayer() {
        
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.black.cgColor]
        // First color starts on 0.7, 1.1 is below the card thats where it fades down to.
        gradientLayer.locations = [0.7, 1.1]
        // self.frame is actually zero frame during the initialization phase. Insite init(), the view has not drawn itself out yet during this process.
        //        gradientLayer.frame = self.frame
        //        gradientLayer.frame = CGRect(x: 0, y: 0, width: 300, height: 400)
        layer.addSublayer(gradientLayer)
    }
    
    override func layoutSubviews() {
        // layoutSubviews() gets executed everytime your views draws itself. In here you know what your CardView frame will be.
        gradientLayer.frame = self.frame
    }
}
