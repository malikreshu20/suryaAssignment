//
//  LoadUsersListViewController.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import UIKit
import RxSwift
import RxCocoa
import Alamofire

class LoadUsersListViewController: UIViewController {
        var viewModel: LoadUsersListViewModelType!
        let disposeBag = DisposeBag()
        @IBOutlet weak var listTableView: UITableView!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.viewModel = LoadUsersListViewModel()
        bindTableView()
        viewModel.loadListData()
        // Do any additional setup after loading the view, typically from a nib.
    }

    func bindTableView () {
        listTableView.delegate = nil
        listTableView.dataSource = nil
        self.listTableView.register(UINib(nibName: "UserTableViewCell", bundle: .main), forCellReuseIdentifier: "UserTableViewCell")
        
        viewModel.usersList.asObservable().bind(to: listTableView.rx.items(cellIdentifier: "UserTableViewCell", cellType: UserTableViewCell.self)) {
            (_, user, cell) in
            cell.configureCell(user:user)
            cell.layoutIfNeeded()
            }.disposed(by: disposeBag)
        
        viewModel.error.asObservable().subscribe(onNext: { [weak self] error in
            if let err = error {
                self?.showAlert(error:err)
            }
        }).disposed(by: disposeBag)
    }
    
    func showAlert(error:Error) {
        let alert = UIAlertController(title: "Something went wrong" , message: error.localizedDescription, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }

}

