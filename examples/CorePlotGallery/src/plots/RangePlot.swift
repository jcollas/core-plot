//
// RangePlot.m
// CorePlotGallery
//

import CorePlot

class RangePlot: PlotItem {

    let oneDay: TimeInterval = 24 * 60 * 60

    var graph: CPTGraph? = nil
    var plotData: [[CPTRangePlotField: Double]] = []
    var areaFill: CPTFill!
    var barLineStyle: CPTLineStyle!

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Range Plot"
        section = kFinancialPlots
    }

    override func generateData() {
        if plotData.isEmpty {
            var newData: [[CPTRangePlotField: Double]] = []
            for i in 0..<5 {
                let x = oneDay * (Double(i) + 1.0)

                let y      = 3.0 * Double(arc4random()) / Double(UInt32.max) + 1.2
                let rHigh  = Double(arc4random()) / Double(UInt32.max) * 0.5 + 0.25
                let rLow   = Double(arc4random()) / Double(UInt32.max) * 0.5 + 0.25
                let rLeft  = (Double(arc4random()) / Double(UInt32.max) * 0.125 + 0.125) * oneDay
                let rRight = (Double(arc4random()) / Double(UInt32.max) * 0.125 + 0.125) * oneDay

                newData.append(
                 [ .X: x,
                    .Y: y,
                    .high: rHigh,
                    .low: rLow,
                    .left: rLeft,
                    .right: rRight ]
                 )
            }
            
            self.plotData = newData
        }
    }

    override func renderInGraphHostingView(_ hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

        // If you make sure your dates are calculated at noon, you shouldn't have to
        // worry about daylight savings. If you use midnight, you will have to adjust
        // for daylight savings time.
        let refDate = NSDate(timeIntervalSinceReferenceDate: oneDay / 2.0)

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let newGraph = CPTXYGraph(frame: bounds)
        graph = newGraph

        self.addGraph(newGraph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: newGraph, withDefault: CPTTheme(named: CPTThemeName.darkGradientTheme))

        newGraph.plotAreaFrame?.masksToBorder = false

        // Instructions
        let textStyle = CPTMutableTextStyle()
        textStyle.color    = CPTColor.white()
        textStyle.fontName = "Helvetica"
        textStyle.fontSize = self.titleSize * 0.5

#if os(iOS)
        let textLayer = CPTTextLayer(text: "Touch to Toggle Range Plot Style", style:textStyle)
#else
        let textLayer = CPTTextLayer(text: "Click to Toggle Range Plot Style", style:textStyle)
#endif

        if let anchorLayer = newGraph.plotAreaFrame?.plotArea {
            let instructionsAnnotation = CPTLayerAnnotation(anchorLayer: anchorLayer)
            instructionsAnnotation.contentLayer = textLayer
            instructionsAnnotation.rectAnchor = .bottom
            instructionsAnnotation.contentAnchorPoint = CGPoint(x: 0.5, y: 0.0)
            instructionsAnnotation.displacement = CGPoint(x: 0.0, y: 10.0)
            newGraph.plotAreaFrame?.plotArea?.addAnnotation(instructionsAnnotation)
        }

        // Setup fill and bar style
        if self.areaFill == nil {
            let transparentGreen = CPTColor.green().withAlphaComponent(0.2)
            self.areaFill = CPTFill(color: transparentGreen)
        }

        if self.barLineStyle == nil {
            let lineStyle = CPTMutableLineStyle()
            lineStyle.lineWidth = 1.0
            lineStyle.lineColor = CPTColor.green()
            self.barLineStyle   = lineStyle
        }

        // Setup scatter plot space
        let plotSpace = newGraph.defaultPlotSpace as! CPTXYPlotSpace
        let xLow = oneDay * 0.5
        plotSpace.xRange = CPTPlotRange(location: NSNumber(value: xLow), length: NSNumber(value: oneDay * 5.0))
        plotSpace.yRange = CPTPlotRange(location:1.5, length:3.5)

        // Axes
        let axisSet = newGraph.axisSet as! CPTXYAxisSet

        guard let
            x = axisSet.xAxis,
            let y = axisSet.yAxis else {
                return
        }

        x.majorIntervalLength   = oneDay as NSNumber?
        x.orthogonalPosition    = 2.0
        x.minorTicksPerInterval = 0
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .short
        let timeFormatter = CPTTimeFormatter(dateFormatter: dateFormatter)
        timeFormatter.referenceDate = refDate as Date
        x.labelFormatter = timeFormatter

        y.majorIntervalLength   = 0.5
        y.minorTicksPerInterval = 5
        y.orthogonalPosition    = oneDay as NSNumber?

        // Create a plot that uses the data source method
        let rangePlot = CPTRangePlot()
        rangePlot.identifier   = "Range Plot" as (NSCoding & NSCopying & NSObjectProtocol)?
        rangePlot.barLineStyle = self.barLineStyle
        rangePlot.dataSource   = self
        rangePlot.delegate     = self

        // Bar properties
        rangePlot.barWidth  = 10.0
        rangePlot.gapWidth  = 20.0
        rangePlot.gapHeight = 20.0

        // Add plot
        newGraph.add(rangePlot)
        newGraph.defaultPlotSpace?.delegate = self

        // Add legend
        newGraph.legend = CPTLegend(graph: newGraph)
        newGraph.legend?.textStyle = x.titleTextStyle
        newGraph.legend?.fill = CPTFill(color: CPTColor.darkGray())
        newGraph.legend?.borderLineStyle = x.axisLineStyle
        newGraph.legend?.cornerRadius = 5.0
        newGraph.legend?.swatchCornerRadius = 3.0
        newGraph.legendAnchor = .top
        newGraph.legendDisplacement = CGPoint(x: 0.0, y: self.titleSize * -2.0 - 12.0)
    }

}

//MARK: - Plot Data Source Methods

extension RangePlot: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {

        guard let field = CPTRangePlotField(rawValue: Int(fieldEnum)) else {
            return nil
        }

        return self.plotData[Int(index)][field]
    }

}

//MARK: - Plot Space Delegate Methods

extension RangePlot: CPTPlotSpaceDelegate {

    func plotSpace(_ space: CPTPlotSpace, shouldHandlePointingDeviceUp event: CPTNativeEvent, at point: CGPoint) -> Bool {
        let rangePlot = graph?.plot(withIdentifier: "Range Plot" as NSCopying?) as! CPTRangePlot

        rangePlot.areaFill = (rangePlot.areaFill != nil ? nil : self.areaFill)

        if rangePlot.areaFill != nil {
            let lineStyle = CPTMutableLineStyle()
            lineStyle.lineColor = CPTColor.lightGray()

            rangePlot.areaBorderLineStyle = lineStyle
        }
        else {
            rangePlot.areaBorderLineStyle = nil
        }
        
        return false
    }

}

//MARK: - Plot Delegate Methods

extension RangePlot: CPTRangePlotDelegate {

    func rangePlot(_ plot: CPTRangePlot, rangeWasSelectedAtRecord index: UInt) {
        NSLog("Range for '\(plot.identifier)' was selected at index \(index).")
    }

}
