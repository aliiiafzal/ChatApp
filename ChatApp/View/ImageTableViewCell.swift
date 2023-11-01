//
//  ImageTableViewCell.swift
//  ChatApp
//
//  Created by Ali Afzal on 08/11/2022.
//

import UIKit

class ImageTableViewCell: UITableViewCell {
    
    @IBOutlet weak var messageImageView: UIImageView!
    @IBOutlet weak var imageRightImage: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
