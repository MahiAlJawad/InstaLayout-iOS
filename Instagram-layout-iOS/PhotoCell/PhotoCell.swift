//
//  PhotoCell.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 1/1/23.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var dataTask: URLSessionDataTask?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        dataTask?.cancel() // Cancel any previous data task if already
    }
    
    func configure() {
//        let urlString = ""
//        guard let url = URL(string: urlString) else {
//            print("Failed making url from \(urlString)")
//            return
//        }
//        
//        dataTask = URLSession.shared.dataTask(with: url) { data, _, error in
//            guard let data = data, error == nil else {
//                print("Failed downloading image data")
//                return
//            }
//            
//            guard let image = UIImage(data: data) else {
//                print("Failed downloading image from data")
//                return
//            }
//            
//            DispatchQueue.main.async {
//                print("Setting image")
//                self.imageView.contentMode = .scaleToFill
//                self.imageView.image = image
//            }
//        }
//        
//        dataTask?.resume()
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
