//
//  MainViewContentContainerViewController.swift
//  Vocabulary_Plus
//
//  Created by Maxence Gama on 19/04/2021.
//

import UIKit
import Foundation
import Lottie
import CoreData

class MainViewContentContainerViewController: UIPageViewController {
    
    let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    var fetchController = NSFetchedResultsController<NSFetchRequestResult>?.self
    
    var models = [Statistics]()
    var wordsModels = [LangData]()
    
    var index = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()

        getStatistics()
//        models[0].goodAnswers = 1
//        do {
//            try context.save()
//            getStatistics()
//        } catch {
//            print("ERROR: Enable to update stats")
//        }
        
        switch index {
        case 0:
            setUpGraph()
        case 1:
            setupWrongWrongList()
        case 2:
            setupPieChart()
//            setupLineChartAnim()
//            setupLineChart()
        case 3:
            setupSimpleBarChart()
//            setupBarChart()
        case 4:
            otherView()
        default:
            break
        }
        minLabel.textColor = traitCollection.userInterfaceStyle == .light ? .systemGray2 : .white.withAlphaComponent(0.5)
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        minLabel.textColor = traitCollection.userInterfaceStyle == .light ? .systemGray2 : .white.withAlphaComponent(0.5)
    }
    
    //MARK: -GraphView
    
    let waitLabel: UILabel = {
        let label = UILabel()
        label.text = "More stats view arrive soon :)"
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let graphTitle: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "Average of good answers"
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        return label
    }()
    
    let infoButton: UIButton = {
        let button = UIButton(type: UIButton.ButtonType.custom) as UIButton
        
        button.setImage(UIImage(systemName: "info.circle")!.tinted(with: UIColor.systemGray), for: .normal)
        button.addTarget(self, action: #selector(didTapContentViewInfoButton), for: .touchUpInside)
        button.contentMode = .scaleToFill
        button.translatesAutoresizingMaskIntoConstraints = false
        button.layer.cornerRadius = 25
        return button
    }()
    
    let superGraphView: UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    var graphView: GraphView = {
        let view = GraphView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .clear
        return view
    }()
    
    let minLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 14)
        label.text = "0"
        return label
    }()
    
    let graphStackView: UIStackView = {
        let stack = UIStackView()
        stack.distribution = .fillEqually
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.spacing = 0
        stack.contentMode = .scaleToFill
        stack.isOpaque = false
        stack.isBaselineRelativeArrangement = false
        stack.translatesAutoresizingMaskIntoConstraints = false
        return stack
    }()
    
    let day1: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 1
        label.textAlignment = .center
        return label
    }()
    let day2: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 2
        label.textAlignment = .center
        return label
    }()
    let day3: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 3
        label.textAlignment = .center
        return label
    }()
    let day4: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 4
        label.textAlignment = .center
        return label
    }()
    let day5: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 5
        label.textAlignment = .center
        return label
    }()
    let day6: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 6
        label.textAlignment = .center
        return label
    }()
    let day7: UILabel = {
        let label = UILabel()
//        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = "M"
        label.tag = 7
        label.textAlignment = .center
        return label
    }()
    
    func setUpGraph() {
        view.addSubview(superGraphView)
        superGraphView.addSubview(graphView)
        superGraphView.addSubview(minLabel)
        superGraphView.addSubview(graphStackView)
        graphStackView.addArrangedSubview(day1)
        graphStackView.addArrangedSubview(day2)
        graphStackView.addArrangedSubview(day3)
        graphStackView.addArrangedSubview(day4)
        graphStackView.addArrangedSubview(day5)
        graphStackView.addArrangedSubview(day6)
        graphStackView.addArrangedSubview(day7)
        setupViewTitle(heightIsActive: true)

        superGraphView.topAnchor.constraint(equalTo: self.view.topAnchor).isActive = true
        superGraphView.leadingAnchor.constraint(equalTo: self.view.leadingAnchor).isActive = true
        superGraphView.trailingAnchor.constraint(equalTo: self.view.trailingAnchor).isActive = true
        superGraphView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor).isActive = true
        
        graphView.topAnchor.constraint(equalTo: superGraphView.topAnchor, constant: 10).isActive = true
        graphView.leadingAnchor.constraint(equalTo: superGraphView.leadingAnchor, constant: 5).isActive = true
        graphView.trailingAnchor.constraint(equalTo: superGraphView.trailingAnchor, constant: -5).isActive = true
        graphView.bottomAnchor.constraint(equalTo: superGraphView.bottomAnchor, constant: -10).isActive = true
        
        minLabel.bottomAnchor.constraint(equalTo: graphStackView.topAnchor).isActive = true
        minLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
        minLabel.widthAnchor.constraint(equalToConstant: 10).isActive = true
        minLabel.trailingAnchor.constraint(equalTo: superGraphView.trailingAnchor, constant: -8).isActive = true
        
        graphStackView.leadingAnchor.constraint(equalTo: superGraphView.leadingAnchor, constant: 5).isActive = true
        graphStackView.trailingAnchor.constraint(equalTo: superGraphView.trailingAnchor, constant: -5).isActive = true
        graphStackView.bottomAnchor.constraint(equalTo: superGraphView.bottomAnchor, constant: -30).isActive = true
        graphStackView.heightAnchor.constraint(equalToConstant: 25).isActive = true
        
        setupGraphDisplay()
    }
    
    func setupGraphDisplay() {
        let maxDayIndex = graphStackView.arrangedSubviews.count - 1
        
//        graphView.graphPoints[graphView.graphPoints.count - 1] = counterView.counter
        graphView.setNeedsDisplay()

        let today = Date()
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEE")

        for i in (0...maxDayIndex) {
            if let date = calendar.date(byAdding: .day, value: -i, to: today),
                let label = graphStackView.arrangedSubviews[maxDayIndex - i] as? UILabel {
                    label.text = formatter.string(from: date)
                }
            }
        }
    
    //MARK: -Wrong Wrong List
    
    let mostWrongWordsListView: MostWrongWordsListView = {
        let view = MostWrongWordsListView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupWrongWrongList() {
        view.addSubview(mostWrongWordsListView)
        
        mostWrongWordsListView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        mostWrongWordsListView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        mostWrongWordsListView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        mostWrongWordsListView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
        
        setupViewTitle(heightIsActive: true)
        graphTitle.text = "Words with the most errors"
    }
    
    //MARK: -V2 LineCharts
    
    let chartGraphView: ChartGraphView = {
        let view = ChartGraphView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupLineChart() {
        view.addSubview(chartGraphView)
        
        chartGraphView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chartGraphView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chartGraphView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chartGraphView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //MARK: -V3 LineChart
    
    func setupLineChartAnim() {
        let lineChart = self.setLineChart()
        self.view.addSubview(lineChart)
        
        lineChart.translatesAutoresizingMaskIntoConstraints = false
        lineChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        lineChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        lineChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        lineChart.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
    }
    
    private func setLineChart() -> PNLineChart {
        let lineChart = PNLineChart(frame: CGRect(x: 0, y: 135, width: 320, height: 250))
        lineChart.yLabelFormat = "%1.1f"
        lineChart.showLabel = true
        lineChart.backgroundColor = UIColor.clear
        lineChart.xLabels = ["Sep 1", "Sep 2", "Sep 3", "Sep 4", "Sep 5", "Sep 6", "Sep 7"]
        lineChart.showCoordinateAxis = true
        lineChart.center = self.view.center
        
        let dataArr = [60.1, 160.1, 126.4, 232.2, 186.2, 127.2, 176.2]
        let data = PNLineChartData()
        data.color = PNGreen
        data.itemCount = dataArr.count
        data.inflexPointStyle = .None
        data.getData = ({
            (index: Int) -> PNLineChartDataItem in
            let yValue = CGFloat(dataArr[index])
            let item = PNLineChartDataItem(y: yValue)
            return item
        })
        
        lineChart.chartData = [data]
        lineChart.strokeChart()
        return lineChart
    }
    
    //MARK: -Bar Chart
    
    let chartBarView: ChartBarView = {
        let view = ChartBarView()
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    func setupBarChart() {
        view.addSubview(chartBarView)
        
        chartBarView.topAnchor.constraint(equalTo: view.topAnchor).isActive = true
        chartBarView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        chartBarView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        chartBarView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true
    }
    
    //MARK: -V2 BarChart
    
    let averageWrongLetters: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.font = UIFont.systemFont(ofSize: 12)
        label.text = "No Datas"
        return label
    }()
    
    func setupSimpleBarChart() {
        setupViewTitle(heightIsActive: false)
        graphTitle.text = "Average number\nof errors per word"
        graphTitle.numberOfLines = 2
        view.addSubview(averageWrongLetters)
        let barChart = self.setBarChart()
        self.view.addSubview(barChart)
        
        graphTitle.heightAnchor.constraint(equalToConstant: 60).isActive = true
        
        barChart.translatesAutoresizingMaskIntoConstraints = false
        barChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 100).isActive = true
        barChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 20).isActive = true
        barChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20).isActive = true
        barChart.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -20).isActive = true
        
        averageWrongLetters.bottomAnchor.constraint(equalTo: barChart.topAnchor, constant: 5).isActive = true
        averageWrongLetters.leadingAnchor.constraint(equalTo: barChart.leadingAnchor, constant: 40).isActive = true
        averageWrongLetters.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        averageWrongLetters.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    private func setBarChart() -> PNBarChart {
        getStatistics()
        getDate()
        let barChart = PNBarChart(frame: CGRect(x: 0, y: 135, width: 320, height: 200))
        barChart.backgroundColor = UIColor.clear
        barChart.animationType = .Waterfall
        barChart.labelMarginTop = 5.0
        barChart.xLabels = getDay(array: ["Sep 1", "Sep 2", "Sep 3", "Sep 4", "Sep 5", "Sep 6", "Sep 7"])
        barChart.yValues = displayPointFromStats(barPoints: [1, 1, 1, 1, 1, 1, 1])
        barChart.strokeChart()
        barChart.center = self.view.center
        return barChart
    }
    
    func getDay(array: Array<String>) -> Array<String> {
        var dayList = array
        let maxDayIndex = dayList.count - 1

        let today = Date()
        let calendar = Calendar.current

        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("EEEEE")

        for i in (0...maxDayIndex) {
            if let date = calendar.date(byAdding: .day, value: -i, to: today) {
                dayList[maxDayIndex - i] = formatter.string(from: date)
            }
        }
        
        return dayList
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
    
    func displayPointFromStats(barPoints: Array<CGFloat>) -> Array<CGFloat> {
        var points = barPoints
        var pointForAverage: [Int] = []
        
        if models.count > 0 {
            for i in 0...models.count-1 {
                if i <= 6 {
                    let graphday = getDayDifference(start: models[0].day!, end: models[i].day!)
                    if models[i].totalLetters != 0 && graphday > -7 {
                        points[points.count-1+graphday] = CGFloat((models[i].wrongLetters/models[i].totalLetters)*100)
                        pointForAverage.append(Int((models[i].wrongLetters/models[i].totalLetters)*100))
                    } else if graphday > -7 {
                        points[points.count-1+graphday] = 1
                    }
                    print("totL \(i): \(models[i].totalLetters), wL: \(models[i].wrongLetters)")
                }
            }
        } else {
            for i in 0..<barPoints.count {
                points[i] = 1
            }
        }
        
        if pointForAverage.count != 0 {
            let average = pointForAverage.reduce(0, +) / pointForAverage.count
            averageWrongLetters.text = "Past week average: \(average)%"
        }
        
        return points
    }
    
    func getDayDifference(start: Date, end: Date) -> Int {
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
    
    func deleteItem(item: Statistics) {
        context.delete(item)
        
        do {
            try context.save()
            getStatistics()
        } catch {
            print("ERROR: Enable to delete item")
        }
    }
    
    //MARK: -Pie Chart
    
    func setupPieChart() {
        setupViewTitle(heightIsActive: true)
        graphTitle.text = "Last Quiz Stats"
        var item1: Float = 0
        var item2: Float = 0
        if models[0].lastTryTotal != 0 {
            item1 = (models[0].lastTryGoodAnswers/models[0].lastTryTotal)*100
            item2 = 100-item1
        } else {
            item1 = 0
            item2 = 0
        }
        let pieChart = self.setPieChart(itemc1: item1, itemc2: item2)
        self.view.addSubview(pieChart)
        
        pieChart.translatesAutoresizingMaskIntoConstraints = false
        pieChart.topAnchor.constraint(equalTo: view.topAnchor, constant: 50).isActive = true
        pieChart.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50).isActive = true
        pieChart.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50).isActive = true
        pieChart.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -50).isActive = true
    }
    
    private func setPieChart(itemc1: Float, itemc2: Float) -> PNPieChart {
        let item1 = PNPieChartDataItem(dateValue: CGFloat(itemc1),
                                       dateColor: PNLightGreen,
                                       description: (itemc1 == 0 && itemc2 == 0) ? "No Datas" :  "Good\nAnswers")
        let item2 = PNPieChartDataItem(dateValue: CGFloat(itemc2),
                                       dateColor: PNFreshGreen,
                                       description: "Wrong\nAnswers")
        
//        let item3 = PNPieChartDataItem(dateValue: 45, dateColor: PNDeepGreen, description: "item3")
        let frame = CGRect(x: 40, y: 155, width: 240, height: 240)
        var items: [PNPieChartDataItem] = []
        if (itemc2 == 100) {
            items = [item2]
        } else if (itemc1 == 100) || (itemc1 == 0 && itemc2 == 0){
            items = [item1]
        } else {
            items = [item1, item2]
        }
        let pieChart = PNPieChart(frame: frame, items: items)
        pieChart.descriptionTextColor = UIColor.white
        pieChart.descriptionTextFont = UIFont(name: "Avenir-Medium", size: 14)!
        pieChart.center = self.view.center
        return pieChart
    }
    
    func getAllItems() {
        do {
            let request = LangData.fetchRequest() as NSFetchRequest<LangData>
            
            let sort = NSSortDescriptor(key: "numOfWrongAnswer", ascending: false)
            request.sortDescriptors = [sort]
            
            wordsModels = try context.fetch(request)
        } catch {
            print("ERROR: Enable to get items")
        }
    }
    
    //MARK: -Title and Info
    
    func setupViewTitle(heightIsActive: Bool) {
        view.addSubview(graphTitle)
        view.addSubview(infoButton)
        
        graphTitle.topAnchor.constraint(equalTo: view.topAnchor, constant: 10).isActive = true
        graphTitle.heightAnchor.constraint(equalToConstant: 25).isActive = heightIsActive
        graphTitle.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        
        infoButton.topAnchor.constraint(equalTo: view.topAnchor, constant: 15).isActive = true
        infoButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -15).isActive = true
        infoButton.heightAnchor.constraint(equalToConstant: 20).isActive = true
        infoButton.widthAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    @objc func didTapContentViewInfoButton() {
//        print("didTapContentViewInfoButton")
        NotificationCenter.default.post(name: Notification.Name(rawValue: "disconnectPaxiSockets"), object: nil)
    }
    
    //MARK: -Other Views
    
    func otherView() {
        view.addSubview(waitLabel)
        
        waitLabel.topAnchor.constraint(equalTo: view.topAnchor, constant: 20).isActive = true
        waitLabel.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        waitLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true
    }
    
    
    override func didReceiveMemoryWarning () {
        super.didReceiveMemoryWarning ()
        // Dispose of any resources that can be recreated.
    }
}
