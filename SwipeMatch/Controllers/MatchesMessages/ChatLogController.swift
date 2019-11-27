//
//  ChatLogController.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 22/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools
import Firebase

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    private lazy var customNavBar = MessagesNavBar(match: self.match)
    
    let navBarHeight: CGFloat = 120
    
    private let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    lazy var customInputView: CustomInputAccessoryView = {
        let civ = CustomInputAccessoryView(frame: .init(x: 0, y: 0, width: view.frame.width, height: 50))
        civ.sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
        return civ
    }()
    
    @objc private func handleSend() {
        print(customInputView.textView.text ?? "")
        saveToFromMessages()
        saveToFromRecentMessages()
    }
    
    private func saveToFromRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["text": customInputView.textView.text ?? "", "name": match.name, "profileImageUrl": match.profileImageUrl, "timestamp": Timestamp(date: Date()), "uid": match.uid]
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").document(match.uid).setData(data) { (err: Error?) in
            if let err = err {
                print("Could not save recent message:", err)
                return
            }
            print("Saved recent message")
        }
        guard let currentUser = self.currentUser else { return }
        let toData: [String: Any] = ["text": customInputView.textView.text ?? "", "name": currentUser.name ?? "", "profileImageUrl": currentUser.imageUrl1 ?? "", "timestamp": Timestamp(date: Date()), "uid": currentUser.uid ?? ""]
        // Save the other direction
        Firestore.firestore().collection("matches_messages").document(match.uid).collection("recent_messages").document(currentUserId).setData(toData) { (err: Error?) in
            if let err = err {
                print("Could not save recent message:", err)
                return
            }
            print("Saved recent message")
        }
    }
    
    private func saveToFromMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let data: [String: Any] = ["text": customInputView.textView.text ?? "", "fromId": currentUserId, "toId": match.uid, "timestamp": Timestamp(date: Date())]
        let collection = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid)
        collection.addDocument(data: data) { (err: Error?) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            print("Successfully saved message into Firestore")
            self.customInputView.textView.text = nil
            self.customInputView.placeholderLabel.isHidden = false
        }
        
        let toCollection = Firestore.firestore().collection("matches_messages").document(match.uid).collection(currentUserId)
        toCollection.addDocument(data: data) { (err: Error?) in
            if let err = err {
                print("Failed to save message:", err)
                return
            }
            print("Successfully saved message into Firestore")
        }
    }
    
    /* This line get called multiple times so should have single instance defined somewhere else. */
    override var inputAccessoryView: CustomInputAccessoryView? {
        get {
            return customInputView
        }
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var listener: ListenerRegistration?
    
    private func fetchMessages() {
        print("Fetching messages")
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        let query = Firestore.firestore().collection("matches_messages").document(currentUserId).collection(match.uid).order(by: "timestamp")
        
        listener = query.addSnapshotListener { (querySnapshot: QuerySnapshot?, err: Error?) in
            if let err = err {
                print("Failed to get messages:", err)
                return
            }
            querySnapshot?.documentChanges.forEach({ (documentChange: DocumentChange) in
                if documentChange.type == .added {
                    self.items.append(Message(dictionary: documentChange.document.data()))
                }
            })
            self.collectionView.reloadData()
            self.collectionView.scrollToItem(at: [0, self.items.count - 1], at: .bottom, animated: true)
        }
        
//        query.getDocuments { (querySnapshot: QuerySnapshot?, err: Error?) in
//            if let err = err {
//                print("Failed to get messages:", err)
//                return
//            }
//            querySnapshot?.documents.forEach({ (queryDocumentSnapshot: QueryDocumentSnapshot) in
////                print(queryDocumentSnapshot.data())
//                self.items.append(Message(dictionary: queryDocumentSnapshot.data()))
//            })
//            self.collectionView.reloadData()
//        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        // Tells you if it's being popped off the nav stack.
        // If you add another view on top, maybe you don't want to remove listner just yet, but if it is being popped off then controller must be able to deinit.
        if isMovingFromParent {
            listener?.remove()
        }
    }
    
    var currentUser: User?
    
    private func fetchCurrentUser() {
        Firestore.firestore().collection("users").document(Auth.auth().currentUser?.uid ?? "").getDocument { (documentSnapshot: DocumentSnapshot?, err: Error?) in
            if let err = err {
                print("Failed to fetch current user:", err)
                return
            }
            let data = documentSnapshot?.data() ?? [:]
            self.currentUser = User(dictionary: data)
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchCurrentUser()
        
        NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardShow), name: UIResponder.keyboardDidShowNotification, object: nil)
        
        collectionView.keyboardDismissMode = .interactive
        collectionView.alwaysBounceVertical = true
        
        fetchMessages()
        
//        items = [
//            .init(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.", isFromCurrentLoggedUser: true),
//            .init(text: "Hello bud", isFromCurrentLoggedUser: false),
//            .init(text: "Hello from the Tinder Course", isFromCurrentLoggedUser: false),
//            .init(text: "Contrary to popular belief", isFromCurrentLoggedUser: true),
//            .init(text: "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet.", isFromCurrentLoggedUser: false)
//        ]
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .zero, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.scrollIndicatorInsets.top = navBarHeight
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    deinit {
        print("ChatLogController deinit")
    }
    
    @objc private func handleKeyboardShow() {
        self.collectionView.scrollToItem(at: [0, items.count - 1], at: .bottom, animated: true)
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        
        // Estimated sizing.
        let estimatedSizeCell = MessageCell(frame: .init(x: 0, y: 0, width: view.frame.width, height: 1000))
        estimatedSizeCell.item = self.items[indexPath.item]
        estimatedSizeCell.layoutIfNeeded()
        
        let estimatedSize = estimatedSizeCell.systemLayoutSizeFitting(.init(width: view.frame.width, height: 1000))
        
        return .init(width: view.frame.width, height: estimatedSize.height)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
