import Foundation

enum URLError: Error {
    case downloadFailed
}

let url = URL(string: "https://www.meetup.com/CopenhagenCocoa/")!

// Completion based API
func download(from url: URL, completion: @escaping (Result<Data, Error>) -> Void) {
    let task = URLSession.shared.dataTask(with: url) { data, response, error in
        guard let data = data else {
            completion(.failure(URLError.downloadFailed))
            return
        }
        completion(.success(data))
    }
    task.resume()
}

// Async based API
func download(from url: URL) async throws -> (Data, URLResponse) {
    return try await URLSession.shared.data(from: url)
}
