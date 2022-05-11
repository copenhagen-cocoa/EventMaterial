//
//  PhotoListItemView.swift
//  PhotoCatalog
//
//  Created by Mikkel Sindberg Eriksen on 07/05/2022.
//

import SwiftUI

struct PhotoListItemView: View {

    @ObservedObject var viewModel: PhotoListItemViewModel

    var body: some View {
        HStack {
            image(from: viewModel.photo)
                .resizable()
                .frame(width: 80, height: 60)
                .aspectRatio(contentMode: .fit)
            Text(viewModel.author)
        }
        .task {
            await viewModel.load()
        }

    }

    private func image(from photo: UIImage?) -> Image {
        if let photo = photo {
            return Image(uiImage: photo)
        } else {
            return Image(systemName: "photo")
        }
    }
}
