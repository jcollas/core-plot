//
// CurvedScatterPlot.m
// Plot_Gallery_iOS
//
// Created by Nino Ag on 23/10/11.

import CorePlot

class CurvedScatterPlot: PlotItem {

    let kData   = "Data Source Plot"
    let kFirst  = "First Derivative"
    let kSecond = "Second Derivative"

    var symbolTextAnnotation: CPTPlotSpaceAnnotation? = nil
    var plotData: [[String: Double]] = []
    var plotData1: [[String: Double]] = []
    var plotData2: [[String: Double]] = []

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Curved Scatter Plot"
        section = kLinePlots
    }

    override func killGraph() {
    if graphs.count != 0 {
        let graph = graphs[0] 

        if let annotation = self.symbolTextAnnotation {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }
    }

    super.killGraph()
}

    override func generateData() {

        if plotData.isEmpty {
            var contentArray: [[String: Double]] = []

            for i in 0..<11 {
                let x = 1.0 + Double(i) * 0.05
                let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 0.5
                contentArray.append(
                    [ "x": x,
                        "y": y ]
                )
            }

            self.plotData = contentArray
        }

        if plotData1.isEmpty {
            var contentArray: [[String: Double]] = []
            let dataArray = self.plotData

            for i in 1..<dataArray.count {
                let point1 = dataArray[i - 1]
                let point2 = dataArray[i]

                let x1   = point1["x"]!
                let x2   = point2["x"]!
                let dx   = x2 - x1
                let xLoc = (x1 + x2) * 0.5

                let y1 = point1["y"]!
                let y2 = point2["y"]!
                let dy = y2 - y1

                contentArray.append(
                    [ "x": xLoc,
                        "y": (dy / dx) / 20.0 ]
                )
            }

            plotData1 = contentArray
        }

        if plotData2.isEmpty {
            var contentArray: [[String: Double]] = []
            let dataArray = self.plotData1

            for i in 1..<dataArray.count {
                let point1 = dataArray[i - 1]
                let point2 = dataArray[i]

                let x1   = point1["x"]!
                let x2   = point2["x"]!
                let dx   = x2 - x1
                let xLoc = (x1 + x2) * 0.5
                
                let y1 = point1["y"]!
                let y2 = point2["y"]!
                let dy = y2 - y1
                
                contentArray.append(
                    [ "x": xLoc,
                        "y": (dy / dx) / 20.0 ]
                )
            }
            
            plotData2 = contentArray
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
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        graph.plotAreaFrame?.paddingLeft   += self.titleSize * 2.25
        graph.plotAreaFrame?.paddingTop    += self.titleSize
        graph.plotAreaFrame?.paddingRight  += self.titleSize
        graph.plotAreaFrame?.paddingBottom += self.titleSize
        graph.plotAreaFrame?.masksToBorder  = false

        // Plot area delegate
        graph.plotAreaFrame?.plotArea?.delegate = self

        // Setup scatter plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.delegate = self

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

        let lineCap = CPTLineCap.sweptArrowPlotLineCap()
        lineCap.size = CGSizeMake( self.titleSize * 0.625, self.titleSize * 0.625 )

        // Axes
        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let x = axisSet.xAxis, y = axisSet.yAxis else {
            return
        }

        x.majorIntervalLength   = 0.1
        x.minorTicksPerInterval = 4
        x.majorGridLineStyle    = majorGridLineStyle
        x.minorGridLineStyle    = minorGridLineStyle
        x.axisConstraints       = CPTConstraints(relativeOffset:0.5)

        lineCap.lineStyle = x.axisLineStyle
        var lineColor = lineCap.lineStyle?.lineColor
        if lineColor != nil {
            lineCap.fill = CPTFill(color: lineColor!)
        }
        x.axisLineCapMax = lineCap

        x.title       = "X Axis"
        x.titleOffset = self.titleSize * 1.25

        // Label y with an automatic label policy.
        y.labelingPolicy              = .Automatic
        y.minorTicksPerInterval       = 4
        y.preferredNumberOfMajorTicks = 8
        y.majorGridLineStyle          = majorGridLineStyle
        y.minorGridLineStyle          = minorGridLineStyle
        y.axisConstraints             = CPTConstraints(lowerOffset: 0.0)
        y.labelOffset                 = self.titleSize * 0.25

        lineCap.lineStyle = y.axisLineStyle
        lineColor = lineCap.lineStyle?.lineColor
        if lineColor != nil {
            lineCap.fill = CPTFill(color: lineColor!)
        }
        y.axisLineCapMax = lineCap
        y.axisLineCapMin = lineCap

        y.title       = "Y Axis"
        y.titleOffset = self.titleSize * 1.25

        // Set axes
        graph.axisSet?.axes = [x, y]

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = kData

        // Make the data source line use curved interpolation
        dataSourceLinePlot.interpolation = .Curved

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth              = 3.0
        lineStyle.lineColor              = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle = lineStyle

        dataSourceLinePlot.dataSource = self
        graph.addPlot(dataSourceLinePlot)

        // First derivative
        let firstPlot = CPTScatterPlot()
        firstPlot.identifier    = kFirst
        lineStyle.lineWidth     = 2.0
        lineStyle.lineColor     = CPTColor.redColor()
        firstPlot.dataLineStyle = lineStyle
        firstPlot.dataSource    = self

        // [graph addPlot:firstPlot]

        // Second derivative
        let secondPlot = CPTScatterPlot()
        secondPlot.identifier    = kSecond
        lineStyle.lineColor      = CPTColor.blueColor()
        secondPlot.dataLineStyle = lineStyle
        secondPlot.dataSource    = self

        // [graph addPlot:secondPlot]

        // Auto scale the plot space to fit the plot data
        plotSpace.scaleToFitEntirePlots(graph.allPlots())
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange

        // Expand the ranges to put some space around the plot
        xRange.expandRangeByFactor(1.025)
        xRange.location = plotSpace.xRange.location
        yRange.expandRangeByFactor(1.05)
        x.visibleAxisRange = xRange
        y.visibleAxisRange = yRange

        xRange.expandRangeByFactor(3.0)
        yRange.expandRangeByFactor(3.0)
        plotSpace.globalXRange = xRange
        plotSpace.globalYRange = yRange

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.blackColor().colorWithAlphaComponent(0.5)
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill = CPTFill(color: CPTColor.blueColor().colorWithAlphaComponent(0.5))
        plotSymbol.lineStyle = symbolLineStyle
        plotSymbol.size = CGSizeMake(10.0, 10.0)
        dataSourceLinePlot.plotSymbol = plotSymbol

        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        dataSourceLinePlot.delegate = self
        
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0
        
        // Add legend
        graph.legend = CPTLegend(graph: graph)
        graph.legend?.numberOfRows = 1
        graph.legend?.textStyle = x.titleTextStyle
        graph.legend?.fill = CPTFill(color: CPTColor.darkGrayColor())
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius = 5.0
        graph.legendAnchor = .Bottom
        graph.legendDisplacement = CGPointMake( 0.0, self.titleSize * 2.0 )
    }

}

//MARK: - Plot Data Source Methods

extension CurvedScatterPlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        var numRecords: UInt = 0
        let identifier  = plot.identifier as! String

        if identifier == kData {
            numRecords = UInt(plotData.count)
        }
        else if identifier == kFirst {
            numRecords = UInt(plotData1.count)
        }
        else if identifier == kSecond {
            numRecords = UInt(plotData2.count)
        }
        
        return numRecords
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
        var num: Double? = nil
        let identifier  = plot.identifier as! String

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return num
        }

        let key = field == .X ? "x" : "y"

        if identifier == kData {
            num = self.plotData[Int(index)][key]
        }
        else if identifier == kFirst {
            num = self.plotData1[Int(index)][key]
        }
        else if identifier == kSecond {
            num = self.plotData2[Int(index)][key]
        }
        
        return num
    }

}

//MARK: - Plot Space Delegate Methods

extension CurvedScatterPlot: CPTPlotSpaceDelegate {

    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        let theGraph = space.graph
        let axisSet = theGraph?.axisSet as! CPTXYAxisSet

        let changedRange = newRange.mutableCopy() as! CPTMutablePlotRange

        switch ( coordinate ) {
            case .X:
                changedRange.expandRangeByFactor(1.025)
                changedRange.location = newRange.location
                axisSet.xAxis?.visibleAxisRange = changedRange

            case .Y:
                changedRange.expandRangeByFactor(1.05)
                axisSet.yAxis?.visibleAxisRange = changedRange

            default:
                break
        }
        
        return newRange
    }

}

//MARK: - CPTScatterPlot delegate methods

extension CurvedScatterPlot: CPTScatterPlotDelegate {

    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: UInt) {
        let graph = graphs[0] as! CPTXYGraph

        var annotation = self.symbolTextAnnotation

        if annotation != nil {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }

        // Setup a style for the annotation
        let hitAnnotationTextStyle = CPTMutableTextStyle()
        hitAnnotationTextStyle.color    = CPTColor.whiteColor()
        hitAnnotationTextStyle.fontName = "Helvetica-Bold"

        // Determine point of symbol in plot coordinates
        var dataPoint: [String: Double] = self.plotData[Int(index)]

        let x = dataPoint["x"]!
        let y = dataPoint["y"]!

        let anchorPoint: [Double] = [x, y]

        // Add annotation
        // First make a string for the y value
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let yString = formatter.stringFromNumber(y)

        // Now add the annotation to the plot area
        let textLayer = CPTTextLayer(text: yString, style: hitAnnotationTextStyle)
        let background = CPTImage(named: "BlueBackground")
        background.edgeInsets = CPTEdgeInsetsMake(8.0, 8.0, 8.0, 8.0)
        textLayer.fill = CPTFill(image: background)
        textLayer.paddingLeft = 2.0
        textLayer.paddingTop = 2.0
        textLayer.paddingRight = 2.0
        textLayer.paddingBottom = 2.0

        if let defaultSpace = graph.defaultPlotSpace {
            annotation = CPTPlotSpaceAnnotation(plotSpace: defaultSpace, anchorPlotPoint: anchorPoint)
            annotation?.contentLayer = textLayer
            annotation?.contentAnchorPoint = CGPointMake(0.5, 0.0)
            annotation?.displacement = CGPointMake(0.0, 10.0)
            graph.plotAreaFrame?.plotArea?.addAnnotation(annotation)
        }
    }

    func scatterPlotDataLineWasSelected(plot: CPTScatterPlot) {
        NSLog("scatterPlotDataLineWasSelected: \(plot)")
    }

    func scatterPlotDataLineTouchDown(plot: CPTScatterPlot) {
        NSLog("scatterPlotDataLineTouchDown: \(plot)")
    }

    func scatterPlotDataLineTouchUp(plot: CPTScatterPlot) {
        NSLog("scatterPlotDataLineTouchUp: \(plot)")
    }

}

//MARK: - Plot area delegate method

extension CurvedScatterPlot: CPTPlotAreaDelegate {

    func plotAreaWasSelected(plotArea: CPTPlotArea) {
        // Remove the annotation
        if let annotation = self.symbolTextAnnotation {
            let graph = graphs[0] as! CPTXYGraph

            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }
    }

}
