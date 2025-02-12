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
        let didLikedButtonTapped: Observable<(Int, Bool)?> = Observable(nil)
        let pushToMovieSearchVC: Observable<(Int, Bool)?> = Observable(nil)
    }
    
    struct Output {
        let showErrorAlert: Observable<String> = Observable("")
        let updateTodayMovieSnapshot: Observable<[MovieInfo]?> = Observable(nil)
        let updateRecentSearchSnapshot: Observable<[RecentSearch]?> = Observable(nil)
        let updateUser: Observable<User?> = Observable(nil)
        let updateLikedMoviesCount: Observable<Int?> = Observable(nil)
        let updateCellWithLikedMovie: Observable<(IndexPath, Bool)?> = Observable(nil)
    }
    
    // Data
    var movies: [Movie]?
    var movieInfoList: [MovieInfo]?
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    
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
            self.getUser()
            self.getLikedMoviesCount()
        }
        
        input.didLikedButtonTapped.lazyBind { [weak self] likedResult in
            print("Input didLikedButtonTapped bind")
            guard let self,
                  let likedResult else { return }
            self.handleLikedMovie(likedResult)
        }
        
        input.pushToMovieSearchVC.lazyBind { [weak self] likedMovieInfo in
            print("Input pushToMovieSearchVC bind")
            guard let self, let likedMovieInfo else { return }
            self.handleLikedMovieIndexPath(likedMovieInfo)
        }
    }
}

private extension CinemaViewModel {
    func loadTodayMovies() {
        let trendingRequest = TrendingRequest()
        TMDBNetworkManager.shared.request(api: .treding(trendingRequest)) { (trending: MovieResponse) in
            self.movies = trending.results
            
            self.movieInfoList = self.movies!.map{ movie in
                let isLiked = self.likedMovies.contains(where: { $0.id == movie.id })
                return MovieInfo(movie: movie, isLiked: isLiked)
            }
            self.output.updateTodayMovieSnapshot.send(self.movieInfoList)
        } failureHandler: { error in
            self.output.showErrorAlert.send(error.localizedDescription)
        }
    }
    
    func getRecentSearches() {
        let recentSearches = UserDefaultsManager.recentSearches
        let array = Array(recentSearches)
        self.output.updateRecentSearchSnapshot.send(array)
    }
    
    func getUser() {
        let user = UserDefaultsManager.user
        self.output.updateUser.send(user)
    }
    
    func getLikedMoviesCount() {
        let likedMoviesCount = likedMovies.count
        self.output.updateLikedMoviesCount.send(likedMoviesCount)
    }
    
    func handleLikedMovie(_ likedResult: (Int, Bool)) {
        let (movieId, isSelected) = likedResult
        guard let index = movies?.firstIndex(where: { $0.id == movieId }),
              let movie = movies?[index],
              movieInfoList != nil  else {
            print("Could not find movie")
            return
        }
        
        movieInfoList![index].isLiked = isSelected
        
        if isSelected {
            UserDefaultsManager.likedMovies.append(movie)
        } else if let removeIndex = UserDefaultsManager.likedMovies.firstIndex(where: {$0.id == movie.id }) {
            UserDefaultsManager.likedMovies.remove(at: removeIndex)
        }
        
        self.getLikedMoviesCount()
    }
    
    func handleLikedMovieIndexPath(_ likedResult: (Int, Bool)) {
        let (movieId, isLiked) = likedResult
        guard let movieIndex = movies?.firstIndex(where: { $0.id == movieId })
        else { return }
        movieInfoList?[movieIndex].isLiked = isLiked
        
        let indexPath = IndexPath(item: movieIndex, section: 2)
        output.updateCellWithLikedMovie.send((indexPath, isLiked))
    }
}
