//
//  CustomCell.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 05/04/2021.
//

import UIKit

class CustomCell: UITableViewCell {
    
    public var cellHeightForContent: CGFloat {
        contentView.layoutIfNeeded()
        return contentView.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize).height
    }
    
    var mainTitle: String?
    var langs: String?
    var isImageSet: Bool? {
        didSet {
            if isImageSet == true {
//                print("isImageSet : \(isImageSet!)")
                checkView.image = UIImage(systemName: "checkmark.circle")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
            }
        }
    }
    
    let mainStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .fill
        stackView.contentMode = .scaleToFill
        stackView.spacing = 5
        stackView.sizeToFit()
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let subStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
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
        label.font = UIFont.systemFont(ofSize: 11)
        label.textColor = .lightGray
        return label
    }()
    
    var checkView: UIImageView = {
        let view = UIImageView()
        view.translatesAutoresizingMaskIntoConstraints = true
        view.contentMode = .center
        view.tintColor = .systemGreen
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        self.addSubview(mainStackView)
        
        mainStackView.addArrangedSubview(subStackView)
        mainStackView.addArrangedSubview(checkView)
        subStackView.addArrangedSubview(mainTitleView)
        subStackView.addArrangedSubview(langsView)
        
//        mainTitleView.backgroundColor = .green
//        tagsView.backgroundColor = .red
//        tagsView.backgroundColor = .blue
//
//        mainStackView.backgroundColor = .cyan
//        checkView.backgroundColor = .red
        
        mainStackView.topAnchor.constraint(equalTo: self.topAnchor, constant: 5).isActive = true
        mainStackView.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 15).isActive = true
        mainStackView.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -10).isActive = true
        mainStackView.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
        
        checkView.widthAnchor.constraint(equalToConstant: self.frame.width/10).isActive = true
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        if let mainTitle = mainTitle {
            mainTitleView.text = mainTitle
        }
        if let langs = langs {
            langsView.text = langs
        }
        if isImageSet != nil && isImageSet == true {
            checkView.image = UIImage(systemName: "checkmark.circle")?.tinted(with: .white, isOpaque: false)!.withRenderingMode(.alwaysTemplate)
        } else {
            checkView.image = nil
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
}
/*
class CustomCell: UITableViewCell {
    
    @IBOutlet var mainTitleLabel: UILabel!
    @IBOutlet var langsLabel: UILabel!
    @IBOutlet var tagsLabel: UILabel!
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        // Configure the view for the selected state
    }
    
}

class CustomCell2: UITableViewCell {
    var cellLabel: UILabel!
    var cellDetailLabel: UILabel
    var cellTagsLabel: UILabel

    init(frame: CGRect, title: String) {
        super.init(style: UITableViewCell.CellStyle.default, reuseIdentifier: "cell")

        cellLabel = UILabel(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height/2))
        cellLabel.textColor = UIColor.black
        cellLabel.font = UIFont.systemFont(ofSize: 17)
        
        cellDetailLabel = UILabel(frame: CGRect(x: self.frame.height/2, y: 0, width: self.frame.width/2, height: self.frame.height/2))
        cellDetailLabel.textColor = UIColor.black
        cellDetailLabel.font = UIFont.systemFont(ofSize: 17)
        
        cellTagsLabel = UILabel(frame: CGRect(x: self.frame.height/2, y: self.frame.width/2, width: self.frame.width/2, height: self.frame.height/2))
        cellTagsLabel.textColor = UIColor.black
        cellTagsLabel.font = UIFont.systemFont(ofSize: 17)

        addSubview(cellLabel)
        addSubview(cellTagsLabel)
        addSubview(cellDetailLabel)
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
    }
}
*/
