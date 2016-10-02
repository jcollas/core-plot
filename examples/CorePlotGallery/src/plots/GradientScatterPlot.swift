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

    override func renderInGraphHostingView(_ hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: CPTThemeName.slateTheme))

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
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.1)

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
            y.labelingPolicy              = .automatic
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
        dataSourceLinePlot.identifier = "Data Source Plot" as (NSCoding & NSCopying & NSObjectProtocol)?

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth = 5.0
        lineStyle.lineJoin = .round
        lineStyle.lineGradient = CPTGradient(beginning: CPTColor.green(), ending: CPTColor.white())
        dataSourceLinePlot.dataLineStyle = lineStyle
        dataSourceLinePlot.dataSource = self
        graph.add(dataSourceLinePlot)

        // Put an area gradient under the plot above
        let areaColor = CPTColor(componentRed: 0.3, green: 1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginning: areaColor, ending: CPTColor.clear())
        areaGradient.angle = -90.0
        let areaGradientFill = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 0.0

        // Add some fill bands
        let band1Color = CPTColor(componentRed: 0.3, green: 0.3, blue:1.0, alpha: 0.8)
        let band1Gradient = CPTGradient(beginning: band1Color,  ending: CPTColor.clear())
        band1Gradient.angle = -90.0
        let band1Fill = CPTFill(gradient: band1Gradient)
        dataSourceLinePlot.addAreaFill(CPTLimitBand(range: CPTPlotRange(location:1.05, length:0.15), fill: band1Fill))

        let band2Color = CPTColor(componentRed: 1.0, green: 0.3, blue: 0.3, alpha: 0.8)
        let band2Gradient = CPTGradient(beginning: band2Color, ending: CPTColor.clear())
        band2Gradient.angle = -90.0
        let band2Fill = CPTFill(gradient: band2Gradient)
        dataSourceLinePlot.addAreaFill(CPTLimitBand(range: CPTPlotRange(location:1.3, length:0.1), fill: band2Fill))

        // Auto scale the plot space to fit the plot data
        // Extend the ranges by 30% for neatness
        plotSpace.scale(toFit: [dataSourceLinePlot])
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange

        // Restrict y range to a global range
        let globalYRange = CPTPlotRange(location:0.0, length:2.0)
        plotSpace.globalYRange = globalYRange

        // Add plot symbols
        let symbolGradient = CPTGradient(beginning: CPTColor(componentRed:0.75, green:0.75, blue:1.0, alpha:1.0), ending: CPTColor.blue())
        symbolGradient.gradientType = .radial
        symbolGradient.startAnchor  = CGPoint(x: 0.25, y: 0.75)
        
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill = CPTFill(gradient: symbolGradient)
        plotSymbol.lineStyle = nil
        plotSymbol.size = CGSize(width: 12.0, height: 12.0)
        dataSourceLinePlot.plotSymbol = plotSymbol
        
        // Set plot delegate, to know when symbols have been touched
        // We will display an annotation when a symbol is touched
        dataSourceLinePlot.delegate = self
        dataSourceLinePlot.plotSymbolMarginForHitDetection = 5.0
    }

}

//MARK: - Plot Data Source Methods

extension GradientScatterPlot: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {

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

    func plotSpace(_ space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, for coordinate: CPTCoordinate) -> CPTPlotRange? {
        // Impose a limit on how far user can scroll in x
        if ( coordinate == .X ) {
            let maxRange = CPTPlotRange(location: -1.0, length:6.0)
            let changedRange = newRange.mutableCopy() as! CPTMutablePlotRange
            changedRange.shiftEndToFit(in: maxRange)
            changedRange.shiftLocationToFit(in: maxRange)
            return changedRange
        }
        
        return newRange
    }

}

//MARK: - CPTScatterPlot delegate method

extension GradientScatterPlot: CPTScatterPlotDelegate {

    func scatterPlot(_ plot: CPTScatterPlot, plotSymbolWasSelectedAtRecord index: UInt) {
        let graph = graphs[0] 

        var annotation = self.symbolTextAnnotation

        if annotation != nil {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }

        // Setup a style for the annotation
        let hitAnnotationTextStyle = CPTMutableTextStyle()
        hitAnnotationTextStyle.color    = CPTColor.white()
        hitAnnotationTextStyle.fontSize = 16.0
        hitAnnotationTextStyle.fontName = "Helvetica-Bold"

        // Determine point of symbol in plot coordinates
        let dataPoint = self.plotData[Int(index)]

        let x = dataPoint["x"]!
        let y = dataPoint["y"]!

        let anchorPoint: [Double] = [x, y]

        // Add annotation
        // First make a string for the y value
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let yString = formatter.string(from: NSNumber(value: y))

        // Now add the annotation to the plot area
        if let defaultSpace = graph.defaultPlotSpace {
            let textLayer = CPTTextLayer(text:yString, style: hitAnnotationTextStyle)
            annotation = CPTPlotSpaceAnnotation(plotSpace: defaultSpace,anchorPlotPoint:anchorPoint as [NSNumber]?)
            annotation?.contentLayer   = textLayer
            annotation?.displacement   = CGPoint(x: 0.0, y: 20.0)
            self.symbolTextAnnotation = annotation
            graph.plotAreaFrame?.plotArea?.addAnnotation(annotation)
        }
    }

}

//MARK: - Plot area delegate method

extension GradientScatterPlot: CPTPlotAreaDelegate {

    func plotAreaWasSelected(_ plotArea: CPTPlotArea) {
        // Remove the annotation
        if let annotation = self.symbolTextAnnotation {
            let graph = graphs[0] as! CPTXYGraph

            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }
    }

}
