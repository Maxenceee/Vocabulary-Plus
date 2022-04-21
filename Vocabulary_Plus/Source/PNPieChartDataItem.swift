//
//  PNPieChartDataItem.swift
//  PNChartSwift
//
//

import UIKit

class PNPieChartDataItem: NSObject {
    var color: UIColor?
    var text: String?
    var value: CGFloat?
    
    init(dateColor color: UIColor, description text: String) {
        self.color = color
        self.text = text
    }
    
    init(dateValue value: CGFloat, dateColor color: UIColor, description text: String) {
        self.value = value
        self.color = color
        self.text = text
    }
    
    func setValue(newValue: CGFloat) {
        guard newValue > 0 else {
            print("Value should >= 0")
            return
        }
        self.value = (self.value != newValue) ? newValue : value
    }
}
