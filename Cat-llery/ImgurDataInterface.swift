//
//  ImgurDataInterface.swift
//  Cat-llery
//
//  Created by Mathy on 2019-11-13.
//  Copyright © 2019 Matheus Susin. All rights reserved.
//

import UIKit

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


class ImgurDataInterface {
    static let sharedInstance = ImgurDataInterface() // singleton

    var imageURLs: [String] = []
    weak var collectionViewController: UICollectionViewController? // holds a reference back to our gallery view controller


    func buildImageCollection(from data: [ImgurGalleryItem]) {
        for item in data {
            for image in item.images ?? [] {
                if image.link == nil || image.type?.contains("video/") ?? true { // we don't want videos or missing links
                    continue
                }
                imageURLs.append(image.link!)
            }
        }
    }

    func downloadAndDecode() {
        let imgurCatGallery = "https://api.imgur.com/3/gallery/search/?q=cats"
        let clientId = "1ceddedc03a5d71"
        guard let url = URL(string: imgurCatGallery) else { // shouldn't happen anyway, as long as imgurCatGallery is formated as a proper URL
            return
        }

        var urlRequest = URLRequest(url: url)

        urlRequest.setValue("Client-ID \(clientId)", forHTTPHeaderField: "Authorization")
        URLSession.shared.dataTask(with: urlRequest) { [weak self] data, response, error in
            guard data != nil else {
                print(error?.localizedDescription ?? "Error: failed to fetch data, received: \(String(describing: response))")
                return
            }
            // if we receive data, we decode it as a JSON
            do {
                let jsonDecoded = try JSONDecoder().decode(ImgurGallerySearchResponse.self, from: data!)
                if jsonDecoded.status == 200 { // no reason to decode if reply is not OK. we may want to change this to also accept 203 and 206
                    self!.buildImageCollection(from: jsonDecoded.data)
                    DispatchQueue.main.async {
                        self!.collectionViewController!.collectionView.reloadData() // reload the gallery, now aware of the number of images to be displayed
                    }
                }
            } catch {
                print(error.localizedDescription)
            }
        }.resume()
    }


}
