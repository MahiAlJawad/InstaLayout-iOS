//
//  PhotoCell.swift
//  Instagram-layout-iOS
//
//  Created by Mahi Al Jawad on 1/1/23.
//

import UIKit

class PhotoCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    var task: Task<(), Never>?
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView.image = nil
        task?.cancel() // Cancel any previous data task if already
    }
    
    func configure(with urlString: String, photoID: String) {
        task = Task.init {
            let result = await PhotoDownloader.shared.getPhoto(with: urlString, photoID: photoID)
            
            switch result {
            case .success(let image):
                DispatchQueue.main.async {
                    self.imageView.contentMode = .scaleToFill
                    self.imageView.image = image
                }
            case .failure(let error):
                print("Error configuring image: \(error)")
            }
        }
    }
}
