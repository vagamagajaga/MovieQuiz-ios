//
//  QuestionFactory.swift
//  MovieQuiz

import Foundation

class QuestionFactory: QuestionFactoryProtocol {
    //MARK: - Variables
    private let moviesLoader: MoviesLoadingProtocol
    weak var delegate: QuestionFactoryDelegate?
    
    private var movies: [MostPopularMovie] = []
    private var currentMovie: MostPopularMovie?
    
    init(delegate: QuestionFactoryDelegate?, moviesLoader: MoviesLoadingProtocol) {
        self.delegate = delegate
        self.moviesLoader = moviesLoader
    }
    
    //MARK: - Error
    enum QuestionFactoryError: LocalizedError {
        case loadingError
        
        var errorDescription: String? {
            switch self {
            case .loadingError:
                return "Fail to loading data"
            }
        }
    }
    
    //MARK: - Methods
    func loadData() -> Void {
        Task { [weak self] in
            guard let self = self else { return }
            
            if let movies = try? await self.moviesLoader.loadMovies().items {
                self.movies = movies
                self.delegate?.didLoadDataFromServer()
            } else {
                self.delegate?.didFailToLoadData(with: QuestionFactoryError.loadingError)
            }
        }
    }
    
    func requestNextQuestion() {
        DispatchQueue.global().async { [weak self] in
            guard let self = self else { return }
            let index = (0..<self.movies.count).randomElement() ?? 0
            
            guard let movie = self.movies[safe: index] else { return }
            currentMovie = movie
            var imageData = Data()
            
            do {
                imageData = try Data(contentsOf: movie.resizedImageURL)
            } catch {
                print("Failed to load image")
                return
            }
            
            let rating = Float(movie.rank) ?? 0
            let randomNumberForQuestion = (6...8).randomElement() ?? 0
            let moreOrLess = ["больше", "меньше"].randomElement()!
            let text = "Рейтинг этого фильма \(moreOrLess) чем \(randomNumberForQuestion)?"
            var correctAnswer: Bool {
                moreOrLess == "больше" ? rating > Float(randomNumberForQuestion) : rating < Float(randomNumberForQuestion)
            }
            
            let question = QuizQuestion(
                image: imageData,
                text: text,
                correctAnswer: correctAnswer)
            
            DispatchQueue.main.async { [weak self] in
                guard let self = self else { return }
                self.delegate?.didReceiveNextQuestion(question: question)
            }
        }
    }
    
    func provideTrailerLink() async -> String? {
        guard let id = currentMovie?.id else { return "" }
        
        do {
            let link = try await moviesLoader.loadMoviesTrailerLink(id: id)
            return link
        } catch {
            return nil
        }
    }
    
    func getMovie() -> MostPopularMovie? {
        return currentMovie
    }
    // MARK: - Mock data
//    private let questions: [QuizQuestion] = [
//        QuizQuestion(
//            image: "The Godfather",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Dark Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Kill Bill",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Avengers",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Deadpool",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "The Green Knight",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: true),
//        QuizQuestion(
//            image: "Old",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "The Ice Age Adventures of Buck Wild",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Tesla",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false),
//        QuizQuestion(
//            image: "Vivarium",
//            text: "Рейтинг этого фильма больше чем 6?",
//            correctAnswer: false)
//    ]
}
