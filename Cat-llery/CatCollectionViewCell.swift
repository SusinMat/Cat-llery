//
//  CatCollectionViewCell.swift
//  Cat-llery
//
//  Created by Mathy on 2019-11-12.
//  Copyright © 2019 Matheus Susin. All rights reserved.
//

import UIKit
import SDWebImage

class CatCollectionViewCell: UICollectionViewCell {

    @IBOutlet weak var kitten: UIImageView!
    @IBOutlet weak var label: UILabel!
    @IBOutlet weak var downloadedCat: UIImageView!

    override func awakeFromNib() {
        super.awakeFromNib()
    }

    func downloadImage(from url: URL?) {
        guard url != nil else {
            return
        }
        self.downloadedCat?.sd_setImage(with: url, placeholderImage: nil, options: SDWebImageOptions.progressiveLoad)
    }

}
