//
//  AddMessageViewController.swift
//  Ume
//
//  Created by marui on 2020/4/13.
//  Copyright © 2020 pointer. All rights reserved.
//

import UIKit

class AddMessageViewController: UIViewController {
    var repository: MessageRepositoryType!
    var didSubmit: (() -> Void)!
    @IBOutlet weak var inputField: UITextField!
    @IBOutlet weak var loadingView: UIActivityIndicatorView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
    @IBAction func closeAction(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    
    @IBAction func submitAction(_ sender: Any) {
        
        guard let text = inputField.text,  text.count > 0 else {
            showAlertView("WARNNING", message: "Please Input Message!")
            return
        }
        let param: [String: Any] = [
             "id": "jacoak",
             "content": text,
        ]
        loadingView.startAnimating()
        repository.addMessage(param) { [weak self] (result) in
            guard let this = self else {return}
            switch result {
            case .success(let items):
                print("message items: ", items)
                this.didSubmit()
            case .failure(let error):
                this.showAlertView("ERROR", message: error.localizedDescription)
                print("error: ", error)
            }
            this.loadingView.stopAnimating()
            this.dismiss(animated: true, completion: nil)
        }
        
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        view.endEditing(true)
    }
}
