//
//  TableViewCell.swift
//  ChatApp
//
//  Created by Ali Afzal on 28/10/2022.
//

import UIKit

class MessageTableViewCell: UITableViewCell {
    @IBOutlet weak var rightImageView: UIImageView!
    @IBOutlet weak var messageLabel: UIView!
    @IBOutlet weak var label: UILabel!
    override func awakeFromNib() {
        super.awakeFromNib()
        messageLabel.layer.cornerRadius = messageLabel.frame.size.height / 5
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
}
