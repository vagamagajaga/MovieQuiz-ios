//
//  MoviesLoader.swift
//  MovieQuiz
//
//  Created by Vagan Galstian on 26.11.2022.
//

import Foundation

struct MoviesLoader: MoviesLoadingProtocol {
    // MARK: - Error
    private enum MoviesLoaderError: LocalizedError {
        case decodeError
        case loadError(message: String)
        var errorDescription: String? {
            switch self {
            case .decodeError:
                return "Decode Error"
            case .loadError(let message):
                return "Load Error: \(message)"
            }
        }
    }
    
    // MARK: - NetworkClient
    private let networkClient: NetworkRouting
    
    init(networkClient: NetworkRouting = NetworkClient()){
        self.networkClient = networkClient
    }
    
    // MARK: - URL
    private var moviesUrl: URL {
        guard let url = URL(string: "https://imdb-api.com/en/API/Top250Movies/k_r0f51fxi") else {
            preconditionFailure("Unable to construct moviesUrl")
        }
        return url
    }
    
    func loadMovies(handler: @escaping (Result<MostPopularMovies, Error>) -> Void) {
        networkClient.fetch(url: moviesUrl) { result in
            switch result {
            case .failure(let error):
                handler(.failure(error))
            case .success(let data):
                guard let decodedMovies = try? JSONDecoder().decode(MostPopularMovies.self, from: data) else {
                    handler(.failure(MoviesLoaderError.decodeError))
                    return
                }
                if decodedMovies.errorMessage.isEmpty {
                    handler(.success(decodedMovies))
                } else {
                    handler(.failure(MoviesLoaderError.loadError(message: decodedMovies.errorMessage)))
                }
            }
        }
    }
}


