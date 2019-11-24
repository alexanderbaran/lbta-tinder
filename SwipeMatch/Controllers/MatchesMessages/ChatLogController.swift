//
//  ChatLogController.swift
//  SwipeMatch
//
//  Created by Alexander Baran on 22/11/2019.
//  Copyright © 2019 Alexander Baran. All rights reserved.
//

import LBTATools

struct Message {
    let text: String
    let isFromCurrentLoggedUser: Bool
}

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

class ChatLogController: LBTAListController<MessageCell, Message>, UICollectionViewDelegateFlowLayout {
    
    private lazy var customNavBar = MessagesNavBar(match: self.match)
    
    let navBarHeight: CGFloat = 120
    
    private let match: Match
    
    init(match: Match) {
        self.match = match
        super.init()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        collectionView.alwaysBounceVertical = true
        
        items = [
            .init(text: "Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s.", isFromCurrentLoggedUser: true),
            .init(text: "Hello bud", isFromCurrentLoggedUser: false),
            .init(text: "Hello from the Tinder Course", isFromCurrentLoggedUser: false),
            .init(text: "Contrary to popular belief", isFromCurrentLoggedUser: true),
            .init(text: "There are many variations of passages of Lorem Ipsum available, but the majority have suffered alteration in some form, by injected humour, or randomised words which don't look even slightly believable. If you are going to use a passage of Lorem Ipsum, you need to be sure there isn't anything embarrassing hidden in the middle of text. All the Lorem Ipsum generators on the Internet tend to repeat predefined chunks as necessary, making this the first true generator on the Internet.", isFromCurrentLoggedUser: false)
        ]
        
        view.addSubview(customNavBar)
        customNavBar.anchor(top: view.safeAreaLayoutGuide.topAnchor, leading: view.leadingAnchor, bottom: nil, trailing: view.trailingAnchor, padding: .zero, size: .init(width: 0, height: navBarHeight))
        
        collectionView.contentInset.top = navBarHeight
        collectionView.scrollIndicatorInsets.top = navBarHeight
        
        customNavBar.backButton.addTarget(self, action: #selector(handleBack), for: .touchUpInside)
        
        let statusBarCover = UIView(backgroundColor: .white)
        view.addSubview(statusBarCover)
        statusBarCover.anchor(top: view.topAnchor, leading: view.leadingAnchor, bottom: view.safeAreaLayoutGuide.topAnchor, trailing: view.trailingAnchor)
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
