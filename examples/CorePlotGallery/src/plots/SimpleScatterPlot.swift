//
// SimpleScatterPlot.m
// CorePlotGallery
//

import CorePlot

class SimpleScatterPlot: PlotItem {

    var symbolTextAnnotation: CPTPlotSpaceAnnotation?
    var plotData: [[String: Double]] = []
    var histogramOption: CPTScatterPlotHistogramOption = .SkipSecond

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Simple Scatter Plot"
        section = kLinePlots
    }

    override func killGraph() {
        if self.graphs.count != 0 {
            let graph = self.graphs[0]

            if let annotation = self.symbolTextAnnotation {
                graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
                self.symbolTextAnnotation = nil
            }
        }

        super.killGraph()
    }

    override func generateData() {
        if self.plotData.isEmpty {
            var contentArray: [[String: Double]] = []
            for i in 0..<10 {
                let x = 1.0 + Double(i) * 0.05
                let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 0.5
                contentArray.append( [ "x": x, "y": y ] )
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

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        // Plot area delegate
        graph.plotAreaFrame?.plotArea?.delegate = self

        // Setup scatter plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.delegate              = self

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

        // Axes
        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let x = axisSet.xAxis, y = axisSet.yAxis else {
            return
        }

        x.majorIntervalLength = 0.5
        x.orthogonalPosition = 1.0
        x.minorTicksPerInterval = 2
        x.majorGridLineStyle = majorGridLineStyle
        x.minorGridLineStyle = minorGridLineStyle

        x.title = "X Axis"
        x.titleOffset   = 30.0
        x.titleLocation = 1.25

        // Label y with an automatic label policy.
        y.labelingPolicy = .Automatic
        y.orthogonalPosition = 1.0
        y.minorTicksPerInterval = 2
        y.preferredNumberOfMajorTicks = 8
        y.majorGridLineStyle = majorGridLineStyle
        y.minorGridLineStyle = minorGridLineStyle
        y.labelOffset = 10.0

        y.title = "Y Axis"
        y.titleOffset   = 30.0
        y.titleLocation = 1.0

        // Set axes
        graph.axisSet?.axes = [x, y]

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = "Data Source Plot"

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth = 3.0
        lineStyle.lineColor = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle   = lineStyle
        dataSourceLinePlot.histogramOption = self.histogramOption

        dataSourceLinePlot.dataSource = self
        graph.addPlot(dataSourceLinePlot)

        // Auto scale the plot space to fit the plot data
        // Extend the ranges by 30% for neatness
        plotSpace.scaleToFitPlots([dataSourceLinePlot])
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        xRange.expandRangeByFactor(1.3)
        yRange.expandRangeByFactor(1.3)
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange

        // Restrict y range to a global range
        let globalYRange = CPTPlotRange(location:0.0, length: 2.0)
        plotSpace.globalYRange = globalYRange

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.blackColor()
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill               = CPTFill(color: CPTColor.blueColor())
        plotSymbol.lineStyle          = symbolLineStyle
        plotSymbol.size               = CGSize(width: 10.0, height: 10.0)
        dataSourceLinePlot.plotSymbol = plotSymbol

        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        dataSourceLinePlot.delegate                        = self
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0
        
        // Add legend
        graph.legend = CPTLegend(graph: graph)
        graph.legend?.textStyle       = x.titleTextStyle
        graph.legend?.fill            = CPTFill(color: CPTColor.darkGrayColor())
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius    = 5.0
        graph.legendAnchor           = .Bottom
        graph.legendDisplacement     = CGPoint(x: 0.0, y: 12.0)
    }
    
}

// MARK: - Plot Data Source Methods

extension SimpleScatterPlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {

        if let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) {
            let key = field == .X ? "x" : "y"
            return self.plotData[Int(index)][key]
        }
        
        return 0.0
    }

}

// MARK: - Plot Space Delegate Methods

extension SimpleScatterPlot: CPTPlotSpaceDelegate {

    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        // Impose a limit on how far user can scroll in x
        if coordinate == .X {
            let maxRange = CPTPlotRange(location: -1.0, length: 6.0)
            let changedRange = newRange.mutableCopy() as! CPTMutablePlotRange

            changedRange.shiftEndToFitInRange(maxRange)
            changedRange.shiftLocationToFitInRange(maxRange)

            return changedRange
        }

        return newRange
    }

}

//MARK: - CPTScatterPlot delegate methods

extension SimpleScatterPlot: CPTScatterPlotDelegate {

    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: UInt) {
        let graph = self.graphs[0]

        if let annotation = self.symbolTextAnnotation {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
        }

        // Setup a style for the annotation
        let hitAnnotationTextStyle = CPTMutableTextStyle()
        hitAnnotationTextStyle.color    = CPTColor.whiteColor()
        hitAnnotationTextStyle.fontSize = 16.0
        hitAnnotationTextStyle.fontName = "Helvetica-Bold"

        // Determine point of symbol in plot coordinates
        let dataPoint: [String: Double] = plotData[Int(index)]

        let x = dataPoint["x"]!
        let y = dataPoint["y"]!

        let anchorPoint = [x, y]

        // Add annotation
        // First make a string for the y value
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let yString = formatter.stringFromNumber(y)

        // Now add the annotation to the plot area
        if let defaultSpace = graph.defaultPlotSpace {
            let textLayer = CPTTextLayer(text: yString, style: hitAnnotationTextStyle)
            let annotation = CPTPlotSpaceAnnotation(plotSpace: defaultSpace, anchorPlotPoint: anchorPoint)
            annotation.contentLayer   = textLayer
            annotation.displacement   = CGPoint(x: 0.0, y: 20.0)
            self.symbolTextAnnotation = annotation
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

// MARK: - Plot area delegate method

extension SimpleScatterPlot: CPTPlotAreaDelegate {

    func plotAreaWasSelected(plotArea: CPTPlotArea) {
        let graph = self.graphs[0] as? CPTXYGraph

        if graph != nil {
            // Remove the annotation
            if let annotation = self.symbolTextAnnotation {
                graph?.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
                self.symbolTextAnnotation = nil
            } else {
                var interpolation: CPTScatterPlotInterpolation = .Histogram

                // Decrease the histogram display option, and if < 0 display linear graph
                let optionValue = self.histogramOption.rawValue
                if ( CPTScatterPlotHistogramOption(rawValue: optionValue - 1) == nil ) {
                    interpolation = .Linear

                    // Set the histogram option to the count, as that is guaranteed to be the last available option + 1
                    // (thus the next time the user clicks in the empty plot area the value will be decremented, becoming last option)
                    self.histogramOption = .OptionCount
                }
                let dataSourceLinePlot = graph?.plotWithIdentifier("Data Source Plot") as! CPTScatterPlot
                dataSourceLinePlot.interpolation   = interpolation
                dataSourceLinePlot.histogramOption = self.histogramOption
            }
        }
    }
    
}
