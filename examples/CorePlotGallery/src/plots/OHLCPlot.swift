//
// OHLCPlot.m
// CorePlotGallery
//

import Foundation
import CorePlot

class OHLCPlot: PlotItem { //<CPTPlotDataSource,CPTTradingRangePlotDelegate>

    let oneDay: NSTimeInterval = 24 * 60 * 60

    var graph: CPTGraph?
    var plotData: [[CPTTradingRangePlotField: Double]] = []

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "OHLC Plot"
        section = kFinancialPlots
    }

    override func generateData() {
        if plotData.isEmpty {
            var newData: [[CPTTradingRangePlotField: Double]] = []
            for i in 0..<8 {
                let x = oneDay * Double(i)

                let rOpen  = 3.0 * Double(arc4random()) / Double(UInt32.max) + 1.0
                let rClose = (Double(arc4random()) / Double(UInt32.max) - 0.5) * 0.125 + rOpen
                let rHigh  = max( rOpen, max(rClose, (Double(arc4random()) / Double(UInt32.max) - 0.5) * 0.5 + rOpen) )
                let rLow   = min( rOpen, min(rClose, (Double(arc4random()) / Double(UInt32.max) - 0.5) * 0.5 + rOpen) )

                newData.append(
                               [ .X: x,
                                .Open: rOpen,
                                .High: rHigh,
                                .Low: rLow,
                                .Close: rClose ]
                               )
            }
            
            self.plotData = newData
        }
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let refDate = NSDate(timeIntervalSinceReferenceDate: oneDay / 2.0)

#if os(iOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let newGraph = CPTXYGraph(frame: bounds)
        self.addGraph(newGraph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: newGraph, withDefault: CPTTheme(named: kCPTStocksTheme))

        let borderLineStyle = CPTMutableLineStyle()
        borderLineStyle.lineColor = CPTColor.whiteColor()
        borderLineStyle.lineWidth = 2.0
        newGraph.plotAreaFrame?.borderLineStyle = borderLineStyle
        newGraph.plotAreaFrame?.paddingTop      = self.titleSize * 0.5
        newGraph.plotAreaFrame?.paddingRight    = self.titleSize * 0.5
        newGraph.plotAreaFrame?.paddingBottom   = self.titleSize * 1.25
        newGraph.plotAreaFrame?.paddingLeft     = self.titleSize * 1.5
        newGraph.plotAreaFrame?.masksToBorder   = false

        self.graph = newGraph

        // Axes
        let xyAxisSet = newGraph.axisSet as! CPTXYAxisSet

        guard let xAxis = xyAxisSet.xAxis, yAxis = xyAxisSet.yAxis else {
            return
        }

        xAxis.majorIntervalLength   = oneDay
        xAxis.minorTicksPerInterval = 0
        let dateFormatter = NSDateFormatter()
        dateFormatter.dateStyle = .ShortStyle
        let timeFormatter = CPTTimeFormatter(dateFormatter: dateFormatter)
        timeFormatter.referenceDate = refDate
        xAxis.labelFormatter = timeFormatter

        let lineCap = CPTLineCap()
        lineCap.lineStyle    = xAxis.axisLineStyle
        lineCap.lineCapType  = .OpenArrow
        lineCap.size         = CGSize(width: self.titleSize * 0.5, height: self.titleSize * 0.5)
        xAxis.axisLineCapMax = lineCap

        yAxis.orthogonalPosition = -0.5 * oneDay

        // Line plot with gradient fill
        let dataSourceLinePlot = CPTScatterPlot(frame: newGraph.bounds)
        dataSourceLinePlot.identifier = "Data Source Plot"
        dataSourceLinePlot.title = "Close Values"
        dataSourceLinePlot.dataLineStyle = nil
        dataSourceLinePlot.dataSource = self
        newGraph.addPlot(dataSourceLinePlot)

        var areaColor = CPTColor(componentRed: 1.0, green: 1.0, blue: 1.0, alpha: 0.6)
        var areaGradient = CPTGradient(beginningColor: areaColor, endingColor: CPTColor.clearColor())
        areaGradient.angle = -90.0
        var areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 0.0

        areaColor = CPTColor(componentRed: 0.0, green: 1.0, blue: 0.0, alpha: 0.6)
        areaGradient = CPTGradient(beginningColor: CPTColor.clearColor(), endingColor: areaColor)
        areaGradient.angle = -90.0
        areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill2 = areaGradientFill
        dataSourceLinePlot.areaBaseValue2 = 5.0

        // OHLC plot
        let whiteLineStyle = CPTMutableLineStyle()
        whiteLineStyle.lineColor = CPTColor.whiteColor()
        whiteLineStyle.lineWidth = 2.0

        let redLineStyle = whiteLineStyle.mutableCopy() as! CPTMutableLineStyle
        redLineStyle.lineColor = CPTColor.redColor()

        let greenLineStyle = whiteLineStyle.mutableCopy() as! CPTMutableLineStyle
        greenLineStyle.lineColor = CPTColor.greenColor()

        let whiteTextStyle = CPTMutableTextStyle()
        whiteTextStyle.color = CPTColor.whiteColor()

        let ohlcPlot = CPTTradingRangePlot(frame: newGraph.bounds)
        ohlcPlot.identifier = "OHLC"

        ohlcPlot.lineStyle         = whiteLineStyle
        ohlcPlot.increaseLineStyle = greenLineStyle
        ohlcPlot.decreaseLineStyle = redLineStyle

        ohlcPlot.labelTextStyle = whiteTextStyle
        ohlcPlot.labelOffset    = 5.0
        ohlcPlot.stickLength    = 10.0
        ohlcPlot.dataSource     = self
        ohlcPlot.delegate       = self
        ohlcPlot.plotStyle      = .OHLC
        newGraph.addPlot(ohlcPlot)

        // Add legend
        newGraph.legend = CPTLegend(graph: newGraph)
        newGraph.legend?.textStyle = xAxis.titleTextStyle
        newGraph.legend?.fill = newGraph.plotAreaFrame?.fill
        newGraph.legend?.borderLineStyle = newGraph.plotAreaFrame?.borderLineStyle
        newGraph.legend?.cornerRadius = 5.0
        newGraph.legend?.swatchCornerRadius = 5.0
        newGraph.legendAnchor = .Bottom
        newGraph.legendDisplacement = CGPoint(x: 0.0, y: self.titleSize * 3.0)
        
        // Set plot ranges
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: -0.5 * oneDay, length: oneDay * Double(plotData.count))
        plotSpace.yRange = CPTPlotRange(location:0.0, length:4.0)
    }

}

//MARK: - Plot Data Source Methods

extension OHLCPlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
        var num: Double? = 0.0

        if plot.identifier as! String == "Data Source Plot" {

            guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
                return nil
            }

            switch ( field ) {
                case .X:
                    num = self.plotData[Int(index)][.X]

                case .Y:
                    num = self.plotData[Int(index)][.Close]
            }
        } else {

            guard let field = CPTTradingRangePlotField(rawValue: Int(fieldEnum)) else {
                return nil
            }

            num = self.plotData[Int(index)][field]
        }

        return num
    }

}

//MARK: - Plot Delegate Methods

extension OHLCPlot: CPTTradingRangePlotDelegate {

    func tradingRangePlot(plot: CPTTradingRangePlot, barWasSelectedAtRecordIndex index: UInt) {
        NSLog("Bar for '\(plot.identifier)' was selected at index \(index).")
    }

}
