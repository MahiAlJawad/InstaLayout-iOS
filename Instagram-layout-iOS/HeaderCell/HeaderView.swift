//
//  HeaderView.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 14/1/23.
//

import UIKit

class HeaderView: UICollectionReusableView {
    @IBOutlet weak var headerLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func configure(with header: String) {
        headerLabel.text = header
    }
}
