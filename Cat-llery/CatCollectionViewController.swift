//
//  CatCollectionViewController.swift
//  Cat-llery
//
//  Created by Mathy on 2019-11-12.
//  Copyright © 2019 Matheus Susin. All rights reserved.
//

import UIKit

private let reuseIdentifier = "Cat Cell"

struct ImgurImages: Decodable {
    let id: String?
    let title: String?
    let type: String?
    let animated: Bool?
    let link: String?
}

struct ImgurGalleryItem: Decodable {
    let id: String?
    let title: String?
    let datetime: Int?
    let privacy: String?
    let views: Int?
    let link: String?
    let ups: Int?
    let downs: Int?
    let points: Int?
    let score: Int?
    let is_album: Bool?
    let nsfw: Bool?
    let images: [ImgurImages]?
}

struct ImgurGallerySearchResponse: Decodable {
    let data: [ImgurGalleryItem]
    let success: Bool
    let status: Int
}

class CatCollectionViewController: UICollectionViewController, UICollectionViewDelegateFlowLayout {


    let maxImages = 60
    var imageURLs: [String] = []

    func buildImageCollection(from data: [ImgurGalleryItem]) {
        for item in data {
            for image in item.images ?? [] {
                if image.link == nil || image.type?.contains("video/") ?? true {
                    continue
                }
                imageURLs.append(image.link!)
            }
        }
    }

    func downloadAndDecode() {
        let imgurCatGallery = "https://api.imgur.com/3/gallery/search/?q=cats"
        let clientId = "1ceddedc03a5d71"
        guard let url = URL(string: imgurCatGallery) else {
            return
        }

        var urlRequest = URLRequest(url: url)

        urlRequest.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard data != nil else {
                return
            }
            do {
                let jsonDecoded = try JSONDecoder().decode(ImgurGallerySearchResponse.self, from: data!)
                if jsonDecoded.status == 200 {
                    self!.buildImageCollection(from: jsonDecoded.data)
                    DispatchQueue.main.async {
                        self!.collectionView.reloadData()
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false

        // Register cell classes
        // self.collectionView!.register(CatCollectionViewCell.self, forCellWithReuseIdentifier: reuseIdentifier)

        // Do any additional setup after loading the view.
        self.downloadAndDecode()
    }

    // MARK: UICollectionViewDataSource

    override func numberOfSections(in collectionView: UICollectionView) -> Int {
        return 1
    }

    override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return min(imageURLs.count, maxImages)
    }

    override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: reuseIdentifier, for: indexPath) as! CatCollectionViewCell
        let imageToFetch = imageURLs[indexPath.item]
        
        // Configure the cell
        cell.layer.cornerRadius = 10
        cell.label.text = "Fetching\nimage"
        cell.downloadImage(from: URL(string: imageToFetch))
    
        return cell
    }

    // MARK: UICollectionViewDelegate

    func cellSizeWhenPerLineThereAre(_ cellsPerLine: Int, inLayout layout: UICollectionViewLayout) -> CGSize {
        let flowLayout = layout as! UICollectionViewFlowLayout
        let totalInset: CGFloat = flowLayout.sectionInset.left + flowLayout.sectionInset.right
        let totalMargin: CGFloat = totalInset + flowLayout.minimumInteritemSpacing * CGFloat(cellsPerLine)
        let width: CGFloat = (self.collectionView.bounds.width - totalMargin) / CGFloat(cellsPerLine)
        return CGSize(width: width, height: width)
    }

    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {

        let sizeWhenThreePerLine =  cellSizeWhenPerLineThereAre(3, inLayout: collectionViewLayout)

        if sizeWhenThreePerLine.width > CGFloat(240) {
            return sizeWhenThreePerLine
        }
        return cellSizeWhenPerLineThereAre(2, inLayout: collectionViewLayout)
    }


}
