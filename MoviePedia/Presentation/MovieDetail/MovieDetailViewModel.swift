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
        let configureInitialViewData: Observable<(Movie)?> = Observable(nil)
        let createSnapshot: Observable<MovieDetail?> = Observable(nil)
        let configureMovieDetailInfo: Observable<(String, String, String)?> = Observable(nil)
    }
    
    // Data
    private let networkManager = TMDBNetworkManager.shared
    var backdrops: [Image] = []
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
            print("Input viewDidLoad bind")
            guard let self else { return }
            self.shouldLoadMovieDetail()
            self.configureMovieDetailInfo()
        }
    }
}

extension MovieDetailViewModel {
    
    typealias MovieDetail = (backdropItems: [Item], synopsysItems: [Item], creditItems: [Item], posterItems: [Item])
    
    enum Section: Int {
        case backdrop
        case synopsis
        case cast
        case poster
        
        var header: String? {
            switch self {
            case .backdrop:
                return nil
            case .synopsis:
                return "Synopsis"
            case .cast:
                return "Cast"
            case .poster:
                return "Poster"
            }
        }
    }
    
    enum Item: Hashable {
        case backdrop(Identifier<Image>)
        case synopsis(Identifier<String>)
        case cast(Identifier<Credit>)
        case poster(Identifier<Image>)
    }
}

private extension MovieDetailViewModel {
    
    func shouldLoadMovieDetail() {
        guard let receivedMovie = input.receivedMovie.value else { return }
        self.loadMovieDetail(receivedMovie)
        self.output.configureInitialViewData.send(receivedMovie)
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
        
        group.notify(queue: .main) { [weak self] in
            guard let self else { return }
            self.configureMoiveDetail()
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
    
    func configureMoiveDetail() {
        guard let movie = input.receivedMovie.value else { return }
        let backdropItems = self.backdrops.prefix(5).map{ Item.backdrop(Identifier(value: $0)) }
        let synopsysItems = [Item.synopsis(Identifier(value: movie.overview ?? ""))]
        let creditItems = credits.map{ Item.cast(Identifier(value: $0)) }
        let posterItems: [Item] = self.posters.map{ Item.poster(Identifier(value: $0)) }
        let movieDetail = (backdropItems, synopsysItems, creditItems, posterItems)
        
        output.createSnapshot.send(movieDetail)
    }
    
    func configureMovieDetailInfo() {
        guard let movie = input.receivedMovie.value else { return }
        
        let dateStr = movie.release_date ?? "_"
        let ratingStr = String(movie.vote_average ?? 0.0)
        let genres = (movie.genre_ids?.prefix(2).compactMap{ Genre(rawValue: $0)?.name_kr }) ?? []
        let genreStr = genres.joined(separator: ", ")
        output.configureMovieDetailInfo.send((dateStr, ratingStr, genreStr))
    }
}
