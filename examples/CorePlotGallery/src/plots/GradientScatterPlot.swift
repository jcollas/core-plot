//
// GradientScatterPlot.m
// CorePlotGallery
//

import CorePlot

class GradientScatterPlot: PlotItem {

    var symbolTextAnnotation: CPTPlotSpaceAnnotation? = nil
    var plotData: [[String: Double]] = []

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Gradient Scatter Plot"
        section = kLinePlots
    }

    override func killGraph() {

        if ( graphs.count != 0 ) {
            let graph = graphs[0] as! CPTXYGraph

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

            for i in 0..<10 {
                let x = 1.0 + Double(i) * 0.05
                let y = 1.2 * Double(arc4random()) / Double(UInt32.max) + 0.5
                contentArray.append([ "x": x, "y": y ])
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
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTSlateTheme))

        // Plot area delegate
        graph.plotAreaFrame?.plotArea?.delegate = self

        // Setup scatter plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.allowsMomentum        = true
        plotSpace.delegate              = self

        // Grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.whiteColor().colorWithAlphaComponent(0.1)

        // Axes
        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 0.5
            x.orthogonalPosition    = 1.0
            x.minorTicksPerInterval = 2
            x.majorGridLineStyle    = majorGridLineStyle
            x.minorGridLineStyle    = minorGridLineStyle

            x.title         = "X Axis"
            x.titleOffset   = 30.0
            x.titleLocation = 1.25
        }

        // Label y with an automatic label policy.
        if let y = axisSet.yAxis {
            y.labelingPolicy              = .Automatic
            y.orthogonalPosition          = 1.0
            y.minorTicksPerInterval       = 2
            y.preferredNumberOfMajorTicks = 8
            y.majorGridLineStyle          = majorGridLineStyle
            y.minorGridLineStyle          = minorGridLineStyle
            y.labelOffset                 = 10.0

            y.title         = "Y Axis"
            y.titleOffset   = 30.0
            y.titleLocation = 1.0
        }

        // Create a plot that uses the data source method
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = "Data Source Plot"

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth = 5.0
        lineStyle.lineJoin = .Round
        lineStyle.lineGradient = CPTGradient(beginningColor: CPTColor.greenColor(), endingColor: CPTColor.whiteColor())
        dataSourceLinePlot.dataLineStyle = lineStyle
        dataSourceLinePlot.dataSource = self
        graph.addPlot(dataSourceLinePlot)

        // Put an area gradient under the plot above
        let areaColor = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginningColor: areaColor, endingColor: CPTColor.clearColor())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 0.0

        // Add some fill bands
        let band1Color = CPTColor(componentRed: 0.3, green: 0.3, blue:1.0, alpha: 0.8)
        let band1Gradient = CPTGradient(beginningColor: band1Color,  endingColor: CPTColor.clearColor())
        band1Gradient.angle = -90.0
        let band1Fill = CPTFill(gradient: band1Gradient)
        dataSourceLinePlot.addAreaFillBand(CPTLimitBand(range: CPTPlotRange(location:1.05, length:0.15), fill: band1Fill))

        let band2Color = CPTColor(componentRed: 1.0, green: 0.3, blue: 0.3, alpha: 0.8)
        let band2Gradient = CPTGradient(beginningColor: band2Color, endingColor: CPTColor.clearColor())
        band2Gradient.angle = -90.0
        let band2Fill = CPTFill(gradient: band2Gradient)
        dataSourceLinePlot.addAreaFillBand(CPTLimitBand(range: CPTPlotRange(location:1.3, length:0.1), fill: band2Fill))

        // Auto scale the plot space to fit the plot data
        // Extend the ranges by 30% for neatness
        plotSpace.scaleToFitPlots([dataSourceLinePlot])
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange

        // Restrict y range to a global range
        let globalYRange = CPTPlotRange(location:0.0, length:2.0)
        plotSpace.globalYRange = globalYRange

        // Add plot symbols
        let symbolGradient = CPTGradient(beginningColor: CPTColor(componentRed:0.75, green:0.75, blue:1.0, alpha:1.0), endingColor: CPTColor.blueColor())
        symbolGradient.gradientType = .Radial
        symbolGradient.startAnchor  = CGPointMake(0.25, 0.75)
        
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill = CPTFill(gradient: symbolGradient)
        plotSymbol.lineStyle = nil
        plotSymbol.size = CGSizeMake(12.0, 12.0)
        dataSourceLinePlot.plotSymbol = plotSymbol
        
        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        dataSourceLinePlot.delegate = self
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0
    }

}

//MARK: - Plot Data Source Methods

extension GradientScatterPlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return nil
        }

        let key = (field == .X ? "x" : "y")
        let num = self.plotData[Int(index)][key]

        if ( field == .Y ) {
//            num = num.doubleValue
        }
        
        return num
    }

}

//MARK: - Plot Space Delegate Methods

extension GradientScatterPlot: CPTPlotSpaceDelegate {

    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        // Impose a limit on how far user can scroll in x
        if ( coordinate == .X ) {
            let maxRange = CPTPlotRange(location: -1.0, length:6.0)
            let changedRange = newRange.mutableCopy() as! CPTMutablePlotRange
            changedRange.shiftEndToFitInRange(maxRange)
            changedRange.shiftLocationToFitInRange(maxRange)
            return changedRange
        }
        
        return newRange
    }

}

//MARK: - CPTScatterPlot delegate method

extension GradientScatterPlot: CPTScatterPlotDelegate {

    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: UInt) {
        let graph = graphs[0] 

        var annotation = self.symbolTextAnnotation

        if annotation != nil {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }

        // Setup a style for the annotation
        let hitAnnotationTextStyle = CPTMutableTextStyle()
        hitAnnotationTextStyle.color    = CPTColor.whiteColor()
        hitAnnotationTextStyle.fontSize = 16.0
        hitAnnotationTextStyle.fontName = "Helvetica-Bold"

        // Determine point of symbol in plot coordinates
        let dataPoint = self.plotData[Int(index)]

        let x = dataPoint["x"]
        let y = dataPoint["y"]

        let anchorPoint: [Double] = [x!, y!]

        // Add annotation
        // First make a string for the y value
        let formatter = NSNumberFormatter()
        formatter.maximumFractionDigits = 2
        let yString = formatter.stringFromNumber(y!)

        // Now add the annotation to the plot area
        if let defaultSpace = graph.defaultPlotSpace {
            let textLayer = CPTTextLayer(text:yString, style: hitAnnotationTextStyle)
            annotation = CPTPlotSpaceAnnotation(plotSpace: defaultSpace,anchorPlotPoint:anchorPoint)
            annotation?.contentLayer   = textLayer
            annotation?.displacement   = CGPointMake(0.0, 20.0)
            self.symbolTextAnnotation = annotation
            graph.plotAreaFrame?.plotArea?.addAnnotation(annotation)
        }
    }

}

//MARK: - Plot area delegate method

extension GradientScatterPlot: CPTPlotAreaDelegate {

    func plotAreaWasSelected(plotArea: CPTPlotArea) {
        // Remove the annotation
        if let annotation = self.symbolTextAnnotation {
            let graph = graphs[0] as! CPTXYGraph

            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }
    }

}
