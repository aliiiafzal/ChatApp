//
//  OtherImageTableViewCell.swift
//  ChatApp
//
//  Created by Ali Afzal on 16/11/2022.
//

import UIKit

class OtherImageTableViewCell: UITableViewCell {

    @IBOutlet weak var imageLeftImage: UIImageView!
    @IBOutlet weak var messageImageView: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
