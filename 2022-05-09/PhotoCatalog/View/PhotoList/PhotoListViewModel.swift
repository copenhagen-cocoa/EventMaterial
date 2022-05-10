//
//  PhotoListViewModel.swift
//  PhotoCatalog
//
//  Created by Mikkel Sindberg Eriksen on 07/05/2022.
//

import SwiftUI

class PhotoListViewModel: ObservableObject {

    private let url = URL(string: "https://picsum.photos/v2/list")!

    @Published var itemViewModels: [PhotoListItemViewModel] = []

    func load() {
        let task = URLSession.shared.dataTask(with: url) { [weak self] data, _, _ in
            guard let data = data else { print("failed to download data"); return }
            DispatchQueue.main.async {
                do {
                    self?.itemViewModels = try JSONDecoder()
                        .decode([Photo].self, from: data)
                        .map { PhotoListItemViewModel(photo: $0) }

                } catch {
                    print("Failed to decode data")
                }
            }
        }
        task.resume()
    }
}










/*
 let (data, _) = try await URLSession.shared.data(from: url)
 itemViewModels = try JSONDecoder()
     .decode([Photo].self, from: data)
     .map { PhotoListItemViewModel(photo: $0) }
 */
