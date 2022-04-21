//
//  GraphView.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 22/04/2021.
//

import Foundation
import UIKit
import CoreData

@IBDesignable
class GraphView: UIView {
    private enum Constants {
        static let cornerRadiusSize = CGSize(width: 8.0, height: 8.0)
        static let margin: CGFloat = 20.0
        static let topBorder: CGFloat = 60
        static let bottomBorder: CGFloat = 50
        static let colorAlpha: CGFloat = 0.3
        static let circleDiameter: CGFloat = 5.0
    }
    
    static var isEmptyGraph: Bool = true
    
    let CoreDatacontext = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var models = [Statistics]()

    @IBInspectable var startColor: UIColor = .clear
    @IBInspectable var endColor: UIColor = .clear

    var graphPoints: [Int] = [1, 1, 1, 1, 1, 1, 1]

//   swiftlint:disable:next function_body_length
    override func draw(_ rect: CGRect) {
        getStatistics()
        clearCoreStats()
        
        getDate()
        
        setupLabel()
        
//        let today = Date()
//        let calendar = Calendar.current
//        let date = calendar.date(byAdding: .day, value: -1, to: today)
//        createItem(day: date!)
        
        displayPointFromStats()
    
        let width = rect.width
        let height = rect.height

        let path = UIBezierPath(
          roundedRect: rect,
          byRoundingCorners: UIRectCorner.allCorners,
          cornerRadii: Constants.cornerRadiusSize
        )
        path.addClip()

        guard let context = UIGraphicsGetCurrentContext() else {
          return
        }
        
        let colors = [startColor.cgColor, endColor.cgColor]

        let colorSpace = CGColorSpaceCreateDeviceRGB()

        let colorLocations: [CGFloat] = [0.0, 1.0]

        guard let gradient = CGGradient(
            colorsSpace: colorSpace,
            colors: colors as CFArray,
            locations: colorLocations
        ) else {
            return
        }

        var startPoint = CGPoint.zero
        var endPoint = CGPoint(x: 0, y: self.bounds.height)
        context.drawLinearGradient(
            gradient,
            start: startPoint,
            end: endPoint,
            options: []
        )

        let margin = Constants.margin
        let columnXPoint = { (column: Int) -> CGFloat in
          let spacing = (width - margin * 2 - 4) / CGFloat((self.graphPoints.count - 1))
          return CGFloat(column) * spacing + margin + 2
        }

        let topBorder: CGFloat = Constants.topBorder
        let bottomBorder: CGFloat = Constants.bottomBorder
        let graphHeight = height - topBorder - bottomBorder
        guard let maxValue = graphPoints.max() else {
          return
        }
        let columnYPoint = { (graphPoint: Int) -> CGFloat in
          let yPoint = CGFloat(graphPoint) / CGFloat(maxValue) * graphHeight
          return graphHeight + topBorder - yPoint
        }
        
        let linePath = UIBezierPath()

        linePath.move(to: CGPoint(x: margin, y: topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: topBorder))

        linePath.move(to: CGPoint(x: margin, y: graphHeight / 2 + topBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: graphHeight / 2 + topBorder))

        linePath.move(to: CGPoint(x: margin, y: height - bottomBorder))
        linePath.addLine(to: CGPoint(x: width - margin, y: height - bottomBorder))
        
        let color = UIColor.black.withAlphaComponent(Constants.colorAlpha)
        color.setStroke()

        linePath.lineWidth = 1.0
        linePath.stroke()
        
        traitCollection.userInterfaceStyle == .light ? UIColor.black.setFill() : UIColor.white.setFill()
        traitCollection.userInterfaceStyle == .light ? UIColor.black.setStroke() : UIColor.white.setStroke()

        let graphPath = UIBezierPath()
        graphPath.move(to: CGPoint(x: columnXPoint(0), y: columnYPoint(graphPoints[0])))
        
        for i in 1..<graphPoints.count {
            print(graphPoints[i])
            let nextPoint = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            graphPath.addLine(to: nextPoint)
            if i == graphPoints.count-1 {
                self.todayPercentageLabel.centerYAnchor.constraint(equalTo: self.topAnchor, constant: columnYPoint(graphPoints[i])).isActive = true
            }
        }

        context.saveGState()

        guard let clippingPath = graphPath.copy() as? UIBezierPath else {
          return
        }

        clippingPath.addLine(to: CGPoint(x: columnXPoint(graphPoints.count - 1), y: height))
        clippingPath.addLine(to: CGPoint(x: columnXPoint(0), y: height))
        clippingPath.close()

        clippingPath.addClip()

        let highestYPoint = columnYPoint(maxValue)
        startPoint = CGPoint(x: margin, y: highestYPoint)
        endPoint = CGPoint(x: margin, y: self.bounds.height)

        context.drawLinearGradient(
          gradient,
          start: startPoint,
          end: endPoint,
          options: CGGradientDrawingOptions(rawValue: 0)
        )
        context.restoreGState()

        graphPath.lineWidth = 2.0
        graphPath.stroke()

        for i in 0..<graphPoints.count {
            var point = CGPoint(x: columnXPoint(i), y: columnYPoint(graphPoints[i]))
            point.x -= Constants.circleDiameter / 2
            point.y -= Constants.circleDiameter / 2

            let circle = UIBezierPath(
                ovalIn: CGRect(
                    origin: point,
                    size: CGSize(width: Constants.circleDiameter, height: Constants.circleDiameter)
                )
            )
            circle.fill()
        }
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        traitCollection.userInterfaceStyle == .light ? UIColor.black.setFill() : UIColor.white.setFill()
        traitCollection.userInterfaceStyle == .light ? UIColor.black.setStroke() : UIColor.white.setStroke()
        maxLabel.textColor = traitCollection.userInterfaceStyle == .light ? .systemGray2 : .white.withAlphaComponent(0.5)
    }
    
    func getDate() {
        if models.count <= 0 {
            createItem(day: Date())
            print("no stats")
            print(models)
        } else {
            getStatistics()
            let lastDate = models[0].day!
            let lastDateFormatter = DateFormatter()
            lastDateFormatter.setLocalizedDateFormatFromTemplate("YYYY MM dd")
            let dateToCheck = lastDateFormatter.string(from: lastDate)
            
            let today = Date()
            let dateFormatter = DateFormatter()
            dateFormatter.setLocalizedDateFormatFromTemplate("YYYY MM dd")
            let todayToCheck = dateFormatter.string(from: today)
            
            if dateToCheck != todayToCheck {
                print("new day")
                createItem(day: Date())
            } else {
                print("same day: \(dateToCheck) == \(todayToCheck)")
//                print(models)
            }
        }
        
        print(models[0].total)
    }
    
    func displayPointFromStats() {
        var pointForAverage: [Int] = []
        
        for i in 0...models.count-1 {
            if i <= 6 {
                let graphday = getDayDifference(start: models[0].day!, end: models[i].day!)
//                print(models[0].day!, models[i].day!)
                if models[i].total != 0 && models[i].goodAnswers != 0 && graphday > -7 {
                    graphPoints[graphPoints.count-1+graphday] = Int((models[i].goodAnswers/models[i].total)*100)
                    pointForAverage.append(Int((models[i].goodAnswers/models[i].total)*100))
                } else if graphday > -7{
                    graphPoints[graphPoints.count-1+graphday] = 1
                }
//                    print(graphPoints.count-1+graphday)
                print("tot \(i): \(models[i].total), g: \(models[i].goodAnswers)")
                print("graphpoint \(graphPoints.count-1+graphday): \(graphday > -7 ? (graphPoints[graphPoints.count-1+graphday]) : 0)")
            }
        }
        
        if pointForAverage.count != 0 {
            let average = pointForAverage.reduce(0, +) / pointForAverage.count
            averageGoodAnswer.text = "Past week average: \(average)%"
            maxLabel.text = "\((graphPoints.max() ?? 0))%"
            GraphView.isEmptyGraph = false
        }
        
        if models.count > 1 {
            todayPercentageLabel.text = (graphPoints[graphPoints.count-1] != graphPoints.max() && graphPoints[graphPoints.count-1] >= (graphPoints.max()!/10)) ? "\(graphPoints[graphPoints.count-1])" : ""
        }
        
//        for i in models {
//            print(i.day!)
//        }
        
//        print("days: \(getDayDifference(start: models[0].day!, end: models[1].day!))")
    }
    
    func getDayDifference(start: Date, end: Date) -> Int{
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)

        let components = calendar.dateComponents([.day], from: date1, to: date2)

        return components.day!
    }
    
    func computeNewDate(from fromDate: Date, to toDate: Date) -> Date  {
         let delta = toDate.timeIntervalSince(fromDate)
         let today = Date()
         if delta < 0 {
             return today
         } else {
             return today.addingTimeInterval(delta)
         }
    }
    
    func getStatistics() {
        do {
            let request = Statistics.fetchRequest() as NSFetchRequest<Statistics>
            
            let sort = NSSortDescriptor(key: "day", ascending: false)
            request.sortDescriptors = [sort]
            
            models = try CoreDatacontext.fetch(request)
            
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    func createItem(day: Date) {
        let newItem = Statistics(context: CoreDatacontext)
        newItem.day = day
        newItem.goodAnswers = 0
        newItem.wrongAnswers = 0
        newItem.total = 0
        
        do {
            try CoreDatacontext.save()
            getStatistics()
        } catch {
            print("ERROR: Enable to save item")
        }
    }
    
    func deleteItem(item: Statistics) {
        CoreDatacontext.delete(item)
        
        do {
            try CoreDatacontext.save()
            getStatistics()
        } catch {
            print("ERROR: Enable to delete item")
        }
    }
    
    let averageGoodAnswer: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "No Datas"
        return label
    }()
    
    let maxLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        return label
    }()
    
    let todayPercentageLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.font = UIFont.systemFont(ofSize: 12)
        return label
    }()
    
    func setupLabel() {
        self.addSubview(averageGoodAnswer)
        self.addSubview(maxLabel)
        self.addSubview(todayPercentageLabel)
        
        maxLabel.textColor = traitCollection.userInterfaceStyle == .light ? .systemGray2 : .white.withAlphaComponent(0.5)
        
        averageGoodAnswer.topAnchor.constraint(equalTo: self.topAnchor, constant: 35).isActive = true
        averageGoodAnswer.leadingAnchor.constraint(equalTo: self.leadingAnchor, constant: 20).isActive = true
        averageGoodAnswer.heightAnchor.constraint(equalToConstant: 20).isActive = true
        averageGoodAnswer.trailingAnchor.constraint(equalTo: self.trailingAnchor, constant: -100).isActive = true
        
        maxLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 35).isActive = true
        maxLabel.widthAnchor.constraint(equalToConstant: 40).isActive = true
        maxLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        maxLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        
        todayPercentageLabel.trailingAnchor.constraint(equalTo: self.trailingAnchor).isActive = true
        todayPercentageLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        todayPercentageLabel.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    func clearCoreStats() {
        let ud = UserDefaults.standard.object(forKey: "isCoreDataAlreadyCleared") as? Bool
        
        if ud == false || ud == nil {
            if models.count > 0 {
                for i in models {
                    print(i.day!, i.total, i.goodAnswers)
                }
                for i in 0...models.count-1 {
                    deleteItem(item: models[i])
                }
                for i in models {
                    print(i.day!, i.total, i.goodAnswers)
                }
                print("coredata cleared")
            }
            
            UserDefaults.standard.setValue(true, forKey: "isCoreDataAlreadyCleared")
        } else {
            print("CoreDataAlreadyCleared")
        }
    }
}
