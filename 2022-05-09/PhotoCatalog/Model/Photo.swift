//
//  Photo.swift
//  PhotoCatalog
//
//  Created by Mikkel Sindberg Eriksen on 07/05/2022.
//

import Foundation

struct Photo: Decodable {

    let id: String
    let author: String
    let width: Int
    let height: Int
    let download_url: String

}
