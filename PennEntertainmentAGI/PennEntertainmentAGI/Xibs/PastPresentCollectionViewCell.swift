//
//  PastPresentCollectionViewCell.swift
//  PennEntertainmentAGI
//
//  Created by Buddy Rich on 7/12/24.
//

import UIKit

class PastPresentCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var mainView: UIView!
    @IBOutlet weak var dayOfWeekLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var avgLabel: UILabel!
    @IBOutlet weak var maxLabel: UILabel!
    @IBOutlet weak var minLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        self.mainView.layer.cornerRadius = 5
        self.mainView.layer.masksToBounds = true
    }
}


