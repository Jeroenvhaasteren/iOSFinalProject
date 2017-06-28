//
//  UIImageView+Download.swift
//  partage
//
//  Created by Jeroen van Haasteren on 08/06/2017.
//  Copyright © 2017 BTS. All rights reserved.
//

import UIKit

extension UIImageView {
    func downloadImage(from url: String) {
        // create a URL object with the url string
        if let url = URL(string: url) {
            // create a request object
            let request = URLRequest(url: url)
            //create a download async task
            let downloadTask = URLSession.shared.dataTask(with: request) { data, response, error in
                // if I get data...
                if let data = data {
                    // update my image on the main thread
                    DispatchQueue.main.async {
                        self.image = UIImage(data: data)
                    }
                }
            }
            // start downloading
            downloadTask.resume()
        }
    }
}
