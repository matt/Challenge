//
//  ProfileTableViewCell.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit
import Haneke

class ProfileTableViewCell: UITableViewCell {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameLabel: UILabel!
    
    var profile: Profile! {
        didSet {
            backgroundColor = (profile.gender == .female) ? UIColor.Gender.female : UIColor.Gender.male
            nameLabel.text = profile.name
            if let imageURL = URL(string: profile.imageUrl) {
                photoImageView.hnk_setImage(from: imageURL)
            }
        }
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        photoImageView.hnk_cancelSetImage()
        photoImageView.image = nil
    }
}
