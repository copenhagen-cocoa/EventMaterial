//: A UIKit based Playground for presenting user interface
  
import SwiftUI

actor Article {

    let title = "Actors 101"
    let subtitle = "Isolation and other topics"
    var isPublished = false

    nonisolated var fullTitle: String {
        title + ": " + subtitle
    }

    func togglePublished() {
        isPublished.toggle()
    }
}

let article = Article()

// Need an async context to access isolated properties or methods:
Task {
    await print(article.isPublished)
    await article.togglePublished()
}

// Can access constant and nonisolated properties freely:
print(article.title)
print(article.fullTitle)
