//
//  ConversationViewController.swift
//  DGChat
//
//  Created by Aman Pratap Singh on 03/10/23.
//

import UIKit
import Firebase

class ConversationViewController: UIViewController {

    @IBOutlet var chatTable: UITableView!
    
    private var conversations = [Conversation]()
    
    private let noConverstaionLabel: UILabel = {
       let label = UILabel()
        label.text = "No Conversataion"
        label.textAlignment = .center
        label.textColor = .gray
        label.font = .systemFont(ofSize: 21, weight: .medium)
        label.isHidden = true
        return label
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.addSubview(noConverstaionLabel)
        setupTableView()
        fetchConverstaion()
        configTheme()
        startListeningForConverstaion()
    }
    
    private func configTheme() {
        navigationItem.title = "Chats"
        navigationController?.navigationBar.prefersLargeTitles = true
        chatTable.backgroundColor = .purple
        
        let rightSecondBarItem = UIBarButtonItem(image: UIImage(systemName: "camera")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(didTapCameraButton))
        let rightFirstBarItem = UIBarButtonItem(image: UIImage(systemName: "plus.bubble")?.withTintColor(.white, renderingMode: .alwaysOriginal), style: .plain, target: self, action: #selector(didTapNewConversation))
        
        navigationItem.rightBarButtonItems = [rightSecondBarItem, rightFirstBarItem]
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(didTapCameraButton))
    }

    private func setupTableView() {
        chatTable.register(cellType: ConversationTableViewCell.self)
        chatTable.dataSource = self
        chatTable.delegate = self
    }
    
    private func startListeningForConverstaion() {
        let safeEmail = CommonHelper.shared.getSafeName()
        DatabaseManager.shared.getAllConversation(for: safeEmail, completion: { [weak self] result in
            switch result {
            case .success(let conversation):
                guard !conversation.isEmpty else {
                    return
                }
                self?.conversations = conversation
                DispatchQueue.main.async {
                    self?.chatTable.reloadData()
                }
            case .failure(let error):
                print("Failed to load Converstaion: \(error)")
            }
        })
    }
    
    private func fetchConverstaion() {
    }
    
    @objc func didTapNewConversation() {
        let newConversationVC = StoryboardScene.NewConversation.newConversationVC.instantiate()
        newConversationVC.completion = { [weak self] result in
            self?.createNewConversation(result: result)
        }
        let navNewConversationVC = UINavigationController(rootViewController: newConversationVC)
        present(navNewConversationVC, animated: true)
    }
    
    private func createNewConversation(result: [String: String]) {
        guard let name = result["name"],
              let email = result["email"] else {
            return
        }
        
        let chatVC = StoryboardScene.ChatScreen.chatScreen.instantiate()
        chatVC.modalPresentationStyle = .fullScreen
        chatVC.otherUserEmail = email
        chatVC.otherUserName = name
        chatVC.isNewConverstaion = true
        chatVC.conversationId = nil
        chatVC.navigationItem.title = name
        chatVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    @objc func didTapCameraButton() {}
}

extension ConversationViewController: UITableViewDelegate, UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversations.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let modelData = conversations[indexPath.row]
        let cell = tableView.dequeueReusableCell(for: indexPath, cellType: ConversationTableViewCell.self)
        cell.configure(with: modelData)
        cell.accessoryType = .disclosureIndicator
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        let modelData = conversations[indexPath.row]
        
        let chatVC = StoryboardScene.ChatScreen.chatScreen.instantiate()
        chatVC.modalPresentationStyle = .fullScreen
        chatVC.otherUserName = modelData.name
        chatVC.otherUserEmail = modelData.otherUserEmail
        chatVC.navigationItem.title = modelData.name
        chatVC.conversationId = modelData.id
        chatVC.navigationItem.largeTitleDisplayMode = .never
        self.navigationController?.pushViewController(chatVC, animated: true)
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 70
    }
}
