//
//  NewProfileViewController.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit
import AVFoundation
import FirebaseFirestore

class NewProfileViewController: UIViewController {

    @IBOutlet weak var photoImageView: UIImageView!
    @IBOutlet weak var nameTextField: UITextField!
    @IBOutlet weak var ageTextField: UITextField!
    @IBOutlet weak var genderSegmentedControl: UISegmentedControl!
    @IBOutlet weak var hobbiesTextView: UITextView!
    @IBOutlet weak var cancelBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var doneBarButtonItem: UIBarButtonItem!
    @IBOutlet weak var scrollView: UIScrollView!
    @IBOutlet weak var addPhotoButton: UIButton!
    @IBOutlet weak var editPhotoButton: UIButton!
    @IBOutlet weak var activityView: UIView!
    @IBOutlet weak var activityIndicatorView: UIActivityIndicatorView!
    
    private lazy var imagePicker: UIImagePickerController = {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        imagePicker.mediaTypes = ["public.image"]
        return imagePicker
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.accessibilityIdentifier = "newProfileView"
        
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow(notification:)), name: .UIKeyboardDidShow, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide(notification:)), name: .UIKeyboardDidHide, object: nil)
    }   
    
    func createProfile(_ profile: Profile, withImage image: UIImage) {
        cancelBarButtonItem.isEnabled = false
        doneBarButtonItem.isEnabled = false
        activityView.isHidden = false
        activityIndicatorView.startAnimating()
        
        FirebaseService.uploadImage(image) { [unowned self] (fileURL, errorMessage) in
            if let errorMessage = errorMessage {
                self.handleError(errorMessage)
            } else if let fileUrl = fileURL {
                self.createProfile(profile, imageUrl: fileUrl.absoluteString)
            }
        }
    }
    
    private func createProfile(_ profile: Profile , imageUrl: String) {
        var profile = profile
        profile.imageUrl = imageUrl
        
        let collectionReference = FirebaseService.reference(toCollection: .profiles)
        FirebaseService.create(profile, in: collectionReference) { error in
            if let error = error {
                self.handleError(error.localizedDescription)
            } else {
                self.dismissWithAnimation(completion: nil)
            }
        }
    }
    
    func handleError(_ error: String) {
        cancelBarButtonItem.isEnabled = true
        doneBarButtonItem.isEnabled = true
        activityIndicatorView.stopAnimating()
        activityView.isHidden = true
        
        let alertViewController = UIAlertController(title: "Error", message: error, preferredStyle: .alert)
        alertViewController.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(alertViewController, animated: true, completion: nil)
    }
    
    @objc func keyboardWillShow(notification: NSNotification) {
        guard hobbiesTextView.isFirstResponder, let userInfo = notification.userInfo, let keyboardSize = (userInfo[UIKeyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue else {
            return
        }
        
        let offset = max(0, (hobbiesTextView.frame.origin.y + hobbiesTextView.bounds.size.height + 10) - (scrollView.bounds.size.height - keyboardSize.height))
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentInset = UIEdgeInsets(top: -offset, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    @objc func keyboardWillHide(notification: NSNotification) {
        guard hobbiesTextView.isFirstResponder else {
            return
        }
        
        UIView.animate(withDuration: 0.25) {
            self.scrollView.contentInset = UIEdgeInsets(top: 0.0, left: 0.0, bottom: 0.0, right: 0.0)
        }
    }
    
    @IBAction func valueChanged(_ sender: Any) {
        updateDoneButtonInteraction()
    }
    
    func updateDoneButtonInteraction() {
        if photoImageView.image != nil,
            let name = nameTextField.text, name.count > 0,
            let age = ageTextField.text, age.count > 0,
            genderSegmentedControl.selectedSegmentIndex != UISegmentedControlNoSegment,
            let hobbies = hobbiesTextView.text, hobbies.count > 0 {
            doneBarButtonItem.isEnabled = true
        } else {
            doneBarButtonItem.isEnabled = false
        }
    }

    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismissWithAnimation(completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: Any) {
        view.endEditing(false)
        let gender = Gender(rawValue: genderSegmentedControl.titleForSegment(at: genderSegmentedControl.selectedSegmentIndex)!)!
        let profile = Profile(uid: Int((Date().timeIntervalSince1970 * 1000.0).rounded()), imageUrl: "", name: nameTextField.text!, age: Int(ageTextField.text!)!, gender: gender, hobbies: hobbiesTextView.text, documentId: "")
        
        createProfile(profile, withImage: photoImageView.image!)
    }
    
    @IBAction func addPhotoTapped(_ sender: UIButton) {
        displayImageOptions(isEditing: false)
    }
    
    @IBAction func editPhotoTapped(_ sender: UIButton) {
        displayImageOptions(isEditing: true)
    }
    
    func displayImageOptions(isEditing: Bool) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        if UIImagePickerController.isSourceTypeAvailable(.camera), [.notDetermined, .authorized].contains(AVCaptureDevice.authorizationStatus(for: .video)) {
            let takePhotoAction = UIAlertAction(title: "Take Photo", style: .default) { _ in
                self.imagePicker.sourceType = .camera
                self.present(self.imagePicker, animated: true)
            }
            alertController.addAction(takePhotoAction)
        }
        let choosePhotoAction = UIAlertAction(title: "Choose Photo", style: .default) { _ in
            self.imagePicker.sourceType = .photoLibrary
            self.present(self.imagePicker, animated: true)
        }
        alertController.addAction(choosePhotoAction)
        if isEditing {
            let deletePhotoAction = UIAlertAction(title: "Delete Photo", style: .default) { _ in
                let deleteAlertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let deleteAction = UIAlertAction(title: "Delete Photo", style: .destructive) { _ in
                    self.photoImageView.image = nil
                    self.addPhotoButton.isHidden = false
                    self.editPhotoButton.isHidden = true
                }
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
                
                deleteAlertController.addAction(deleteAction)
                deleteAlertController.addAction(cancelAction)
                
                self.present(deleteAlertController, animated: true)
            }
            alertController.addAction(deletePhotoAction)
        }
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        alertController.addAction(cancelAction)
        
        present(alertController, animated: true)
    }
    
    private func dismissWithAnimation(completion: (() -> Void)?) {
        view.endEditing(false)
        dismiss(animated: true, completion: completion)
    }
}

extension NewProfileViewController: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return false
    }
}

extension NewProfileViewController: UITextViewDelegate {
    func textViewDidChange(_ textView: UITextView) {
        updateDoneButtonInteraction()
    }
    
    func textView(_ textView: UITextView, shouldChangeTextIn range: NSRange, replacementText text: String) -> Bool {
        if text == "\n" {
            textView.resignFirstResponder()
            return false
        }
        return true
    }
}

extension NewProfileViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        guard let image = info[UIImagePickerControllerOriginalImage] as? UIImage else {
            return
        }
        
        photoImageView.image = image
        addPhotoButton.isHidden = true
        editPhotoButton.isHidden = false
        updateDoneButtonInteraction()
        dismiss(animated:true, completion: nil)
    }
}
