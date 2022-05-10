import Foundation

let articleIds = [1, 2, 3]

struct Article: Decodable {
    let id: Int
    let title: String
    let content: String
}

func downloadArticles() async throws -> [Article] {

    // Execution suspends until downloadArticle returns
    let article1 = try await downloadArticle(id: articleIds[0])

    // Execution suspends until downloadArticle returns
    let article2 = try await downloadArticle(id: articleIds[0])

    // Execution suspends until downloadArticle returns
    let article3 = try await downloadArticle(id: articleIds[0])

    // Finally we can return all articles
    return [article1, article2, article3]
}

func downloadArticlesConcurrently() async throws -> [Article] {

    // Create a task to run the async function concurrently with other code
    async let article1 = downloadArticle(id: articleIds[0])

    // Create a task to run the async function concurrently with other code
    async let article2 = downloadArticle(id: articleIds[0])

    // Create a task to run the async function concurrently with other code
    async let article3 = downloadArticle(id: articleIds[0])

    // Execution suspends until all articles have finsihed downloading.
    return try await [article1, article2, article3]
}

func downloadArticle(id: Int) async throws -> Article{
    let url = URL(string: "https://server.com/article/\(id)")!
    let (data, _) = try await URLSession.shared.data(from: url)
    return try JSONDecoder().decode(Article.self, from: data)
}
