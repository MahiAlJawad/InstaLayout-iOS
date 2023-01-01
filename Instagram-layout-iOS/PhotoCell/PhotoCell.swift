//
//  PhotoCell.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 1/1/23.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var dummyView: UIView!
    
    @IBOutlet weak var serialNumberLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func setup(_ serial: Int) {
        dummyView.backgroundColor = .random
        serialNumberLabel.text = "\(serial)"
    }
}

extension UIColor {
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0.4...1),
            green: .random(in: 0.4...1),
            blue: .random(in: 0.4...1),
            alpha: 1
        )
    }
}
