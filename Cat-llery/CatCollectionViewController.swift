//
//  CatCollectionViewController.swift
//  Cat-llery
//
//  Created by Mathy on 2019-11-12.
//  Copyright © 2019 Matheus Susin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cat Cell"

class CatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {

    let maxImages = 60 // limits the amount of images that will be downloaded and displayed to the user


    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        if #available(iOS 11.0, *) {
            if let flowLayout = collectionView?.collectionViewLayout as? UICollectionViewFlowLayout {
                flowLayout.sectionInsetReference = .fromSafeArea // add inset to stop one of the cells from getting under the iPhone 11 notch when in horizontal orientation
            }
        }
        ImgurDataInterface.sharedInstance.collectionViewController = self
        ImgurDataInterface.sharedInstance.downloadAndDecode()

    }

    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        flowLayout.invalidateLayout()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(ImgurDataInterface.sharedInstance.imageURLs.count, maxImages)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell
        let imageToFetch = ImgurDataInterface.sharedInstance.imageURLs[indexPath.item]
        let resizedImageToFetch = ImgurDataInterface.imgurResize(link: imageToFetch)

        // let cellWidth = cell.frame.width

        // Configure the cell
        cell.layer.cornerRadius = 10 // the PDF showed images with rounded corners, so I added this
        cell.label.text = "Fetching\nimage" // placeholder
        cell.downloadImage(from: URL(string: resizedImageToFetch))
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    func cellSizeWhenPerLineThereAre(_ cellsPerLine: Int, inLayout layout: UICollectionViewLayout) -> CGSize {
        if cellsPerLine < 1 { // shoud never happen
            return CGSize(width: 0.0, height: 0.0)
        }
        let flowLayout = layout as! UICollectionViewFlowLayout
        let totalInset: CGFloat = flowLayout.sectionInset.left + self.view.safeAreaInsets.left + flowLayout.sectionInset.right + self.view.safeAreaInsets.right
        let totalMargin: CGFloat = totalInset + flowLayout.minimumInteritemSpacing * (CGFloat(cellsPerLine) - 1)
        let width: CGFloat = (self.collectionView.bounds.width - totalMargin) / CGFloat(cellsPerLine)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sizeWhenThreePerLine =  cellSizeWhenPerLineThereAre(3, inLayout: collectionViewLayout)

        if sizeWhenThreePerLine.width >= CGFloat(240) {
            return sizeWhenThreePerLine
        }
        return cellSizeWhenPerLineThereAre(2, inLayout: collectionViewLayout) // if the images would be too small, we only draw two per line
    }


}
