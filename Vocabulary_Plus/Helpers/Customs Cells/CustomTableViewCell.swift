//
//  CustomTableViewCell.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 05/04/2021.
//

import UIKit
import Foundation

class CustomTableViewCell: UITableViewCell {
    
    public var cellHeightForContent: CGFloat {
        contentView.layoutIfNeeded()
        return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    var mainTitle: String?
    var langs: String?
    var tags: String?
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fillProportionally
        stackView.contentMode = .scaleToFill
        stackView.spacing = 5
        stackView.sizeToFit()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.distribution = .fillEqually
        stackView.contentMode = .scaleToFill
        stackView.spacing = 0
        stackView.sizeToFit()
        stackView.translatesAutoresizingMaskIntoConstraints = true
        return stackView
    }()
    
    var mainTitleView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.contentMode = .center
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 17)
        return label
    }()
    
    var langsView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.contentMode = .center
        label.textAlignment = .left
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    var tagsView: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = true
        label.contentMode = .center
        label.textAlignment = .right
        label.sizeToFit()
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(mainTitleView)
        mainStackView.addArrangedSubview(subStackView)
        subStackView.addArrangedSubview(langsView)
        subStackView.addArrangedSubview(tagsView)
        
//        mainTitleView.backgroundColor = .green
//        tagsView.backgroundColor = .red
//        tagsView.backgroundColor = .blue
//
//        mainStackView.backgroundColor = .cyan
        
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let mainTitle = mainTitle {
            mainTitleView.text = mainTitle
        }
        if let langs = langs {
            langsView.text = langs
        }
        if let tags = tags {
            tagsView.text = tags
        }
        self.frame.size.height = cellHeightForContent
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
