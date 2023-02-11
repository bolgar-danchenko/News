//
//  ArticleTableViewCell.swift
//  NewsApp
//
//  Created by Konstantin Bolgar-Danchenko on 04.02.2023.
//

import UIKit

class ArticleTableViewCell: UITableViewCell {

    // MARK: - Properties
    
    static let id = "ArticleTableViewCell"
    
    private lazy var newsTitleLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = .systemFont(ofSize: 18, weight: .semibold)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var countLabel: UILabel = {
        let label = UILabel()
        label.font = .systemFont(ofSize: 14, weight: .light)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var newsImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.backgroundColor = .secondarySystemBackground
        imageView.layer.cornerRadius = 6
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        imageView.clipsToBounds = true
        imageView.translatesAutoresizingMaskIntoConstraints = false
        return imageView
    }()
    
    // MARK: - Lifecycle
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        
        setupView()
        setupSubview()
        setupConstraints()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        newsTitleLabel.text = nil
        newsImageView.image = nil
    }
    
    // MARK: - Layout
    
    private func setupView() {
        contentView.clipsToBounds = true
    }
    
    private func setupSubview() {
        contentView.addSubview(newsTitleLabel)
        contentView.addSubview(countLabel)
        contentView.addSubview(newsImageView)
    }
    
    private func setupConstraints() {
        NSLayoutConstraint.activate([
            
            newsImageView.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 10),
            newsImageView.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 20),
            newsImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -20),
            newsImageView.heightAnchor.constraint(equalToConstant: 200),
            
            newsTitleLabel.topAnchor.constraint(equalTo: newsImageView.bottomAnchor, constant: 10),
            newsTitleLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            newsTitleLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -16),
            
            countLabel.topAnchor.constraint(equalTo: newsTitleLabel.bottomAnchor, constant: 5),
            countLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 16),
            countLabel.heightAnchor.constraint(equalToConstant: 15),
            countLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
    }
    
    // MARK: - Configure
    
    // Configuring cell with ViewModel
    func configure(with viewModel: CellViewModel) {
        
        newsTitleLabel.text = viewModel.title
        
        let currentCount = UserDefaults.standard.value(forKey: viewModel.url) ?? 0
        countLabel.text = "Views: \(currentCount)"
        
        if let data = viewModel.imageData {
            newsImageView.image = UIImage(data: data)
            
        } else if let url = viewModel.imageUrl {
            URLSession.shared.dataTask(with: url) { [weak self] data, _, error in
                
                guard let data = data, error == nil else { return }
                viewModel.imageData = data
                
                DispatchQueue.main.async {
                    self?.newsImageView.image = UIImage(data: data)
                }
            }
            .resume()
        } else {
            // Some articles have no images, in such cases images will not be displayed
            newsImageView.heightAnchor.constraint(equalToConstant: 0).isActive = true
        }
    }
}
