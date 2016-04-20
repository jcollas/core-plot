//
// DatePlot.m
// Plot Gallery-Mac
//

import CorePlot

class DatePlot: PlotItem {

    let oneDay: NSTimeInterval = 24 * 60 * 60

    var plotData: [[CPTScatterPlotField: Double]] = []

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Date Plot"
        section = kLinePlots
    }

    override func generateData() {

        if plotData.isEmpty {

            // Add some data
            var newData: [[CPTScatterPlotField: Double]] = []

            for i in 0..<5 {
                let xVal = oneDay * Double(i)
                let yVal = 1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2

                newData.append(
                 [ .X: xVal,
                    .Y: yVal ]
                 )
                
                self.plotData = newData
            }
        }
    }


    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let dateComponents = NSDateComponents()

        dateComponents.month  = 10
        dateComponents.day    = 29
        dateComponents.year   = 2009
        dateComponents.hour   = 12
        dateComponents.minute = 0
        dateComponents.second = 0

        let gregorian = NSCalendar(calendarIdentifier: NSCalendarIdentifierGregorian)
        let refDate = gregorian?.dateFromComponents(dateComponents)

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        // Setup scatter plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        let  xLow: NSTimeInterval       = 0.0
        plotSpace.xRange = CPTPlotRange(location: xLow, length:oneDay * 5.0)
        plotSpace.yRange = CPTPlotRange(location: 1.0, length:3.0)

        // Axes
        let axisSet = graph.axisSet as! CPTXYAxisSet
        if let x          = axisSet.xAxis {
            x.majorIntervalLength   = oneDay
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 0
            let dateFormatter = NSDateFormatter()
            dateFormatter.dateStyle = .ShortStyle
            let timeFormatter = CPTTimeFormatter(dateFormatter:dateFormatter)
            timeFormatter.referenceDate = refDate
            x.labelFormatter            = timeFormatter
            x.labelRotation             = CGFloat(M_PI_4)
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = oneDay
        }

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = "Date Plot"

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth              = 3.0
        lineStyle.lineColor              = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle = lineStyle
        
        dataSourceLinePlot.dataSource = self
        graph.addPlot(dataSourceLinePlot)
    }

}

//MARK: - Plot Data Source Methods

extension DatePlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return nil
        }

        return plotData[Int(index)][field]
    }

}
