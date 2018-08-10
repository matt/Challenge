//
//  ProfilesFilterAndSortViewController.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit

class ProfilesFilterAndSortViewController: UIViewController {

    @IBOutlet weak var femaleSwitch: UISwitch!
    @IBOutlet weak var maleSwitch: UISwitch!
    @IBOutlet weak var sortByTableView: UITableView!
    
    var filterOptions: [Gender]! {
        didSet {
            updateGenderSwitches()
        }
    }
    var sortOrder: ProfilesSortOrder!  {
        didSet {
            sortByTableView?.reloadData()
        }
    }
    
    var profilesFilterAndSortDelegate: ProfilesFilterAndSortDelegate?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        sortByTableView.tableFooterView = UIView()
        updateGenderSwitches()
    }
    
    @IBAction func toggleGenderVisibility(_ sender: UISwitch) {
        let gender: Gender = (sender == femaleSwitch) ? .female : .male
        if sender.isOn {
            filterOptions.append(gender)
        } else if let index = filterOptions.index(of: gender) {
            filterOptions.remove(at: index)
        }
    }
    
    @IBAction func resetTapped(_ sender: UIButton) {
        filterOptions = [.female, .male]
        sortOrder = .uidAscending
    }
    
    @IBAction func cancelTapped(_ sender: UIBarButtonItem) {
        dismissWithAnimation(completion: nil)
    }
    
    @IBAction func doneTapped(_ sender: UIBarButtonItem) {
        dismissWithAnimation {
            self.profilesFilterAndSortDelegate?.filterAndSort(filterBy: self.filterOptions, sortBy: self.sortOrder)
        }
    }
    
    private func dismissWithAnimation(completion: (() -> Void)?) {
        dismiss(animated: true, completion: completion)
    }
    
    private func updateGenderSwitches() {
        femaleSwitch?.isOn = filterOptions.contains(.female)
        maleSwitch?.isOn = filterOptions.contains(.male)
    }
}

extension ProfilesFilterAndSortViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 4
    }
    
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return "Sort by: \(sortOrder.textDescription())"
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "sortOrderCell", for: indexPath)
        
        let profilesSortOrder = ProfilesSortOrder(rawValue: indexPath.row + 1)
        
        cell.textLabel?.text = profilesSortOrder?.textDescription()
        cell.accessoryType = (sortOrder.rawValue == indexPath.row + 1) ? .checkmark : .none
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if indexPath == IndexPath(row: sortOrder.rawValue - 1, section: 0) {
            tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
        }
    }
}

extension ProfilesFilterAndSortViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        sortOrder = ProfilesSortOrder(rawValue: indexPath.row + 1)
    }
    
    func tableView(_ tableView: UITableView, didDeselectRowAt indexPath: IndexPath) {
        sortOrder = .uidAscending
    }
}
