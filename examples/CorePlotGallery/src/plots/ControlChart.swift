
import CorePlot

let kDataLine    = "Data Line"
let kCenterLine  = "Center Line"
let kControlLine = "Control Line"
let kWarningLine = "Warning Line"

let numberOfPoints = 11

class ControlChart: PlotItem { //<CPTPlotDataSource>

    var plotData: [Double] = []
    var meanValue = 0.0
    var standardError = 0.0

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Control Chart"
        section = kLinePlots
    }

    override func generateData() {

        if plotData.isEmpty {
            var contentArray: [Double] = []
            var sum = 0.0

            for _ in 0..<numberOfPoints {
                let y = 12.0 * Double(arc4random()) / Double(UInt32.max) + 5.0
                sum += y
                contentArray.append(y)
            }

            self.plotData = contentArray

            meanValue = sum / Double(numberOfPoints)

            sum = 0.0
            for value in contentArray {
                let error = value - self.meanValue
                sum += error * error
            }
            let stdDev = sqrt( ( 1.0 / Double(numberOfPoints - 1) ) * sum )
            self.standardError = stdDev / sqrt(Double(numberOfPoints))
        }
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTPlainWhiteTheme))

        graph.plotAreaFrame?.paddingTop    = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingRight  = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingBottom = self.titleSize * 1.5
        graph.plotAreaFrame?.paddingLeft   = self.titleSize * 1.5
        graph.plotAreaFrame?.masksToBorder = false

        // Grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.whiteColor().colorWithAlphaComponent(0.1)

        let redLineStyle = CPTMutableLineStyle()
        redLineStyle.lineWidth = 10.0
        redLineStyle.lineColor = CPTColor.redColor().colorWithAlphaComponent(0.5)

        let labelFormatter = NSNumberFormatter()
        labelFormatter.maximumFractionDigits = 0

        // Axes
        // X axis
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let
        x = axisSet.xAxis,
        y = axisSet.yAxis else {
            return
        }

        x.labelingPolicy     = .Automatic
        x.majorGridLineStyle = majorGridLineStyle
        x.minorGridLineStyle = minorGridLineStyle
        x.labelFormatter     = labelFormatter

        x.title       = "X Axis"
        x.titleOffset = self.titleSize * 1.25

        // Y axis
        y.labelingPolicy     = .Automatic
        y.majorGridLineStyle = majorGridLineStyle
        y.minorGridLineStyle = minorGridLineStyle
        y.labelFormatter     = labelFormatter

        y.title       = "Y Axis"
        y.titleOffset = self.titleSize * 1.25

        // Center line
        let centerLinePlot = CPTScatterPlot()
        centerLinePlot.identifier = kCenterLine

        var lineStyle = CPTMutableLineStyle()
        lineStyle.lineWidth          = 2.0
        lineStyle.lineColor          = CPTColor.greenColor()
        centerLinePlot.dataLineStyle = lineStyle

        centerLinePlot.dataSource = self
        graph.addPlot(centerLinePlot)

        // Control lines
        let controlLinePlot = CPTScatterPlot()
        controlLinePlot.identifier = kControlLine

        lineStyle                     = CPTMutableLineStyle()
        lineStyle.lineWidth           = 2.0
        lineStyle.lineColor           = CPTColor.redColor()
        lineStyle.dashPattern         = [10, 6]
        controlLinePlot.dataLineStyle = lineStyle

        controlLinePlot.dataSource = self
        graph.addPlot(controlLinePlot)

        // Warning lines
        let warningLinePlot = CPTScatterPlot()
        warningLinePlot.identifier = kWarningLine

        lineStyle                     = CPTMutableLineStyle()
        lineStyle.lineWidth           = 1.0
        lineStyle.lineColor           = CPTColor.orangeColor()
        lineStyle.dashPattern         = [5, 5]
        warningLinePlot.dataLineStyle = lineStyle

        warningLinePlot.dataSource = self
        graph.addPlot(warningLinePlot)

        // Data line
        let linePlot = CPTScatterPlot()
        linePlot.identifier = kDataLine

        lineStyle              = CPTMutableLineStyle()
        lineStyle.lineWidth    = 3.0
        linePlot.dataLineStyle = lineStyle

        linePlot.dataSource = self
        graph.addPlot(linePlot)

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.blackColor()
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill      = CPTFill(color: CPTColor.lightGrayColor())
        plotSymbol.lineStyle = symbolLineStyle
        plotSymbol.size      = CGSize(width: 10.0, height: 10.0)
        linePlot.plotSymbol  = plotSymbol

        // Auto scale the plot space to fit the plot data
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.scaleToFitPlots([linePlot])

        // Adjust visible ranges so plot symbols along the edges are not clipped
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange

        x.orthogonalPosition = yRange.location
        y.orthogonalPosition = xRange.location

        x.visibleRange = xRange
        y.visibleRange = yRange

        x.gridLinesRange = yRange
        y.gridLinesRange = xRange

        xRange.expandRangeByFactor(1.05)
        yRange.expandRangeByFactor(1.05)
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange
        
        // Add legend
        graph.legend = CPTLegend(plots:[linePlot, controlLinePlot, warningLinePlot, centerLinePlot])
        graph.legend?.fill = CPTFill(color: CPTColor.whiteColor())
        graph.legend?.textStyle       = x.titleTextStyle
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius    = 5.0
        graph.legend?.numberOfRows    = 1
        graph.legendAnchor           = .Bottom
        graph.legendDisplacement     = CGPoint(x: 0.0, y: self.titleSize * 4.0)
    }

}

//MARK: - Plot Data Source Methods

extension ControlChart: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        if plot.identifier as! String == kDataLine {
            return UInt(plotData.count)
        } else if plot.identifier as! String == kCenterLine {
            return 2
        } else {
            return 5
        }
    }

    func doubleForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> Double {
        var number: Double = 0.0 / 0.0

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return 0.0
        }

        switch ( field ) {
            case .X:
                if plot.identifier as! String == kDataLine {
                    number = Double(index)
                } else {
                    switch ( index % 3 ) {
                        case 0:
                            number = 0.0

                        case 1:
                            number = Double(plotData.count - 1)

                        case 2:
                            number = 0.0 / 0.0

                        default:
                            break
                    }
                }

            case .Y:
                if plot.identifier as! String == kDataLine {
                    number = self.plotData[Int(index)]
                } else if plot.identifier as! String == kCenterLine {
                    number = self.meanValue
                } else if plot.identifier as! String == kControlLine {
                    switch ( index ) {
                        case 0, 1:
                            number = self.meanValue + 3.0 * self.standardError

                        case 2:
                            number = 0.0 / 0.0

                        case 3, 4:
                            number = self.meanValue - 3.0 * self.standardError

                        default:
                            break
                    }
                } else if plot.identifier as! String == kWarningLine {
                    switch ( index ) {
                        case 0, 1:
                            number = self.meanValue + 2.0 * self.standardError

                        case 2:
                            number = 0.0 / 0.0

                        case 3, 4:
                            number = self.meanValue - 2.0 * self.standardError

                        default:
                            break
                    }
                }
        }
        
        return number
    }

}