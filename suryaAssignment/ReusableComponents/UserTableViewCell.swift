//
//  UserTableViewCell.swift
//  suryaAssignment
//
//  Created by Reshu Malik on 10/03/19.
//  Copyright © 2019 Reshu Malik. All rights reserved.
//

import UIKit
import RxSwift
import Alamofire
import Kingfisher

class UserTableViewCell: UITableViewCell {

    @IBOutlet weak var nameLabel: UILabel!
    @IBOutlet weak var userImage: UIImageView!
    @IBOutlet weak var emailLbl: UILabel!
    let network = RESTNetworkClient()
    let bag = DisposeBag()

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(false, animated: animated)
    }
    
    func configureCell(user:Users) {
        var firstName = user.firstName ?? ""
        firstName.append(" ")
        let name = firstName + (user.lastName ?? "" )
        self.nameLabel.text = name
        self.emailLbl.text = user.emailId
        self.setImage(user: user)
    }
    
    func setImage(user:Users) {
        let placeholderImage = UIImage(named: "placeHolder")
        if let imgURL = user.imageUrl {
            let url = URL(string: imgURL)
            userImage.kf.setImage(with: url, placeholder: placeholderImage) { (image, error, cacheType, imageUrl) in
                if (image == nil && error?.code == 10002) {
                    self.userImage.image = placeholderImage
                }
            }
        } else {
            self.userImage.image = placeholderImage
        }
    }
    
    
}


