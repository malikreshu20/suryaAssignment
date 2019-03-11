//
//  LoadUsersListViewModel.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import Foundation
import RxSwift
import RxCocoa
import ObjectMapper

public protocol LoadUsersListViewModelType : class {
    var usersList:Variable<[Users]>{get}
    var error:Variable<Error?>{get}
    func loadListData()
}

class LoadUsersListViewModel : LoadUsersListViewModelType {
    let network:RESTNetworkClient!
    let disposeBag = DisposeBag()
    var usersList:Variable<[Users]> = Variable([])
    var error:Variable<Error?> = Variable(nil)
    
    init() {
        self.network = RESTNetworkClient()
    }
    
    func loadListData() {
        loadCache()
        fetchData().observeOn(MainScheduler.instance).subscribe({ [weak self] response in
            switch response {
            case .success(let result):
                Storage.store(result.users, to: .documents, as: "list.json")
                if let userListData = result.users {
                    self?.usersList.value = userListData
                } else {
                    self?.error.value = DataError.noContent
                }
            case .error(let error):
                self?.error.value = error
            }
        }).disposed(by: disposeBag)

    }
    
    func fetchData() -> Single<ListResponse> {
        let request = Request(method: .post, path: "/list", parameters: ["emailId" : "abc@gmail.com"])
        return network.request(request)
    }
    
    func loadCache() {
        if Storage.fileExists("list.json", in: .documents) {
            self.usersList.value = Storage.retrieve("list.json", from: .documents, as: [Users].self)
        }
    }

}
