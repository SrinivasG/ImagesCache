//
//  ThumbnailCell.swift
//  CacheImagesAssignment
//
//  Created by Srinivas Gadda on 16/04/24.
//

import UIKit

class ThumbnailCell: UICollectionViewCell {
    @IBOutlet weak var thumbnailImageView: UIImageView!

    ///Configure the cell with an image
    func configureCell(with viewModel: MediaCoveragesViewModel, at index: IndexPath) {
        Task {
            do {
                let image = try await viewModel.loadImage(for: index)
                thumbnailImageView.image = image
            } catch {
                thumbnailImageView.image = UIImage(named: "NoImage")
            }
        }
    }
}
