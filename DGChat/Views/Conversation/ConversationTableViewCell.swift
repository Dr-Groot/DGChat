//
//  ConversationTableViewCell.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 10/10/23.
//

import UIKit
import Kingfisher
import Reusable
import FirebaseStorage

class ConversationTableViewCell: UITableViewCell, NibReusable {
    
    @IBOutlet var userImageView: UIImageView!
    @IBOutlet var userNameLabel: UILabel!
    @IBOutlet var userMessageLabel: UILabel!
    
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        configureTheme()
    }
    
    private func configureTheme() {
        userImageView.contentMode = .scaleAspectFill
        userImageView.layer.cornerRadius = userImageView.frame.height / 2
        userImageView.layer.masksToBounds = true
    }
    
    public func configure(with model: Conversation) {
        self.userMessageLabel.text = model.latestMEssage.text
        self.userNameLabel.text = model.name
        
        Storage.storage().reference().child("images/\(model.otherUserEmail)_profile_picture.png").downloadURL(completion: { url, _  in
            guard let url = url else {
                return
            }
            let urlString = url.absoluteString
            self.userImageView.kf.setImage(with: URL(string: urlString))
        })
    }

}
