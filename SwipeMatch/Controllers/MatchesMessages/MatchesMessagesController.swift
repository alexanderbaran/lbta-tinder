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

struct Match {
    let name, profileImageUrl: String
    
    init(dictionary: [String: Any]) {
        self.name = dictionary["name"] as? String ?? ""
        self.profileImageUrl = dictionary["profileImageUrl"] as? String ?? ""
    }
    
}

class MatchCell: LBTAListCell<Match> {
    
    let profileImageView = UIImageView(image: UIImage(named: "kelly1"), contentMode: .scaleAspectFill)
    let usernameLabel = UILabel(text: "Username Here", font: .systemFont(ofSize: 14, weight: .semibold), textColor: #colorLiteral(red: 0.2135103005, green: 0.2311722682, blue: 0.25683072, alpha: 1), textAlignment: .center, numberOfLines: 2)
    
    override var item: Match! {
        didSet {
            usernameLabel.text = item.name
            profileImageView.sd_setImage(with: URL(string: item.profileImageUrl))
        }
    }
    
    override func setupViews() {
        super.setupViews()
        
        profileImageView.clipsToBounds = true
        profileImageView.constrainWidth(80)
        profileImageView.constrainHeight(80)
        profileImageView.layer.cornerRadius = 80 / 2
        
        stack(stack(profileImageView, alignment: .center), usernameLabel)
    }
}

class MatchesMessagesController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
    
    let customNavBar = MatchesNavBar()
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 120, height: 140)
    }
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let match = items[indexPath.item]
        let chatLogController = ChatLogController(match: match)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        items = [
//            .init(name: "test", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/lbta-swipematch.appspot.com/o/images%2F382CA931-0966-42DA-B7E3-2E470E5126C7?alt=media&token=9fef7211-0636-4e03-bfb5-e0d6ac6a329e"),
//            .init(name: "test", profileImageUrl: "https://firebasestorage.googleapis.com/v0/b/lbta-swipematch.appspot.com/o/images%2F382CA931-0966-42DA-B7E3-2E470E5126C7?alt=media&token=9fef7211-0636-4e03-bfb5-e0d6ac6a329e"),
//            .init(name: "test", profileImageUrl: "profileUrl")
//        ]
        
        fetchMatches()
        
        collectionView.backgroundColor = .white
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .zero, size: .init(width: 0, height: 150))
        
        collectionView.contentInset.top = 150
    }
    
    private func fetchMatches() {
        guard let currentUserId = Auth.auth().currentUser?.uid else { return }
        Firestore.firestore().collection("matches_messages").document(currentUserId).collection("matches").getDocuments { (querySnapshot: QuerySnapshot?, err: Error?) in
            if let err = err {
                print("Failed to fetch matches:", err)
                return
            }
            print("Here are my matches documents")
            var matches = [Match]()
            querySnapshot?.documents.forEach({ (queryDocumentSnapshot: QueryDocumentSnapshot) in
//                print(queryDocumentSnapshot.data())
                let dictionary = queryDocumentSnapshot.data()
                matches.append(.init(dictionary: dictionary))
            })
            self.items = matches
            self.collectionView.reloadData()
        }
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 16, left: 0, bottom: 16, right: 0)
    }
    
    @objc private func handleBack() {
        navigationController?.popViewController(animated: true)
    }
    
}
