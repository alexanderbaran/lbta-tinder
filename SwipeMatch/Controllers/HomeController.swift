//
//  ViewController.swift
//  SwipeMatchFirestore
//
//  Created by Alexander Baran on 11/08/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import UIKit
import Firebase
import JGProgressHUD

class HomeController: UIViewController, SettingsControllerDelegate, LoginControllerDelegate, CardViewDelegate {

    let topStackView = TopNavigationStackView()
    let cardsDeckView = UIView()
    let bottomControls = HomeBottomControlsStackView()
    
    //    let users = [
    //        User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "lady5c"),
    //        User(name: "Jane", age: 18, profession: "Teacher", imageName: "lady4c")
    //    ]
    
//    let cardViewModels: [CardViewModel] = {
//        let producers: [ProducesCardViewModel] = [
//            User(name: "Kelly", age: 23, profession: "Music DJ", imageNames: ["kelly1", "kelly2", "kelly3"]),
//            Advertiser(title: "Slide Out Menu", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster"),
//            User(name: "Jane", age: 18, profession: "Teacher", imageNames: ["jane1", "jane2", "jane3"])
//        ]
//        let viewModels = producers.map({ return $0.toCardViewModel() })
//        return viewModels
//    }()
    
    var cardViewModels = [CardViewModel]()
    
    //    let cardViewModels = ([
    //        User(name: "Kelly", age: 23, profession: "Music DJ", imageName: "lady5c"),
    //        User(name: "Jane", age: 18, profession: "Teacher", imageName: "lady4c"),
    //        Advertiser(title: "Slide Out Menu", brandName: "Lets Build That App", posterPhotoName: "slide_out_menu_poster")
    //        ] as [ProducesCardViewModel]).map { (producer: ProducesCardViewModel) -> CardViewModel in
    //            return producer.toCardViewModel()
    //    }
    
    // Ømer fix
    private func removeAllAnimations() {
        cardsDeckView.subviews.forEach({ (subView: UIView) in
            // subView should be the CardViews.
            //            print("Removing all animations.")
            subView.layer.removeAllAnimations()
        })
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden = true
//        navigationController?.isNavigationBarHidden = true // This does not work as good. Can't slide back with the back gesture.
        
        topStackView.settingsButton.addTarget(self, action: #selector(handleSettings), for: .touchUpInside)
        topStackView.messagesButton.addTarget(self, action: #selector(handleMessages), for: .touchUpInside)
        bottomControls.refreshButton.addTarget(self, action: #selector(handleRefresh), for: .touchUpInside)
        setupLayout()
        fetchCurrentUser()
//        setupFirestoreUserCards()
//        fetchUsersFromFirestore()
        bottomControls.likeButton.addTarget(self, action: #selector(handleLike), for: .touchUpInside)
        bottomControls.dislikeButton.addTarget(self, action: #selector(handleDislike), for: .touchUpInside)
    }
    
    @objc private func handleMessages() {
        let vc = MatchesMessagesController()
        navigationController?.pushViewController(vc, animated: true)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
//        print("HomeController did appear")
        if Auth.auth().currentUser == nil {
            let registrationController = RegistrationController()
            let loginController = LoginController()
            loginController.delegate = self
            let navigationController = UINavigationController(rootViewController: registrationController)
            navigationController.modalPresentationStyle = .fullScreen
            present(navigationController, animated: true) {
                navigationController.pushViewController(loginController, animated: true)
            }
        }
    }
    
    fileprivate var user: User?
    
    fileprivate func fetchCurrentUser() {
        guard let uid = Auth.auth().currentUser?.uid else { print("No logged in user"); return }
        Firestore.firestore().collection("users").document(uid).getDocument { (snapshot: DocumentSnapshot?, err: Error?) in
            if let err = err {
                print(err)
                return
            }
            guard let dictionary = snapshot?.data() else { return }
            self.user = User(dictionary: dictionary)
            self.fetchSwipes()
//            self.fetchUsersFromFirestore()
        }
    }
    
    var swipes = [String: Int]()
    
    private func fetchSwipes() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot: DocumentSnapshot?, err: Error?) in
            if let err = err {
                print("Failed to fetch swipes info for currently logged in user:", err)
                return
            }
            print("Swipes:", snapshot?.data() ?? "")
//            guard let data = snapshot?.data() as? [String: Int] else { return }
//            self.swipes = data
            if let data = snapshot?.data() as? [String: Int] {
                self.swipes = data
            }
            self.fetchUsersFromFirestore()
        }
    }
    
    @objc fileprivate func handleRefresh() {
//        presentMatchView(cardUID: "")
        
        cardsDeckView.subviews.forEach({ $0.removeFromSuperview() })
        // comments https://www.letsbuildthatapp.com/course_video?id=4512
//        if topCardView == nil {
            fetchUsersFromFirestore()
//        }
    }
    
    func didSaveSettings() {
        fetchCurrentUser()
    }
    
    var lastFetchedUser: User?
    
    private func fetchUsersFromFirestore() {
//        guard let minAge = user?.minSeekingAge, let maxAge = user?.maxSeekingAge else { return }
        let minAge = user?.minSeekingAge ?? SettingsController.defaultMinSeekingAge
        let maxAge = user?.maxSeekingAge ?? SettingsController.defaultMaxSeekingAge
        
        let hud = JGProgressHUD(style: .dark)
        hud.textLabel.text = "Fetching Users"
        hud.show(in: view)
//        let query = Firestore.firestore().collection("users")
//        let query = Firestore.firestore().collection("users").whereField("age", isLessThan: 31).whereField("age", isGreaterThan: 18)
        // Will introduce pagination here to page through 2 users at a time.
//        let query = Firestore.firestore().collection("users").order(by: "uid").start(after: [lastFetchedUser?.uid ?? ""]).limit(to: 2)
        let query = Firestore.firestore().collection("users").whereField("age", isGreaterThanOrEqualTo: minAge).whereField("age", isLessThanOrEqualTo: maxAge).limit(to: 10)
        topCardView = nil
        
        query.getDocuments { (snapshot: QuerySnapshot?, error: Error?) in
            hud.dismiss()
            if let error = error {
                print("Failed to fetch users:", error)
                return
            }
            
            // We are going to set up the nextCardView relationship for all cards.
            // Linked List
            var previousCardView: CardView?
            
            self.removeAllAnimations() // Ømer fix
            snapshot?.documents.forEach({ (documentSnapshot: QueryDocumentSnapshot) in
                let userDictionary = documentSnapshot.data()
                let user = User(dictionary: userDictionary)
                self.users[user.uid ?? ""] = user
                let isNotCurrentUser = user.uid != Auth.auth().currentUser?.uid
                let hasNotSwipedBefore = self.swipes[user.uid!] == nil
                if isNotCurrentUser && hasNotSwipedBefore {
                    let cardView = self.setupCardFromUser(user: user)
                    previousCardView?.nextCardView = cardView
                    previousCardView = cardView
                    if self.topCardView == nil {
                        self.topCardView = cardView
                    }
                }
//                self.setupCardFromUser(user: user)
//                print(userDictionary)
//                self.cardViewModels.append(user.toCardViewModel())
//                print(user.name, user.imageNames)
//                self.lastFetchedUser = user
                
            })
//            self.setupFirestoreUserCards()
        }
    }
    
    var users = [String: User]()
    
    var topCardView: CardView?
    
    @objc func handleLike() {
        saveSwipeToFirestore(didLike: 1)
        performSwipeAnimation(translation: 700, angle: 15)
        
//        let duration = 0.5
//
//        let translationAnimation = CABasicAnimation(keyPath: "position.x")
//        translationAnimation.toValue = 700
//        translationAnimation.duration = duration
//        translationAnimation.fillMode = .forwards
//        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
//        translationAnimation.isRemovedOnCompletion = false
//
//        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
//        rotationAnimation.toValue = 15 * CGFloat.pi / 180
//        rotationAnimation.duration = duration
//
//        let cardView = topCardView
//        topCardView = cardView?.nextCardView
//
//        CATransaction.setCompletionBlock {
//            cardView?.removeFromSuperview()
////            self.topCardView?.removeFromSuperview()
//            // Not setting the nextCardView correctly.
////            self.topCardView = self.topCardView?.nextCardView
//        }
//
////        topCardView?.layer.add(translationAnimation, forKey: "translation") // Key doesn't matter, just call it translation.
////        topCardView?.layer.add(rotationAnimation, forKey: "rotation")
//
//        cardView?.layer.add(translationAnimation, forKey: "translation") // Key doesn't matter, just call it translation.
//        cardView?.layer.add(rotationAnimation, forKey: "rotation")
//
//        CATransaction.commit()
//
//
////        removeAllAnimations()
//
////        // This type of animation is buggy when you try to animate multiple things at the same time.
////        UIView.animate(withDuration: 1, delay: 0, usingSpringWithDamping: 0.6, initialSpringVelocity: 0.1, options: .curveEaseOut, animations: {
////            self.topCardView?.layer.frame = CGRect(x: 600, y: 0, width: self.topCardView!.frame.width, height: self.topCardView!.frame.height)
////            let angle = 15 * CGFloat.pi / 180
////            self.topCardView?.transform = CGAffineTransform(rotationAngle: angle)
////        }) { (_) in
////            self.topCardView?.removeFromSuperview()
////            self.topCardView = self.topCardView?.nextCardView
////        }
//
////        print("Swipe and remove card from top of stack")
////        topCardView?.removeFromSuperview()
//
    }
    
    private func saveSwipeToFirestore(didLike: Int) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        guard let cardUID = topCardView?.cardViewModel.uid else { return }
        let documentData = [cardUID: didLike]
        // Too fast if you do it here, put it inside the callbacks later.
//        if didLike == 1 {
//            self.checkIfMatchExists(cardUID: cardUID)
//        }
        // Need to already exists before can update data.
        Firestore.firestore().collection("swipes").document(uid).getDocument { (snapshot: DocumentSnapshot?, err: Error?) in
            if let err = err {
                print("Failed to fetch swipe document:", err)
                return
            }
            if snapshot?.exists == true {
                Firestore.firestore().collection("swipes").document(uid).updateData(documentData) { (err: Error?) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully updated swiped...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            } else {
                Firestore.firestore().collection("swipes").document(uid).setData(documentData) { (err: Error?) in
                    if let err = err {
                        print("Failed to save swipe data:", err)
                        return
                    }
                    print("Successfully saved swiped...")
                    if didLike == 1 {
                        self.checkIfMatchExists(cardUID: cardUID)
                    }
                }
            }
        }
    }
    
    private func checkIfMatchExists(cardUID: String) {
        // How to detect our match between two users?
        print("Detecting match")
        Firestore.firestore().collection("swipes").document(cardUID).getDocument { (snapshot: DocumentSnapshot?, err: Error?) in
            if let err = err {
                print("We failed to fetch document for card user:", err)
                return
            }
            guard let data = snapshot?.data() else { return }
//            print(data)
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let hasMatched = data[uid] as? Int == 1
            if hasMatched {
                print("Has matched")
//                let hud = JGProgressHUD(style: .dark)
//                hud.textLabel.text = "Found a match"
//                hud.show(in: self.view)
//                hud.dismiss(afterDelay: 4)
                self.presentMatchView(cardUID: cardUID)
                guard let cardUser = self.users[cardUID] else { return }
                let data: [String: Any] = ["name": cardUser.name ?? "", "profileImageUrl": cardUser.imageUrl1 ?? "", "uid": cardUID, "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(uid).collection("matches").document(cardUID).setData(data) { (err: Error?) in
                    if let err = err {
                        print("Failed to save match info:", err)
                        return
                    }
                    print("Successfully saved match info")
                }
                // Save opposite user.
                guard let currentUser = self.user else { return }
                let otherMatchData: [String: Any] = ["name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "uid": currentUser.uid ?? "", "timestamp": Timestamp(date: Date())]
                Firestore.firestore().collection("matches_messages").document(cardUID).collection("matches").document(uid).setData(otherMatchData) { (err: Error?) in
                    if let err = err {
                        print("Failed to save match info:", err)
                        return
                    }
                    print("Successfully saved match info")
                }
            }
        }
    }
    
    private func presentMatchView(cardUID: String) {
        let matchView = MatchView()
        matchView.cardUID = cardUID
        matchView.currentUser = self.user
        view.addSubview(matchView)
        matchView.fillSuperview()
    }
    
    @objc func handleDislike() {
        saveSwipeToFirestore(didLike: 0)
        performSwipeAnimation(translation: -350, angle: -15)
    }
    
    private func performSwipeAnimation(translation: CGFloat, angle: CGFloat) {
        let duration = 0.5
        let translationAnimation = CABasicAnimation(keyPath: "position.x")
        translationAnimation.toValue = translation
        translationAnimation.duration = duration
        translationAnimation.fillMode = .forwards
        translationAnimation.timingFunction = CAMediaTimingFunction(name: .easeOut)
        translationAnimation.isRemovedOnCompletion = false
        let rotationAnimation = CABasicAnimation(keyPath: "transform.rotation.z")
        rotationAnimation.toValue = angle * CGFloat.pi / 180
        rotationAnimation.duration = duration
        let cardView = topCardView
        topCardView = cardView?.nextCardView
        CATransaction.setCompletionBlock {
            cardView?.removeFromSuperview()
        }
        cardView?.layer.add(translationAnimation, forKey: "translation") // Key doesn't matter, just call it translation.
        cardView?.layer.add(rotationAnimation, forKey: "rotation")
        CATransaction.commit()
    }
    
    func didRemoveCard(cardView: CardView) {
        self.topCardView?.removeFromSuperview()
        self.topCardView = self.topCardView?.nextCardView
    }
    
    private func setupCardFromUser(user: User) -> CardView {
        let cardView = CardView()
        cardView.delegate = self
        cardView.cardViewModel = user.toCardViewModel()
        cardsDeckView.addSubview(cardView)
        cardsDeckView.sendSubviewToBack(cardView) /* To prevent annoying flashing that occurs at LBTA video 23 */
        cardView.fillSuperview()
        return cardView
    }
    
    func didTapMoreInfo(cardViewModel: CardViewModel) {
//        print("HomeController going to show user details now")
//        print(cardViewModel.attributedString)
        let userDetailsController = UserDetailsViewController()
        userDetailsController.cardViewModel = cardViewModel
        userDetailsController.modalPresentationStyle = .fullScreen
        present(userDetailsController, animated: true)
    }
    
    func didFinishLoggingIn() {
        fetchCurrentUser()
    }
    
    @objc private func handleSettings() {
        //        print("Show registration page")
//        let registrationController = RegistrationController()
//        present(registrationController, animated: true)
        let settingsController = SettingsController()
        settingsController.delegate = self
        let navigationController = UINavigationController(rootViewController: settingsController)
        // https://stackoverflow.com/questions/56568967/detecting-sheet-was-dismissed-on-ios-13
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true)
    }
    
    // MARK:- Fileprivate
    
    private func setupFirestoreUserCards() {
        
        //        users.forEach { (user: User) in
        //            let cardView = CardView() // let cardView = CardView(frame: .zero) // Same as empty argument
        //            cardView.imageView.image = UIImage(named: user.imageName)
        //            cardView.informationLabel.text = "\(user.name) \(user.age)\n\(user.profession)"
        //            let attributedText = NSMutableAttributedString(string: user.name, attributes: [.font: UIFont.systemFont(ofSize: 32, weight: .heavy)])
        //            attributedText.append(NSAttributedString(string: " \(user.age)", attributes: [.font: UIFont.systemFont(ofSize: 24, weight: .regular)]))
        //            attributedText.append(NSAttributedString(string: "\n\(user.profession)", attributes: [.font: UIFont.systemFont(ofSize: 20, weight: .regular)]))
        //            cardView.informationLabel.attributedText = attributedText
        //            cardsDeckView.addSubview(cardView)
        //            cardView.fillSuperview()
        //        }
        
        cardViewModels.forEach { (cardViewModel: CardViewModel) in
            let cardView = CardView()
            cardView.cardViewModel = cardViewModel
            //            cardView.imageView.image = UIImage(named: cardViewModel.imageName)
            //            cardView.informationLabel.attributedText = cardViewModel.attributedString
            //            cardView.informationLabel.textAlignment = cardViewModel.textAlignment
            cardsDeckView.addSubview(cardView)
            cardView.fillSuperview()
        }
    }
    
    private func setupLayout() {
        view.backgroundColor = .white
        let overallStackView = UIStackView(arrangedSubviews: [topStackView, cardsDeckView, bottomControls]) // z indexes for these components
        overallStackView.axis = .vertical
        view.addSubview(overallStackView)
        overallStackView.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.bottomAnchor, trailing: view.trailingAnchor)
        overallStackView.isLayoutMarginsRelativeArrangement = true
        overallStackView.layoutMargins = .init(top: 0, left: 12, bottom: 0, right: 12)
        
        overallStackView.bringSubviewToFront(cardsDeckView)
    }
    
}

