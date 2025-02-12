//
//  MovieDetailViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/13/25.
//

import Foundation

final class MovieDetailViewModel: BaseViewModel {
    
    private(set) var input: Input
    private(set) var output: Output
    
    struct Input {
        let receivedMovie: Observable<Movie?> = Observable(nil)
        let viewDidLoad: Observable<Void> = Observable(())
    }
    
    struct Output {
        let showErrorAlert: Observable<String?> = Observable(nil)
        let configureInitialViewData: Observable<Movie?> = Observable(nil)
        let createSnapshot: Observable<Void> = Observable(())
    }
    
    // Data
    private let networkManager = TMDBNetworkManager.shared
    private var backdrops: [Image] = []
    private var posters: [Image] = []
    private var credits: [Credit] = []
    
    init() {
        print("MovieDetailViewModel init")
        
        input = Input()
        output = Output()
        
        transform()
    }
    
    deinit {
        print("MovieDetailViewModel deinit")
    }
    
    func transform() {
        
        input.viewDidLoad.lazyBind { [weak self] _ in
            guard let self else { return }
            shouldLoadMovieDetail()
        }
    }
}

private extension MovieDetailViewModel {
    
    func shouldLoadMovieDetail() {
        guard let receivedMovie = input.receivedMovie.value else { return }
        self.loadMovieDetail(receivedMovie)
        output.configureInitialViewData.send(receivedMovie)
    }
    
    func loadMovieDetail(_ movie: Movie) {
        let group = DispatchGroup()
        
        group.enter()
        loadMovieImage(movie.id) {
            group.leave()
        }

        group.enter()
        loadMovieCredit(movie.id) {
            group.leave()
        }
        
        group.notify(queue: .main) {
//            self.createSnapshot()
        }
    }
    
    func loadMovieImage(_ movieId: Int, completionHandler: @escaping () -> Void) {
        let request = ImageRequest(movieID: movieId)
        networkManager.request(api: .image(request)) { [self] (image: ImageResponse) in
            self.backdrops = image.backdrops ?? []
            self.posters = image.posters ?? []
            completionHandler()
        } failureHandler: { error in
            print(error)
        }
    }
    func loadMovieCredit(_ movieId: Int, completionHandler: @escaping () -> Void) {
        let request = CreditRequest(movieID: movieId)
        networkManager.request(api: .credit(request)) { [self] (credit: CreditResponse) in
            self.credits = credit.cast ?? []
            completionHandler()
        } failureHandler: { error in
            self.output.showErrorAlert.send(error.localizedDescription)
        }
    }
}
