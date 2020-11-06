//
//  MovieViewViewModel.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import Foundation
import RxSwift
import RxRelay
import RxCocoa

class MovieViewViewModel {
    private let service = MovieService()
    private var movie: Movie!
    
    private let _isFetching = BehaviorRelay<Bool>(value: false)
    var isFetching: Driver<Bool> {
        return _isFetching.asDriver()
    }
    
    init() {}
    
    init(movie: Movie) {
        self.movie = movie
    }
    
    var id: Int {
        return movie.id
    }
    
    var title: String {
        return movie.title
    }
    
    var overview: String {
        return movie.overview
    }
    
    var posterURL: String {
        return movie.posterPath
    }
    
    var releaseDate: String {
        return movie.releaseDate
    }
    
    var genres: [Genre] {
        return movie.genres
    }
    
    func fetch(id: Int, completion: @escaping () -> ()) {
        _isFetching.accept(true)
        
        service.getMovieInfoById(id) { [weak self] (movie) in
            self?.movie = movie
            self?._isFetching.accept(false)
            completion()
        }
    }
    
}
