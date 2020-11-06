//
//  MoviesListViewController.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import UIKit
import RxSwift
import RxCocoa

class MoviesListViewController: UIViewController {
    
    var movieListViewViewModel: MoviesListViewModel!
    let disposeBag = DisposeBag()
    
    var collectionView: UICollectionView!
    var searchBar: UISearchBar!
    
    lazy var refreshControl: UIRefreshControl = {
        let refresh = UIRefreshControl()
        refresh.tintColor = .white
        refresh.addTarget(self, action: #selector(self.refreshMovies), for: .valueChanged)
        return refresh
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupSearchBar()
        setupCollectionView()
        
        movieListViewViewModel = MoviesListViewModel(query: searchBar.rx.text.orEmpty.asDriver())
        movieListViewViewModel.movies.drive(onNext: { [unowned self] _ in
            self.collectionView.reloadData()
        }).disposed(by: disposeBag)
        
        movieListViewViewModel.isFetching.drive(refreshControl.rx.isRefreshing).disposed(by: disposeBag)
        
        let tap = UITapGestureRecognizer()
        tap.cancelsTouchesInView = false
        view.addGestureRecognizer(tap)
        tap.rx.event.bind(onNext: { [unowned searchBar] (recognizer) in
            searchBar?.resignFirstResponder()
        }).disposed(by: disposeBag)
    }
    
    func setupSearchBar() {
        searchBar = UISearchBar(frame: CGRect(x: 0, y: 0, width: view.frame.width, height: 40))
        searchBar.enablesReturnKeyAutomatically = true
        searchBar.placeholder = "Search for movie..."
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: searchBar)
        
        searchBar.rx.searchButtonClicked.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar?.resignFirstResponder()
            }).disposed(by: disposeBag)
        
        searchBar.rx.cancelButtonClicked.asDriver(onErrorJustReturn: ())
            .drive(onNext: { [unowned searchBar] in
                searchBar?.resignFirstResponder()
            }).disposed(by: disposeBag)
    }
    
    func setupCollectionView() {
        let layout = UICollectionViewFlowLayout()
        layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        let width = self.view.frame.size.width / 3 - 20
        layout.itemSize = CGSize(width: width, height: 200)
        collectionView = UICollectionView(frame: self.view.frame, collectionViewLayout: layout)
        collectionView.backgroundColor = .black
        collectionView.delegate = self
        collectionView.dataSource = self
        collectionView.register(MovieCell.self, forCellWithReuseIdentifier: "Cell")
        collectionView.refreshControl = refreshControl
        view.addSubview(collectionView)
        collectionView.snp.makeConstraints { (make) in
            make.leading.equalTo(view.safeAreaLayoutGuide.snp.leading)
            make.trailing.equalTo(view.safeAreaLayoutGuide.snp.trailing)
            make.top.equalTo(view.safeAreaLayoutGuide.snp.top).offset(20)
            make.bottom.equalTo(view.safeAreaLayoutGuide.snp.bottom)
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard collectionView != nil else { return }
        
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return
        }
        
        coordinator.animate { (context) in
            if UIDevice.current.orientation.isLandscape {
                let width = size.width / 5 - 40
                flowLayout.itemSize = CGSize(width: width, height: 200)
                self.searchBar.frame.size.width = size.width
            } else {
                let width = size.width / 3 - 20
                flowLayout.itemSize = CGSize(width: width, height: 200)
                self.searchBar.frame.size.width = size.width
            }
            flowLayout.invalidateLayout()
        }
    }
    
    @objc func refreshMovies() {
        guard searchBar.text != nil else {
            movieListViewViewModel.fetchMovies()
            return
        }
        
        if !searchBar.text!.isEmpty {
            movieListViewViewModel.fetchMovies(name: searchBar.text!)
        } else {
            movieListViewViewModel.fetchMovies()
        }
    }
}

extension MoviesListViewController: UICollectionViewDelegate, UICollectionViewDataSource {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return movieListViewViewModel.numberOfMovies
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "Cell", for: indexPath) as! MovieCell
        if let viewModel = movieListViewViewModel.viewModelForMovie(at: indexPath.row) {
            cell.configure(viewModel: viewModel)
        }
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        if let viewModel = movieListViewViewModel.viewModelForMovie(at: indexPath.row) {
            let detailVC = MovieDetailViewController()
            detailVC.id = viewModel.id
            navigationController?.pushViewController(detailVC, animated: true)
        }
    }
    
}
