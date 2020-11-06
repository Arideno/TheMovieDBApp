//
//  MovieDetailViewController.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import UIKit
import Kingfisher
import RxSwift
import RxCocoa

class MovieDetailViewController: UIViewController {
    
    var id: Int!
    var movieViewViewModel: MovieViewViewModel!
    let disposeBag = DisposeBag()
    
    lazy var activityIndicator: UIActivityIndicatorView = {
        let ai = UIActivityIndicatorView()
        return ai
    }()
    
    lazy var scrollView: UIScrollView = {
        let sv = UIScrollView()
        return sv
    }()
    
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 16)
        lbl.numberOfLines = 0
        return lbl
    }()
    
    lazy var dateLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.font = .systemFont(ofSize: 14)
        return lbl
    }()
    
    lazy var genresTextView: UITextView = {
        let txt = UITextView()
        txt.textColor = .white
        txt.isScrollEnabled = false
        txt.isEditable = false
        return txt
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = .black
        
        setupViews()
        
        movieViewViewModel = MovieViewViewModel()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(customView: activityIndicator)
        
        movieViewViewModel.isFetching.drive(activityIndicator.rx.isAnimating).disposed(by: disposeBag)
    
        movieViewViewModel.fetch(id: id) { [weak self] in
            DispatchQueue.main.async {
                self?.populateWithData()
            }
        }
    }
    
    func populateWithData() {
        title = movieViewViewModel.title
        
        if let url = URL(string: IMAGES_URL + movieViewViewModel.posterURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "noposter"), options: [
                .processor(DownsamplingImageProcessor(size: self.view.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(ImageTransition.fade(1)),
            ])
        }
        
        descriptionLabel.text = movieViewViewModel.overview
        dateLabel.text = "Release date: \(movieViewViewModel.releaseDate)"
        let genresName = movieViewViewModel.genres.map { $0.name }
        let genresText = NSMutableAttributedString(string: "Genres:\n", attributes: [.font: UIFont.systemFont(ofSize: 24), .foregroundColor: UIColor.white])
        genresText.append(NSAttributedString(string: genresName.joined(separator: "\n"), attributes: [.font: UIFont.systemFont(ofSize: 14), .foregroundColor: UIColor.white]))
        genresTextView.attributedText = genresText
    }
    
    func setupViews() {
        view.addSubview(scrollView)
        scrollView.snp.makeConstraints { (make) in
            make.edges.equalTo(view.safeAreaLayoutGuide)
        }
        
        let contentView = UIView()
        scrollView.addSubview(contentView)
        contentView.snp.makeConstraints { (make) in
            make.top.bottom.equalTo(scrollView)
            make.left.right.equalTo(view.safeAreaLayoutGuide)
        }
        
        contentView.addSubview(imageView)
        contentView.addSubview(descriptionLabel)
        contentView.addSubview(dateLabel)
        contentView.addSubview(genresTextView)
        
        imageView.snp.makeConstraints { (make) in
            make.top.equalTo(contentView.snp.top)
            make.centerX.equalTo(contentView.snp.centerX)
            make.width.equalTo(contentView.snp.width)
            make.height.equalTo(200)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.top.equalTo(imageView.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
        }
        
        dateLabel.snp.makeConstraints { (make) in
            make.top.equalTo(descriptionLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
        }
        
        genresTextView.snp.makeConstraints { (make) in
            make.top.equalTo(dateLabel.snp.bottom).offset(10)
            make.leading.equalTo(contentView.snp.leading).offset(10)
            make.trailing.equalTo(contentView.snp.trailing).offset(-10)
            make.bottom.equalTo(contentView.snp.bottom)
        }
    }
}
