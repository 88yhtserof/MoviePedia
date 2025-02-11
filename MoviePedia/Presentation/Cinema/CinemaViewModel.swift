//
//  CinemaViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/11/25.
//

import Foundation

final class CinemaViewModel: BaseViewModel {
    
    private(set) var input: Input
    private(set) var output: Output
    
    struct Input {
        let viewDidLoad: Observable<Void> = Observable(())
    }
    
    struct Output {
        let showErrorAlert: Observable<String> = Observable("")
        let updateTodayMovieSnapshot: Observable<[Movie]?> = Observable(nil)
        let updateRecentSearchSnapshot: Observable<[RecentSearch]?> = Observable(nil)
    }
    
    // Data
    private var movies: [Movie]?
    
    init() {
        print("CinemaViewModel init")
        
        input = Input()
        output = Output()
        
        transform()
    }
    
    deinit {
        print("CinemaViewModel deinit")
    }
    
    func transform() {
        
        input.viewDidLoad.lazyBind { [weak self] _ in
            print("Input viewDidLoad bind")
            guard let self else { return }
            self.loadTodayMovies()
            self.getRecentSearches()
        }
    }
}

private extension CinemaViewModel {
    func loadTodayMovies() {
        let trendingRequest = TrendingRequest()
        TMDBNetworkManager.shared.request(api: .treding(trendingRequest)) { (trending: MovieResponse) in
            self.movies = trending.results
            self.output.updateTodayMovieSnapshot.send(self.movies)
        } failureHandler: { error in
            self.output.showErrorAlert.send(error.localizedDescription)
        }
    }
    
    func getRecentSearches() {
        let recentSearches = UserDefaultsManager.recentSearches
        let array = Array(recentSearches)
        self.output.updateRecentSearchSnapshot.send(array)
    }
}
