//
// SteppedScatterPlot.m
// Plot Gallery-Mac
//

import CorePlot

class SteppedScatterPlot: PlotItem {

    var plotData: [[String: Double]] = []

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Stepped Scatter Plot"
        section = kLinePlots
    }

    override func generateData() {
        if ( self.plotData.isEmpty ) {
            var contentArray: [[String: Double]] = []
            for i in 0..<10 {
                let x = 1.0 + Double(i) * 0.05
                let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2
                contentArray.append([ "x": x, "y": y])
            }
            self.plotData = contentArray
        }
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {
        
#if os(iOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.cachePrecision = .Double

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth              = 1.0
        lineStyle.lineColor              = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle = lineStyle

        dataSourceLinePlot.dataSource = self
        dataSourceLinePlot.delegate   = self

        let whiteTextStyle = CPTMutableTextStyle()
        whiteTextStyle.color              = CPTColor.whiteColor()
        dataSourceLinePlot.labelTextStyle = whiteTextStyle
        dataSourceLinePlot.labelOffset    = 5.0
        dataSourceLinePlot.labelRotation  = CGFloat(M_PI_4)
        dataSourceLinePlot.identifier     = "Stepped Plot"
        graph.addPlot(dataSourceLinePlot)

        // Make the data source line use stepped interpolation
        dataSourceLinePlot.interpolation = .Stepped

        // Put an area gradient under the plot above
        let areaColor = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginningColor: areaColor, endingColor: CPTColor.clearColor())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 1.75

        // Auto scale the plot space to fit the plot data
        // Extend the y range by 10% for neatness
        let plotSpace = graph.defaultPlotSpace as? CPTXYPlotSpace
        plotSpace?.scaleToFitPlots([dataSourceLinePlot])
        let yRange = plotSpace?.yRange.mutableCopy() as! CPTMutablePlotRange
        yRange.expandRangeByFactor(1.1)
        plotSpace?.yRange = yRange
        
        // Restrict y range to a global range
        let globalYRange = CPTPlotRange(location: 0.0, length: 6.0)
        plotSpace?.globalYRange = globalYRange
    }
    
}

// MARK: - CPTScatterPlotDelegate Methods

extension SteppedScatterPlot: CPTScatterPlotDelegate {

    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex index: UInt) {
        NSLog("Data label for '\(plot.identifier)' was selected at index \(index).")
    }

}

// MARK: -  Plot Data Source Methods

extension SteppedScatterPlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
        if let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) {
            let key = field == .X ? "x" : "y"
            return self.plotData[Int(index)][key]
        }

        return nil
    }

}
