
import CorePlot

class ColoredBarChart: PlotItem {

    var plotData: [Double] = []

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Colored Bar Chart"
        section = kBarPlots
    }

    override func generateData() {
        if plotData.isEmpty {
            var contentArray: [Double] = []
            for _ in 0..<8 {
                contentArray.append(10.0 * Double(arc4random()) / Double(UInt32.max) + 5.0)
            }
            self.plotData = contentArray
        }
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTSlateTheme))


        graph.plotAreaFrame?.paddingLeft   += self.titleSize * 2.5
        graph.plotAreaFrame?.paddingTop    += self.titleSize * 1.25
        graph.plotAreaFrame?.paddingRight  += self.titleSize
        graph.plotAreaFrame?.paddingBottom += self.titleSize
        graph.plotAreaFrame?.masksToBorder  = false

        // Create grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 1.0
        majorGridLineStyle.lineColor = CPTColor.whiteColor().colorWithAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 1.0
        minorGridLineStyle.lineColor = CPTColor.whiteColor().colorWithAlphaComponent(0.25)

        // Create axes
        let axisSet = graph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 1.0
            x.minorTicksPerInterval = 0
            x.orthogonalPosition    = 0.0
            x.majorGridLineStyle    = majorGridLineStyle
            x.minorGridLineStyle    = minorGridLineStyle
            x.axisLineStyle         = nil
            x.majorTickLineStyle    = nil
            x.minorTickLineStyle    = nil
            x.labelFormatter        = nil
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength         = 10.0
            y.minorTicksPerInterval       = 9
            y.axisConstraints             = CPTConstraints(lowerOffset:0.0)
            y.preferredNumberOfMajorTicks = 8
            y.majorGridLineStyle          = majorGridLineStyle
            y.minorGridLineStyle          = minorGridLineStyle
            y.axisLineStyle               = nil
            y.majorTickLineStyle          = nil
            y.minorTickLineStyle          = nil
            y.labelOffset                 = self.titleSize * 0.375
            y.labelRotation               = CGFloat(M_PI_2)
            y.labelingPolicy              = .Automatic

            y.title       = "Y Axis"
            y.titleOffset = self.titleSize * 1.25
        }

        // Create a bar line style
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineWidth = 1.0
        barLineStyle.lineColor = CPTColor.whiteColor()

        // Create bar plot
        let barPlot = CPTBarPlot()
        barPlot.lineStyle         = barLineStyle
        barPlot.barWidth          = 0.75 // bar is 75% of the available space
        barPlot.barCornerRadius   = 4.0
        barPlot.barsAreHorizontal = false
        barPlot.dataSource        = self
        barPlot.identifier        = "Bar Plot 1"

        graph.addPlot(barPlot)

        // Plot space
        let barRange = barPlot.plotRangeEnclosingBars()?.mutableCopy() as! CPTMutablePlotRange
        barRange.expandRangeByFactor(1.05)

        let barPlotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        barPlotSpace.xRange = barRange
        barPlotSpace.yRange = CPTPlotRange(location: 0.0, length: 16.0)

        // Add legend
        let theLegend = CPTLegend(graph: graph)
        theLegend.fill            = CPTFill(color: CPTColor(genericGray: 0.15))
        theLegend.borderLineStyle = barLineStyle
        theLegend.cornerRadius    = 10.0
        let whiteTextStyle = CPTMutableTextStyle()
        whiteTextStyle.color   = CPTColor.whiteColor()
        theLegend.textStyle    = whiteTextStyle
        theLegend.numberOfRows = 1

        graph.legend             = theLegend
        graph.legendAnchor       = .Top
        graph.legendDisplacement = CGPoint(x: 0.0, y: self.titleSize * -2.625)
    }
    
}

// MARK: - Plot Data Source Methods

extension ColoredBarChart: CPTPlotDataSource {

        func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
            return UInt(plotData.count)
        }

        func numbersForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndexRange indexRange: NSRange) -> [AnyObject]? {
            var nums: [Double] = []

            guard let field = CPTBarPlotField(rawValue: Int(fieldEnum)) else {
                return nums
            }

            switch ( field ) {
                case .BarLocation:
                    for i in indexRange.location..<NSMaxRange(indexRange) {
                        nums.append(Double(i))
                    }

                case .BarTip:
                    nums = (plotData as NSArray).objectsAtIndexes(NSIndexSet(indexesInRange: indexRange)) as! [Double]

                default:
                    break
            }

            return nums
        }

}

extension ColoredBarChart: CPTBarPlotDataSource {

    func barFillForBarPlot(barPlot: CPTBarPlot, recordIndex index: UInt) -> CPTFill? {
        let colors: [CPTColor] = [.redColor(), .greenColor(), .blueColor(), .yellowColor(), .purpleColor(), .cyanColor(), .orangeColor(), .magentaColor()]

        var color = CPTColor.blackColor()

        if Int(index) < colors.count {
            color = colors[Int(index)]
        }

        let fillGradient = CPTGradient(beginningColor: color, endingColor: CPTColor.blackColor())
        
        return CPTFill(gradient: fillGradient)
    }

    func legendTitleForBarPlot(barPlot: CPTBarPlot, recordIndex idx: UInt) -> String? {
        return "Bar \(idx + 1)"
    }

}
