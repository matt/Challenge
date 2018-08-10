//
//  ProfilesTableViewController.swift
//  Challenge
//
//  Created by Matthew Mohrman on 8/3/18.
//  Copyright © 2018 Matthew Mohrman. All rights reserved.
//

import UIKit
import FirebaseFirestore

protocol ProfilesFilterAndSortDelegate {
    func filterAndSort(filterBy filterOptions: [Gender], sortBy sortOrder: ProfilesSortOrder)
}

class ProfilesTableViewController: UITableViewController {
    
    private var filterOptions = [Gender.female, Gender.male]
    private var sortOrder = ProfilesSortOrder.uidAscending
    private var profiles: [Profile] = []
    private var query: Query? {
        didSet {
            observeQuery()
        }
    }
    private var listener: ListenerRegistration?
    
    private func baseQuery() -> Query {
        return FirebaseService.reference(toCollection: .profiles)
    }
    
    private func observeQuery() {
        stopObserving()
        guard let query = query else {
            profiles = []
            tableView.reloadData()
            return
        }
        
        listener = FirebaseService.read(fromQuery: query, returning: Profile.self, completion: { profiles in
            self.profiles = profiles
            self.tableView.reloadData()
        })
    }
    
    private func stopObserving() {
        listener?.remove()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.tableFooterView = UIView()
        query = query(filterBy: filterOptions, sortBy: sortOrder)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        observeQuery()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopObserving()
    }

    deinit {
        listener?.remove()
    }
    
    func query(filterBy filterOptions: [Gender], sortBy sortOrder: ProfilesSortOrder) -> Query? {
        guard filterOptions.count > 0 else {
            return nil
        }
        
        var query = baseQuery()
        if filterOptions.count == 1, let gender = filterOptions.first?.rawValue {
            query = query.whereField("gender", isEqualTo: gender)
        }
        let sortLogic = sortOrder.sortLogic()
        query = query.order(by: sortLogic.field, descending: sortLogic.isDescending)
        
        return query
    }

    // MARK: - Table view data source

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return profiles.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "profileCell", for: indexPath) as! ProfileTableViewCell

        let profile = profiles[indexPath.row]
        cell.profile = profile

        return cell
    }

    // MARK: - Navigation

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if let profileViewController = segue.destination as? ProfileViewController {
            guard let cell = sender as? UITableViewCell, let indexPath = tableView.indexPath(for: cell) else {
                return
            }
            
            profileViewController.profile = profiles[indexPath.row]
        } else if let navigationController = segue.destination as? UINavigationController {
            if let profilesFilterAndSortViewController = navigationController.topViewController as? ProfilesFilterAndSortViewController {
                profilesFilterAndSortViewController.profilesFilterAndSortDelegate = self
                profilesFilterAndSortViewController.filterOptions = filterOptions
                profilesFilterAndSortViewController.sortOrder = sortOrder
            }
        }
    }
}

extension ProfilesTableViewController: ProfilesFilterAndSortDelegate {
    func filterAndSort(filterBy filterOptions: [Gender], sortBy sortOrder: ProfilesSortOrder) {
        self.filterOptions = filterOptions
        self.sortOrder = sortOrder
        
        query = query(filterBy: filterOptions, sortBy: sortOrder)
    }
}
