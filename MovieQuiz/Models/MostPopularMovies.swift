import Foundation

struct MostPopularMovies: Codable {
    let items: [MostPopularMovie]
}

struct MostPopularMovie: Codable {
    let title: String
    let rating: String
    let imageURL: URL
    
    private enum CodingKeys: String, CodingKey {
        case title = "fulltitle"
        case rating = "imDBRating"
        case imageURL = "image"
    }
    
}
