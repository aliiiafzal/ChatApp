//
//  VideoTableViewCell.swift
//  ChatApp
//
//  Created by Ali Afzal on 08/11/2022.
//

import UIKit

class VideoTableViewCell: UITableViewCell {

    @IBOutlet weak var videoView: UIView!
    @IBOutlet weak var videoRightImage: UIImageView!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}
