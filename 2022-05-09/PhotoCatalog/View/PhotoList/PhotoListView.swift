//
//  PhotoListView.swift
//  PhotoCatalog
//
//  Created by Mikkel Sindberg Eriksen on 07/05/2022.
//

import SwiftUI

struct PhotoListView: View {

    @StateObject private var viewModel: PhotoListViewModel

    init() {
        _viewModel = StateObject(wrappedValue: PhotoListViewModel())
    }

    var body: some View {
        List {
            ForEach(viewModel.itemViewModels) { viewModel in
                PhotoListItemView(viewModel: viewModel)
            }
        }
        .onAppear {
            viewModel.load()
        }
    }
}
