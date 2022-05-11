//
//  PhotoListItemViewModel.swift
//  PhotoCatalog
//
//  Created by Mikkel Sindberg Eriksen on 07/05/2022.
//

import SwiftUI

class PhotoListItemViewModel: ObservableObject, Identifiable {

    private let url: URL

    @Published var photo: UIImage?

    let author: String

    init(photo: Photo) {
        self.url = URL(string: photo.download_url)!
        self.author = photo.author
    }

    func load() async {
        guard photo == nil else { return }

        // Unstructured task, does not participate in the task tree/cancellation propagation.
        // If we remove the task declaration here, the code will execute as part of the calling
        // task on view, which will cancel and propagate cancel down the task tree to the
        // URLSession data task and the resizedImage task.
        Task {
            do {
                let (data, _) = try await URLSession.shared.data(from: url)
                let image = try image(from: data)

                // Create child task (structured task), if we cancel parent task, this will cancel as well
                async let resizedImage = resizeImage(image, to: CGSize(width: 80, height: 60))

                // Await result of child task resizedImage
                let finalImage = await resizedImage

                // Force update of 'photo' onto main actor
                await MainActor.run { photo = finalImage }
            } catch {
                print("Failed to download image: \(error)")
            }
        }
    }
}

extension PhotoListItemViewModel {
    private func image(from data: Data) throws -> UIImage {
        guard let image = UIImage(data: data) else { throw "Invalid image data" }
        return image
    }

    private func resizeImage(_ image: UIImage, to size: CGSize) -> UIImage? {
        // We can explicity test if the task running our code is cancelled
        // and implement cancellation logic deal with it appropriately.
        return Task.isCancelled ? nil : image.preparingThumbnail(of: size)
    }
}
