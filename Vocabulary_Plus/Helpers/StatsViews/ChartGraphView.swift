//
//  ChartGraphView.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 24/04/2021.
//

import Charts
import UIKit
import Foundation
import CoreData

class ChartGraphView: UIView, ChartViewDelegate {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var models = [Statistics]()
    
    var lineChart = LineChartView()
    
    var graphPoints: [Int] = []
    
    override func draw(_ rect: CGRect) {
        super.draw(rect)
        lineChart.delegate = self
        
//        getDate()
        
//        displayPointFromStats()
        
        self.addSubview(lineChart)
        lineChart.frame = CGRect(x: 10, y: 10, width: self.frame.size.width-10, height: self.frame.size.height-10)
        
        var entries = [ChartDataEntry]()
        
        for i in 0..<10 {
            entries.append(ChartDataEntry(x: Double(i), y: Double(i+Int.random(in: -3...3))))
        }
        
        let set = LineChartDataSet(entries: entries)
        set.colors = ChartColorTemplates.material()
        let data = LineChartData(dataSet: set)
        lineChart.data = data
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
    }
    
    func displayPointFromStats() {
        for i in 0...models.count-1 {
            if i <= 6 {
                let graphday = getDayDifference(start: models[0].day!, end: models[i].day!)
//                    print("tot \(i): \(models[i].total), g: \(models[i].goodAnswers)")
                if models[i].total != 0 {
                    graphPoints[graphPoints.count-1+graphday] = Int((models[i].goodAnswers/models[i].total)*100)
                }
//                    print(graphPoints.count-1+graphday)
                print("graphpoint \(i+1): \(graphPoints[graphPoints.count-1+graphday])")
            }
        }
    }
    
    func getDayDifference(start: Date, end: Date) -> Int{
        let calendar = Calendar.current
        
        let date1 = calendar.startOfDay(for: start)
        let date2 = calendar.startOfDay(for: end)

        let components = calendar.dateComponents([.day], from: date1, to: date2)

        return components.day!
    }
    
    func getStatistics() {
        do {
            let request = Statistics.fetchRequest() as NSFetchRequest<Statistics>
            
            let sort = NSSortDescriptor(key: "day", ascending: false)
            request.sortDescriptors = [sort]
            
            models = try context.fetch(request)
            
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    func createItem(day: Date) {
        let newItem = Statistics(context: context)
        newItem.day = day
        newItem.goodAnswers = 0
        newItem.wrongAnswers = 0
        newItem.total = 0
        
        do {
            try context.save()
            getStatistics()
        } catch {
            print("ERROR: Enable to save item")
        }
    }
}
