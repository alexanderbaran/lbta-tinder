//
//  MatchesHorizontalController.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 24/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools
import Firebase

class MatchesHorizontalController: LBTAListController<MatchCell, Match>, UICollectionViewDelegateFlowLayout {
    
    weak var rootMatchesController: MatchesMessagesController?
    
    override func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        let match = self.items[indexPath.item]
//        let controller = ChatLogController(match: match)
//        navigationController?.pushViewController(controller, animated: true)
        rootMatchesController?.didSelectMatchFromHeader(match: match)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return .init(width: 110, height: view.frame.height)
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, insetForSectionAt section: Int) -> UIEdgeInsets {
        return .init(top: 0, left: 4, bottom: 0, right: 16)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if let layout = collectionViewLayout as? UICollectionViewFlowLayout {
            layout.scrollDirection = .horizontal
        }
        collectionView.alwaysBounceHorizontal = true
        fetchMatches()
        
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
    
}
