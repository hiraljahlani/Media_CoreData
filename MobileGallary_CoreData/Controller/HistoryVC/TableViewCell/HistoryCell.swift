//
//  HistoryCell.swift
//  MobileGallary_CoreData
//
//  Created by Hiral Jahlani on 23/09/21.
//

import UIKit

class HistoryCell: UITableViewCell {

    @IBOutlet weak var imgPicture: UIImageView!
    @IBOutlet weak var lblDate: UILabel!
    @IBOutlet weak var lblTime: UILabel!

    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }

}
