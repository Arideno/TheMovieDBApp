//
//  Movie.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import Foundation
import RxSwift
import RxRelay
import Alamofire

class MovieService {
    func getMovies(_ completion: @escaping (_ response: MovieList) -> ()) {
        let parameters = ["api_key": API_KEY]
        AF.request(TRENDING_URL, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).response(queue: DispatchQueue.global(qos: .utility)) { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        let movies = try JSONDecoder().decode(MovieList.self, from: data)
                        completion(movies)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getMoviesByName(_ name: String, _ completion: @escaping (_ response: MovieList) -> ()) {
        let parameters = ["api_key": API_KEY, "query": name]
        AF.request(SEARCH_URL, method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).response(queue: DispatchQueue.global(qos: .utility)) { response in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        let movies = try JSONDecoder().decode(MovieList.self, from: data)
                        completion(movies)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
    
    func getMovieInfoById(_ id: Int, _ completion: @escaping (_ movie: Movie) -> ()) {
        let parameters = ["api_key": API_KEY]
        AF.request(INFO_URL + "/\(id)", method: .get, parameters: parameters, encoder: URLEncodedFormParameterEncoder.default).response(queue: DispatchQueue.global(qos: .utility)) { (response) in
            switch response.result {
            case .success(let data):
                if let data = data {
                    do {
                        let movie = try JSONDecoder().decode(Movie.self, from: data)
                        completion(movie)
                    } catch let error {
                        print(error.localizedDescription)
                    }
                }
            case .failure(let error):
                print(error.localizedDescription)
            }
        }
    }
}

class Movie: Decodable {
    var id: Int
    var posterPath: String
    var title: String
    var releaseDate: String
    var overview: String
    var genres: [Genre]
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case posterPath = "poster_path"
        case title = "title"
        case releaseDate = "release_date"
        case overview = "overview"
        case genres = "genres"
    }
    
    init(id: Int, poster: String, backdrop: String, title: String, releaseDate: String, overview: String, genres: [Genre]) {
        self.id = id
        self.posterPath = poster
        self.title = title
        self.releaseDate = releaseDate
        self.overview = overview
        self.genres = genres
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? values.decode(Int.self, forKey: .id)) ?? -1
        self.posterPath = (try? values.decode(String.self, forKey: .posterPath)) ?? ""
        self.title = (try? values.decode(String.self, forKey: .title)) ?? ""
        self.releaseDate = (try? values.decode(String.self, forKey: .releaseDate)) ?? ""
        self.overview = (try? values.decode(String.self, forKey: .overview)) ?? ""
        self.genres = (try? values.decode([Genre].self, forKey: .genres)) ?? []
    }
}

class MovieList: Decodable {
    var results: [Movie]
    
    private enum CodingKeys: String, CodingKey {
        case results = "results"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.results = (try? values.decode([Movie].self, forKey: .results)) ?? []
    }
}

class Genre: Decodable {
    var id: Int
    var name: String
    
    private enum CodingKeys: String, CodingKey {
        case id = "id"
        case name = "name"
    }
    
    required init(from decoder: Decoder) throws {
        let values = try decoder.container(keyedBy: CodingKeys.self)
        self.id = (try? values.decode(Int.self, forKey: .id)) ?? 0
        self.name = (try? values.decode(String.self, forKey: .name)) ?? ""
    }
}
