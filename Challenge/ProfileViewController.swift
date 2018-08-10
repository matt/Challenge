//
//  ProfileViewController.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/5/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit
import Firebase
import FirebaseFirestore
import Haneke

protocol EditHobbiesDelegate {
    func updateHobbies(_ hobbies: String)
}

class ProfileViewController: UIViewController {
    
    @IBOutlet weak var genderColorView: UIView!
    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var detailsTableView: UITableView!
    @IBOutlet weak var rightBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var deleteProfileButton: UIButton!
    
    var profile: Profile!
    var profileReference: DocumentReference!
    var profileDetails: [[ProfileDataKey: String]]!
    var updatedHobbies: String!
    var isEditModeEnabled = false
    
    private var listener: ListenerRegistration?
    private var documentReference: DocumentReference!
    
    enum ProfileDataKey {
        case title, data
    }
    
    enum ProfileTitleValue: String {
        case age = "Age"
        case gender = "Gender"
        case hobbies = "Hobbies"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        documentReference = FirebaseService.reference(toCollection: .profiles).document(profile.documentId)
        listener = FirebaseService.read(fromDocument: documentReference, returning: Profile.self) { (profile) in
            guard let profile = profile else {
                self.displayProfileRemovedAlert()
                return
            }
            
            self.profile = profile
            self.profileDetails = self.configureDetails(forProfile: profile)
            if !self.isEditModeEnabled {
                self.detailsTableView.reloadData()
            }
        }
        
        detailsTableView.tableFooterView = UIView()
        
        genderColorView.backgroundColor = (profile.gender == .female) ? UIColor.Gender.female : UIColor.Gender.male
        name.text = profile.name
        
        if let imageURL = URL(string: profile.imageUrl) {
            photoImageView.hnk_setImage(from: imageURL)
        }
        
        profileDetails = self.configureDetails(forProfile: profile)
    }
    
    func configureDetails(forProfile profile: Profile) -> [[ProfileDataKey: String]] {
        return [
            [.title: ProfileTitleValue.age.rawValue, .data: String(profile.age)],
            [.title: ProfileTitleValue.gender.rawValue, .data: profile.gender.rawValue],
            [.title: ProfileTitleValue.hobbies.rawValue, .data: profile.hobbies]
        ]
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardDidHide, object: nil)
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let offset = max(0, (detailsTableView.frame.origin.y + detailsTableView.contentSize.height) - (view.bounds.size.height - keyboardSize.height))
        
        UIView.animate(withDuration: 0.25) {
            self.detailsTableView.contentInset = UIEdgeInsets(top: -offset, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        UIView.animate(withDuration: 0.25) {
            self.detailsTableView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    @IBAction func deleteProfileButtonTapped(_ sender: UIButton) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let deleteAction = UIAlertAction(title: "Delete Profile", style: .destructive) { _ in
            self.listener?.remove()
            if let match = self.profile.imageUrl.range(of: "(?<=images%2F)[^?]+", options: .regularExpression) {
                let fileName = String(self.profile.imageUrl[match])
                FirebaseService.deleteImage(fileName: fileName)
                FirebaseService.delete(self.documentReference)
                self.navigationController?.popViewController(animated: true)
            }
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        
        alertController.addAction(deleteAction)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    @IBAction func toggleEditingTapped(_ sender: UIBarButtonItem) {
        isEditModeEnabled = !isEditModeEnabled
        rightBarButtonItem.title = isEditModeEnabled ? "Done" : "Edit"
        deleteProfileButton.isHidden = !isEditModeEnabled
        if isEditModeEnabled {
            updatedHobbies = profile.hobbies
        } else if updatedHobbies != profile.hobbies {
            profile.hobbies = updatedHobbies
            
            FirebaseService.update(data: [ "hobbies": profile.hobbies ], in: documentReference)
            
            if let index = profileDetails.index(where: { $0[.title] == ProfileTitleValue.hobbies.rawValue }) {
                profileDetails[index][.data] = updatedHobbies
            }
        }
        detailsTableView.reloadData()
    }
    
    func displayProfileRemovedAlert() {
        let alertController = UIAlertController(title: "Profile Removed", message: "This profile has been removed. You will be taken back to the list of profiles.", preferredStyle: .alert)
        let okAction = UIAlertAction(title: "OK", style: .default) { _ in
            self.navigationController?.popViewController(animated: true)
        }
        
        alertController.addAction(okAction)
        
        present(alertController, animated: true)
    }
    
    deinit {
        listener?.remove()
    }
}

extension ProfileViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 3
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let profileDetail = profileDetails[indexPath.row]
        
        if indexPath.row < 2 {
            let cell = tableView.dequeueReusableCell(withIdentifier: "profileDetailCell", for: indexPath) as! ProfileDetailTableViewCell
            
            cell.titleLabel.text = profileDetail[.title]
            cell.dataLabel.text = profileDetail[.data]
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "editProfileDetailCell", for: indexPath) as! EditProfileDetailTableViewCell
            
            cell.titleLabel.text = profileDetail[.title]
            cell.dataTextView.text = profileDetail[.data]
            cell.dataTextView.isEditable = isEditModeEnabled
            cell.editHobbiesDelegate = self
            
            return cell
        }
    }
}

extension ProfileViewController: EditHobbiesDelegate {
    func updateHobbies(_ hobbies: String) {
        updatedHobbies = hobbies
    }
}
