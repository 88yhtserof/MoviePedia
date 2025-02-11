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
    }
    
    struct Output {
        let searchWord: Observable<String?> = Observable(nil)
        let showErrorAlert: Observable<String?> = Observable(nil)
        let updateInitialSnapshot: Observable<[Movie]?> = Observable(nil)
        let updatePagibleSnapshot: Observable<[Movie]?> = Observable(nil)
    }
    
    // Data
    private let networkManager = TMDBNetworkManager.shared
    private var movies: [Movie] = []
    private var currentPage: Int = 1
    private var totalPage: Int?
    
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
            self.output.searchWord.send(searchWord)
            self.loadSearchResults(query: searchWord, isInitial: true)
        }
        
        input.search.lazyBind { [weak self] searchWord in
            print("Input Search bind: \(searchWord)")
            guard let self, let searchWord else { return }
            self.loadSearchResults(query: searchWord, isInitial: true)
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
}
