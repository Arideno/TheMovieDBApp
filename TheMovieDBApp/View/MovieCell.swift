//
//  MovieCell.swift
//  TheMovieDBApp
//
//  Created by Andrii Moisol on 06.11.2020.
//

import UIKit
import SnapKit
import Kingfisher

class MovieCell: UICollectionViewCell {
    lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    lazy var nameLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.numberOfLines = 2
        lbl.font = .systemFont(ofSize: 14)
        lbl.textAlignment = .center
        return lbl
    }()
    
    lazy var descriptionLabel: UILabel = {
        let lbl = UILabel()
        lbl.textColor = .white
        lbl.textAlignment = .center
        lbl.font = .systemFont(ofSize: 10)
        lbl.numberOfLines = 3
        lbl.lineBreakMode = .byClipping
        return lbl
    }()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        addSubview(imageView)
        addSubview(nameLabel)
        addSubview(descriptionLabel)
        
        imageView.snp.makeConstraints { (make) in
            make.height.equalTo(100)
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.top.equalTo(snp.top)
        }
        
        nameLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.top.equalTo(imageView.snp.bottom).offset(10)
        }
        
        descriptionLabel.snp.makeConstraints { (make) in
            make.leading.equalTo(snp.leading)
            make.trailing.equalTo(snp.trailing)
            make.top.equalTo(nameLabel.snp.bottom).offset(10)
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func configure(viewModel: MovieViewViewModel) {
        if let url = URL(string: IMAGES_URL + viewModel.posterURL) {
            imageView.kf.setImage(with: url, placeholder: UIImage(named: "noposter"), options: [
                .processor(DownsamplingImageProcessor(size: self.frame.size)),
                .scaleFactor(UIScreen.main.scale),
                .cacheOriginalImage,
                .transition(ImageTransition.fade(1)),
            ])
        }
        nameLabel.text = viewModel.title
        descriptionLabel.text = viewModel.overview
    }
}
