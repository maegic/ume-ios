//
//  MessageViewController.swift
//  Ume
//
//  Created by marui on 2020/4/13.
//  Copyright © 2020 pointer. All rights reserved.
//

import UIKit

class MessageViewController: UIViewController {
    var repository: MessageRepositoryType!
    var addMessageVCFactory: ((MessageViewController) -> AddMessageViewController)!

    @IBOutlet weak var tableView: UITableView!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    lazy var refreshControl: UIRefreshControl = {
       let item = UIRefreshControl()
       self.tableView.addSubview(item)
       return item
    }()
    
    lazy var noMoreDataLable: UILabel = {
        let item = UILabel(frame: CGRect(x: 0, y: 0, width: UIScreen.main.bounds.size.width, height: 30))
        item.text = "no more data"
        item.textAlignment = .center
        item.backgroundColor = .systemGreen
        item.textColor = .white
        return item
    }()
    
    private var messages: [MessageItem] = [] {
        didSet {
            let isEmpty = (messages.count == 0 ? true : false)
            tableView.isHidden = isEmpty
            tableView.reloadData()
        }
    }
    
    private var lastMessage: MessageItem?
    private var lastCount: Int?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupUI()
        
        loadData(isRefresh: true)
    }
    
    private func setupUI() {
        title = "Messages"
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "kUITableViewCell")
        refreshControl.addTarget(self, action: #selector(refreshData), for: .valueChanged)
    }
    
    
    @objc private func refreshData() {
        loadData(isRefresh: true)
    }
    
    @IBAction func addMessageAction(_ sender: Any) {
        let addMessageVC = addMessageVCFactory(self)
        present(addMessageVC, animated: true, completion: nil)
    }
    
    
    /// trigger pull down refresh
    func beginRefreshing() {
        let offset = CGPoint(x: 0, y: tableView.contentOffset.y - refreshControl.frame.size.height)
        tableView.setContentOffset(offset, animated: false)
        refreshControl.beginRefreshing()
        refreshControl.sendActions(for: .valueChanged)
    }
    
    /// load data
    /// - Parameter isRefresh: true: refresh new data, false: load more data
    private func loadData(isRefresh: Bool) {
        var param: [String: Any] = [
            "id": "jacoak",
            "limit": 10,
            "direction": isRefresh ? 1 : 0
        ]
        
        if !isRefresh, let lastCount = lastCount, lastCount < 10 {
            print("no more data")
            tableView.tableFooterView = noMoreDataLable
            return
        } else {
            tableView.tableFooterView = nil
        }
        
        if !isRefresh, let lastItem = lastMessage?.creationTime, lastItem > 0 {
            param["lastItem"] = lastItem
        }
        
        repository.fetchMessageItems(param) { [weak self] (result) in
            guard let this = self else {return}
            switch result {
            case .success(let data):
                print("message data: ", data)
                this.lastMessage = data.lastItem
                this.lastCount = data.count
                if isRefresh {
                    this.messages = data.items?.sorted(by: >) ?? []
                } else {
                    this.messages.append(contentsOf: data.items ?? [])
                    this.messages = this.messages.sorted(by: >)
                }
            case .failure(let error):
                this.showAlertView("ERROR", message: error.localizedDescription)
                print("error: ", error)
            }
            this.loadingView.stopAnimating()
            guard this.refreshControl.isRefreshing else { return }
            this.refreshControl.endRefreshing()
        }
    }
}

extension MessageViewController: UITableViewDataSource {
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "kUITableViewCell", for: indexPath)
        if indexPath.row % 2 != 0 {
            cell.backgroundColor = .systemTeal
        } else {
            cell.backgroundColor = .systemYellow
        }
        let message = messages[indexPath.row]
        cell.textLabel?.text =  "\(message.content ?? "") -> \(message.creationTime)"
        
        return cell
    }
}

extension MessageViewController: UITableViewDelegate {
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        let willDisplayRow = indexPath.row
        let lastSection = tableView.numberOfSections - 1

        if willDisplayRow < 0 || lastSection < 0 {
            return
        }
        let lastRow = tableView.numberOfRows(inSection: lastSection) - 1

        if willDisplayRow == lastRow {
            loadData(isRefresh: false)
        }
    }
}

