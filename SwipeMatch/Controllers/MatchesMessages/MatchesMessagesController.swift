//
//  MatchesMessagesController.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 21/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

//import UIKit
import LBTATools
import Firebase

class RecentMessageCell: LBTAListCell<RecentMessage> {
    
    let userProfileImageView = UIImageView(image: UIImage(named: "kelly1"), contentMode: .scaleAspectFill)
    
    let usernameLabel = UILabel(text: "USERNAME HERE", font: .boldSystemFont(ofSize: 18))
    
    let messageTextLabel = UILabel(text: "Some long line of text that should span 2 lines", font: .systemFont(ofSize: 16), textColor: .gray, textAlignment: .left, numberOfLines: 2)
    
    override var item: RecentMessage! {
        didSet {
            usernameLabel.text = item.name
            messageTextLabel.text = item.text
            userProfileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        userProfileImageView.layer.cornerRadius = 94 / 2
        
        hstack(
            userProfileImageView.withWidth(94).withHeight(94),
            stack(
                usernameLabel,
                messageTextLabel,
                spacing: 2
            ),
            spacing: 20,
            alignment: .center
            ).padLeft(20).padRight(20)
        
        addSeparatorView(leadingAnchor: usernameLabel.leadingAnchor)
    }
}

struct RecentMessage {
    let text, uid, name, profileImageUrl: String
    let timestamp: Timestamp
    
    init(dictionary: [String: Any]) {
        self.text = dictionary["text"] as? String ?? ""
        self.uid = dictionary["uid"] as? String ?? ""
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
        self.timestamp = dictionary["timestamp"] as? Timestamp ?? Timestamp(date: Date())
    }
}

//class MatchesMessagesController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
class MatchesMessagesController: LBTAListHeaderController<RecentMessageCell, RecentMessage, MatchesHeader>, UICollectionViewDelegateFlowLayout {
    
    var recentMessagesDictionary = [String: RecentMessage]()
    
    private func fetchRecentMessages() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("recent_messages").addSnapshotListener { (querySnapshot: QuerySnapshot?, err: Error?) in
            if let err = err {
                print("Failed to get recent_messages:", err)
                return
            }
            querySnapshot?.documentChanges.forEach({ (documentChange: DocumentChange) in
                if documentChange.type == .added || documentChange.type == .modified {
                    let dictionary = documentChange.document.data()
                    let recentMessage = RecentMessage(dictionary: dictionary)
                    self.recentMessagesDictionary[recentMessage.uid] = recentMessage
//                    self.items.append(recentMessage)
                }
            })
            self.resetItems()
//            self.collectionView.reloadData()
        }
    }
    
    private func resetItems() {
        var values = Array(recentMessagesDictionary.values)
        items = values.sorted(by: { (rm1: RecentMessage, rm2: RecentMessage) -> Bool in
            return rm1.timestamp.compare(rm2.timestamp) == .orderedDescending
        })
        collectionView.reloadData()
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return 0
    }
    
    override func setupHeader(_ header: MatchesHeader) {
        header.matchesHorizontalController.rootMatchesController = self
    }
    
    func didSelectMatchFromHeader(match: Match) {
//        print("Select match:", match.name)
        let chatLogController = ChatLogController(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    // 250 good value for a header
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, referenceSizeForHeaderInSection section: Int) -> CGSize {
        return .init(width: view.frame.width, height: 250)
    }
    
    let customNavBar = MatchesNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: view.frame.width, height: 130)
    }
    
//    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
//        let match = items[indexPath.item]
//        let chatLogController = ChatLogController(match: match)
//        navigationController?.pushViewController(chatLogController, animated: true)
//    }
    
    private func setupUI() {
        collectionView.backgroundColor = .white
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .zero, size: .init(width: 0, height: 150))
        collectionView.contentInset.top = 150
        collectionView.scrollIndicatorInsets.top = 150
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        fetchRecentMessages()
        
        setupUI()
        
//        items = [
//            .init(name: "test", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/lbta-swipematch.appspot.com/o/images%2F382CA931-0966-42DA-B7E3-2E470E5126C7?alt=media&token=9fef7211-0636-4e03-bfb5-e0d6ac6a329e"),
//            .init(name: "test", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/lbta-swipematch.appspot.com/o/images%2F382CA931-0966-42DA-B7E3-2E470E5126C7?alt=media&token=9fef7211-0636-4e03-bfb5-e0d6ac6a329e"),
//            .init(name: "test", profileImageUrl: "profileUrl")
//        ]
        
//        fetchMatches()
        
//        items = [
//            .init(text: "Some random message that I'll use for each recent message cell", uid: "BLANK", name: "Big Burger", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/lbta-swipematch.appspot.com/o/images%2F382CA931-0966-42DA-B7E3-2E470E5126C7?alt=media&token=9fef7211-0636-4e03-bfb5-e0d6ac6a329e", timestamp: Timestamp(date: Date()))
//        ]
    }
    
//    private func fetchMatches() {
//        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
//        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { (querySnapshot: QuerySnapshot?, err: Error?) in
//            if let err = err {
//                print("Failed to fetch matches:", err)
//                return
//            }
//            print("Here are my matches documents")
//            var matches = [Match]()
//            querySnapshot?.documents.forEach({ (queryDocumentSnapshot: QueryDocumentSnapshot) in
////                print(queryDocumentSnapshot.data())
//                let dictionary = queryDocumentSnapshot.data()
//                matches.append(.init(dictionary: dictionary))
//            })
//            self.items = matches
//            self.collectionView.reloadData()
//        }
//    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 0, bottom: 16, right: 0)
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
}
