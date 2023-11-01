//
//  OtherVideoTableViewCell.swift
//  ChatApp
//
//  Created by Ali Afzal on 16/11/2022.
//

import UIKit

class OtherVideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoLeftImage: UIImageView!
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
