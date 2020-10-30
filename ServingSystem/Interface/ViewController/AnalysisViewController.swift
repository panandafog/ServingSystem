//
//  AnalysisViewController.swift
//  ServingSystem
//
//  Created by panandafog on 28.10.2020.
//

import Charts
import Cocoa

class AnalysisViewController: NSViewController {
    
    var analyser: Analyser?
    
    private var analysisCompletion: ((_: [Int]?, _: [Double]?, _: [Double]?, _: [Double]?) -> Void)?
    
    @IBOutlet private var rejectProbabilityChart: LineChartView!
    @IBOutlet private var stayTimeChart: LineChartView!
    @IBOutlet private var usingRateChart: LineChartView!
    
    @IBOutlet private var startButton: NSButton!
    @IBOutlet private var stopButton: NSButton!
    @IBOutlet private var progressIndicator: NSProgressIndicator!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        setupCharts()
        
        self.analysisCompletion = { values, rejectProbability, stayTime, usingRate in
            guard let rejectProbability = rejectProbability,
                  let stayTime = stayTime,
                  let usingRate = usingRate,
                  let values = values else {
                return
            }
            DispatchQueue.main.async {
                self.progressIndicator.stopAnimation(self)
            }
            self.drawCharts(values: values,
                            rejectProbability: rejectProbability,
                            stayTime: stayTime,
                            usingRate: usingRate)
            self.animateCharts()
        }
    }
    
    override func viewWillAppear() {
        super.viewWillAppear()
        animateCharts()
    }
    
    @IBAction private func openStartWindow(_ sender: NSButton) {
        let window = NSWindow(
            contentRect: NSRect(x: 0, y: 0, width: 810, height: 850),
            styleMask: [.titled, .closable],
            backing: .buffered,
            defer: false)
        window.titlebarAppearsTransparent = true
        window.title = "Start analysis"
        let contentViewController = NSStoryboard(name: "Main", bundle: nil)
            .instantiateController(withIdentifier: "AnalysisSettingsViewController")
            as! AnalysisSettingsViewController
        
        let analyser = Analyser()
        analyser.completion = analysisCompletion
        self.analyser = analyser
        contentViewController.analyser = analyser
        contentViewController.onStartAction = {
            DispatchQueue.main.async {
                self.progressIndicator.startAnimation(self)
            }
        }
        
        window.contentViewController = contentViewController
        window.makeKeyAndOrderFront(nil)
        window.isReleasedWhenClosed = false
        window.center()
    }
    
    @IBAction private func stop(_ sender: NSButton) {
        analyser?.cancel()
        DispatchQueue.main.async {
            self.progressIndicator.stopAnimation(self)
        }
    }
    
    private func setupCharts() {
        guard let rejectProbabilityChart = self.rejectProbabilityChart,
              let stayTimeChart = self.stayTimeChart,
              let usingRateChart = self.usingRateChart else {
            return
        }
        
        let charts = [rejectProbabilityChart, stayTimeChart, usingRateChart]
        
        for chart in charts {
            chart.xAxis.labelTextColor = .textColor
            chart.leftAxis.labelTextColor = .textColor
            chart.rightAxis.labelTextColor = .textColor
            chart.chartDescription?.textColor = .textColor
            chart.legend.textColor = .textColor
            chart.noDataTextColor = .textColor
            
            chart.gridBackgroundColor = .controlAccentColor
            chart.rightAxis.drawLabelsEnabled = false
        }
        self.rejectProbabilityChart.chartDescription?.text = "Reject probability"
        self.stayTimeChart.chartDescription?.text = "Request stay time"
        self.usingRateChart.chartDescription?.text = "Processors using rate"
    }
    
    private func animateCharts() {
        guard let rejectProbabilityChart = self.rejectProbabilityChart,
              let stayTimeChart = self.stayTimeChart,
              let usingRateChart = self.usingRateChart else {
            return
        }
        
        let charts = [rejectProbabilityChart, stayTimeChart, usingRateChart]
        
        for chart in charts {
            chart.animate(xAxisDuration: 0.0, yAxisDuration: 1.0)
        }
    }
    
    private func drawCharts(values: [Int], rejectProbability: [Double], stayTime: [Double], usingRate: [Double]) {
        rejectProbabilityChart.setData(x: values, y: rejectProbability, label: "Reject probability")
        stayTimeChart.setData(x: values, y: stayTime, label: "Request stay time")
        usingRateChart.setData(x: values, y: usingRate, label: "Processors using rate")
    }
}

extension LineChartView {
    
    func setData(x xData: [Int], y yData: [Double], label: String) {
        
        let drawCirclesLimit = 15
        let drawValuesLimit = 15
        
        guard xData.count == yData.count else {
            return
        }
        var entries = [ChartDataEntry]()
        
        for index in 0...xData.count - 1 {
            entries.append(ChartDataEntry(x: Double(xData[index]), y: yData[index]))
        }

        let data = LineChartData()
        let dataSet = LineChartDataSet(entries: entries, label: label)
        dataSet.valueTextColor = .textColor
        dataSet.colors = [.controlAccentColor]
        
        if xData.count < drawCirclesLimit {
            dataSet.circleRadius = 5
            dataSet.setCircleColor(.controlAccentColor)
        } else {
            dataSet.drawCirclesEnabled = false
        }
        
        dataSet.drawValuesEnabled = xData.count < drawValuesLimit
    
        data.addDataSet(dataSet)
        
        self.data = data
    }
}
