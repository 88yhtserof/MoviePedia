//
//  MovieSearchViewModel.swift
//  MoviePedia
//
//  Created by 임윤휘 on 2/12/25.
//

import Foundation

final class MovieSearchViewModel: BaseViewModel {
    
    private(set) var input: Input
    private(set) var output: Output
    
    struct Input {
        let receiveSearchWord: Observable<String?> = Observable(nil)
        let viewDidLoad: Observable<Void> = Observable(())
        let search: Observable<String?> = Observable(nil)
        let willDisplaySearchList: Observable<(String, Int)?> = Observable(nil)
        let checkRecentSearchMovie: Observable<String?> = Observable(nil)
        let didTapLikesButton: Observable<(Int, Bool)?> = Observable(nil)
    }
    
    struct Output {
        let setReceivedSearchWord: Observable<String?> = Observable(nil)
        let showErrorAlert: Observable<String?> = Observable(nil)
        let updateInitialSnapshot: Observable<[Movie]?> = Observable(nil)
        let updatePagibleSnapshot: Observable<[Movie]?> = Observable(nil)
        let updateRecentSearches: Observable<String> = Observable("") // 직전 검색어 확인 용도로도 사용됨 그래서 초기값이 nil이 아닌 공백란
        let becomeFirstResponder: Observable<Void> = Observable(())
        let updateLikedMovies: Observable<(Int, Bool)?> = Observable(nil)
    }
    
    // Data
    private let networkManager = TMDBNetworkManager.shared
    private var movies: [Movie] = []
    private var currentPage: Int = 1
    private var totalPage: Int?
    private var likedMovies: [Movie] { UserDefaultsManager.likedMovies }
    
    init() {
        print("MovieSearchViewModel init")
        
        input = Input()
        output = Output()
        
        transform()
    }
    
    deinit {
        print("MovieSearchViewModel deinit")
    }
    
    func transform() {
        
        input.viewDidLoad.lazyBind { [weak self] _ in
            print("Input ViewDidLoad bind:")
            guard let self else { return }
        }
        
        input.receiveSearchWord.lazyBind { [weak self] searchWord in
            print("Input ReceiveSearchText bind: \(searchWord)")
            guard let self, let searchWord else { return }
            self.output.setReceivedSearchWord.send(searchWord)
            self.loadSearchResults(query: searchWord, isInitial: true)
        }
        
        input.search.lazyBind { [weak self] searchWord in
            print("Input Search bind: \(searchWord)")
            guard let self, let searchWord else { return }
            self.loadSearchResults(query: searchWord, isInitial: true)
            self.output.updateRecentSearches.send(searchWord)
            self.output.setReceivedSearchWord.send(searchWord)
        }
        
        input.willDisplaySearchList.lazyBind { [weak self] paginationInfo in
            print("Input WillDisplaySearchList bind")
            guard let self,
                  let (searchWord, index) = paginationInfo else { return }
            self.pagonationSearchResults(searchWord, index)
        }
        
        input.checkRecentSearchMovie.lazyBind { [weak self] text in
            print("Input CheckRecentSearchMovie bind: \(text)")
            guard let self, let text else { return }
            self.checkRecentSearchWord(text)
        }
        
        input.didTapLikesButton.lazyBind { [weak self] likedMovieInfo in
            print("Input DidTapLikesButton bind: \(likedMovieInfo)")
            guard let self, let (movieId, isSelected) = likedMovieInfo else { return }
            self.handleLikedMovie(movieId, isSelected)
        }
    }
}

private extension MovieSearchViewModel {
    
    func loadSearchResults(query: String, isInitial: Bool) {
        if isInitial {
            currentPage = 1
            movies = []
        }
        
        let request = SearchRequest(query: query, page: currentPage)
        networkManager.request(api: .search(request)) { (value: MovieResponse) in
            self.currentPage += 1
            self.totalPage = value.total_pages
            self.movies.append(contentsOf: value.results)
            if isInitial {
                self.output.updateInitialSnapshot.send(self.movies)
                
            } else {
                self.output.updatePagibleSnapshot.send(value.results)
            }
        } failureHandler: { error in
            self.output.showErrorAlert.send(error.localizedDescription)
        }
    }
    
    func pagonationSearchResults(_ searchWord: String, _ index: Int) {
        guard let totalPage else { return }
        
        if currentPage <= totalPage && index == (movies.count - 2) {
            loadSearchResults(query: searchWord, isInitial: false)
        }
    }
    
    func checkRecentSearchWord(_ text: String) {
        let receiveSearchWord = self.input.receiveSearchWord.value
        if receiveSearchWord == nil && (text.isEmpty) {
            self.output.becomeFirstResponder.send()
        }
    }
    
    func handleLikedMovie(_ likedMovieId: Int, _ isSelected: Bool) {
        guard let movie = movies.first(where: { $0.id == likedMovieId }) else { return }
        
        if isSelected {
            UserDefaultsManager.likedMovies.append(movie)
        } else if let removeIndex = UserDefaultsManager.likedMovies.firstIndex(where: {$0.id == movie.id }) {
            UserDefaultsManager.likedMovies.remove(at: removeIndex)
        }
        self.output.updateLikedMovies.send((movie.id, isSelected))
    }
}
