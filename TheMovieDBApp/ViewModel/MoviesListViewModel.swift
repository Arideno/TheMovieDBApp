//
//  MoviesListViewModel.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import UIKit
import RxSwift
import RxRelay
import RxCocoa

class MoviesListViewModel {
    private let service = MovieService()
    
    private let _movies = BehaviorRelay<[Movie]>(value: [])
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    private let bag = DisposeBag()
    
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    var movies: Driver<[Movie]> {
        return _movies.asDriver()
    }
    
    var numberOfMovies: Int {
        return _movies.value.count
    }
    
    init(query: Driver<String>) {
        query
            .debounce(.milliseconds(400))
            .distinctUntilChanged()
            .drive(onNext: { [weak self] queryString in
                if !queryString.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty {
                    self?.fetchMovies(name: queryString)
                } else {
                    self?.fetchMovies()
                }
            }).disposed(by: bag)
    }
    
    func fetchMovies() {
        self._movies.accept([])
        self._isFetching.accept(true)
        
        service.getMovies { [weak self] (response) in
            self?._isFetching.accept(false)
            self?._movies.accept(response.results)
        }
    }
    
    func fetchMovies(name: String) {
        self._movies.accept([])
        self._isFetching.accept(true)
        
        service.getMoviesByName(name) { [weak self] (response) in
            self?._isFetching.accept(false)
            self?._movies.accept(response.results)
        }
    }
    
    func viewModelForMovie(at index: Int) -> MovieViewViewModel? {
        guard index < _movies.value.count else {
            return nil
        }
        return MovieViewViewModel(movie: _movies.value[index])
    }
    
}
