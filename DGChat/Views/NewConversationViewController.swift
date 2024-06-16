//
//  NewConversationViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 03/10/23.
//

import UIKit

class NewConversationViewController: UIViewController {
    
    @IBOutlet var searchUserTableView: UITableView!
    @IBOutlet var noUserFoundLabel: UILabel!
    
    private var users = [[String: String]]()
    private var results = [[String: String]]()
    private var hasFetched = false
    public var completion: (([String: String]) -> (Void))?
    
    private let searchBar: UISearchBar = {
       let searchBar = UISearchBar()
        searchBar.placeholder = "Search for users ..."
        return searchBar
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configTheme()
        configDependency()
        setupSearchTableView()
        keyboardHandler()
    }
    
    private func configTheme() {
        view.backgroundColor = .white
        
        self.navigationController?.navigationBar.backgroundColor = .purple
        self.navigationItem.largeTitleDisplayMode = .never
        
        navigationController?.navigationBar.topItem?.titleView = searchBar
        
        let cancelBarButtonItem = UIBarButtonItem(title: "Cancel", style: .done, target: self, action: #selector(dismissNewConvVC))
        let refreshBarButtonItem = UIBarButtonItem(image: UIImage(systemName: "gobackward"), style: .done, target: self, action: #selector(reloadUsersList))
        navigationItem.rightBarButtonItems = [refreshBarButtonItem ,cancelBarButtonItem]
        noUserFoundLabel.isHidden = true
    }
    
    private func configDependency() {
        searchBar.delegate = self
    }
    
    private func setupSearchTableView() {
        searchUserTableView.register(UITableViewCell.self, forCellReuseIdentifier: "cell")
        searchUserTableView.delegate = self
        searchUserTableView.dataSource = self
    }
    
    @objc func dismissNewConvVC() {
        self.dismiss(animated: true)
    }
    
    @objc func reloadUsersList() {
        DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
            switch result {
            case .success(let userCollection):
                self?.users = userCollection
                self?.hasFetched = true
                self?.showReloadedAlert()
            case .failure:
                print("Unable to Fetch User")
            }
        })
    }
    
    private func showReloadedAlert() {
        let reloadedAlert = UIAlertController(title: "", message: "Refreshed!", preferredStyle: .alert)
        self.present(reloadedAlert, animated: true)
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0, execute: {
            self.dismiss(animated: true)
        })
    }

}

extension NewConversationViewController: UISearchBarDelegate {
    
    func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        guard let text = searchBar.text, !text.replacingOccurrences(of: " ", with: "").isEmpty else {
            return
        }
        results.removeAll()
        self.searchUser(query: text)
    }
    
    func searchUser(query: String) {
        if hasFetched {
            filterUsers(with: query)
        } else {
            DatabaseManager.shared.getAllUsers(completion: {[weak self] result in
                switch result {
                case .success(let userCollection):
                    self?.hasFetched = true
                    self?.users = userCollection
                    self?.filterUsers(with: query)
                case .failure:
                    print("Unable to Fetch User")
                }
            })
        }
    }
    
    private func filterUsers(with term: String) {
        guard hasFetched else {
            return
        }

        var results: [[String: String]] = self.users.filter({
            guard let name = $0["name"]?.lowercased() as? String else {
                return false
            }
            return name.hasPrefix(term.lowercased())
        })
        
        self.results = results
        updateTableView()
    }
    
    private func updateTableView() {
        if results.isEmpty {
            self.noUserFoundLabel.isHidden = false
            self.searchUserTableView.isHidden = true
        } else {
            self.noUserFoundLabel.isHidden = true
            self.searchUserTableView.isHidden = false
            self.searchUserTableView.reloadData()
        }
    }
}

extension NewConversationViewController: UITableViewDelegate, UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        results.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "cell", for: indexPath)
        cell.textLabel?.text = results[indexPath.row]["name"]
        cell.accessoryType = .disclosureIndicator
        cell.selectionStyle = .default
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let targetUserData = results[indexPath.row]
        self.dismiss(animated: true) { [weak self] in
            self?.completion?(targetUserData)
        }
    }
}

extension NewConversationViewController {
    private func keyboardHandler() {
        let tap = UITapGestureRecognizer(
            target: self,
            action: #selector(UIInputViewController.dismissKeyboard)
        )
        view.addGestureRecognizer(tap)

        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillShow),
            name: UIResponder.keyboardWillShowNotification,
            object: nil
        )
        NotificationCenter.default.addObserver(
            self,
            selector: #selector(keyboardWillHide),
            name: UIResponder.keyboardWillHideNotification,
            object: nil
        )
    }

    @objc func dismissKeyboard() {
        view.endEditing(true)
    }

    @objc func keyboardWillShow(notification: NSNotification) {
        if ((notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey]
             as? NSValue)?.cgRectValue) != nil {
            if self.view.frame.origin.y == 0 {
                self.view.frame.origin.y -= 0
            }
        }
    }

    @objc func keyboardWillHide(notification: NSNotification) {
        if self.view.frame.origin.y != 0 {
            self.view.frame.origin.y = 0
        }
    }
}
