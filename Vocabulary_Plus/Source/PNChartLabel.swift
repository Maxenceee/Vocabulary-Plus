//
//  PNChartLabel.swift
//  PNChartSwift
//
//

import UIKit

class PNChartLabel: UILabel {
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.font = UIFont.boldSystemFont(ofSize: 10.0)
        self.textColor = PNGrey
        self.backgroundColor = UIColor.clear
        self.textAlignment = NSTextAlignment.center
        self.isUserInteractionEnabled = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder: NSCode) has not been implemented.")
    }

}
