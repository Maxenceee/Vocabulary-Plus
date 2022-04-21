//
//  PNLineChartData.swift
//  PNChartSwift
//
//

import UIKit

public class PNLineChartData {
    public var getData = {
        (index: Int) -> PNLineChartDataItem in
        return PNLineChartDataItem()
    }
    
    public var inflexPointStyle = PNLineChartPointStyle.None
    public var color: UIColor = UIColor.gray
    public var itemCount: Int = 0
    public var lineWidth: CGFloat = 2.0
    public var inflexionPointWidth: CGFloat = 6.0
    
    public init() { }
}

extension PNLineChartData {
    public enum PNLineChartPointStyle: Int {
        case None = 0
        case Cycle
        case Triangle
        case Square
    }
}
