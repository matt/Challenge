//
//  EditProfileDetailTableViewCell.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/5/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit

class EditProfileDetailTableViewCell: UITableViewCell {

    @IBOutlet weak var titleLabel: UILabel!
    @IBOutlet weak var dataTextView: UITextView!
    
    var editHobbiesDelegate: EditHobbiesDelegate?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        
        dataTextView.textContainerInset = .zero
        dataTextView.textContainer.lineFragmentPadding = 0
        dataTextView.delegate = self
    }
}

extension EditProfileDetailTableViewCell: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        editHobbiesDelegate?.updateHobbies(textView.text)
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}
