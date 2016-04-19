//
// CurvedInterpolationDemo.m
// Plot_Gallery
//
// Created by malte on 16/03/16.
//
//

import CorePlot

class CurvedInterpolationDemo: PlotItem {

let bezierYShift                = -1.0
let catmullRomUniformPlotYShift = 0.0
let catmullRomCentripetalYShift = 1.0
let catmullRomChordalYShift     = 2.0
let hermiteCubicYShift          = -2.0

let bezierCurveIdentifier           = "Bezier"
let catmullRomUniformIdentifier     = "Catmull-Rom Uniform"
let catmullRomCentripetalIdentifier = "Catmull-Rom Centripetal"
let catmullRomChordalIdentifier     = "Catmull-Rom Chordal"
let hermiteCubicIdentifier          = "Hermite Cubic"

    var plotData: [[String: Double]] = []

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Curved Interpolation Options Demo"
        section = kLinePlots
    }

    override func generateData() {

        if plotData.isEmpty {
            let xValues = [0.0, 0.1, 0.2, 0.5, 0.6, 0.7, 1]
            let yValues = [0.5, 0.5, -1, 1, 1, 0, 0.1]

            assert(xValues.count == yValues.count, "Invalid const data")

            var generatedData: [[String: Double]] = []
            for i in 0..<xValues.count {
                let x = xValues[i]
                let y = yValues[i]

                generatedData.append([
                                      "x": x,
                                      "y": y
                                      ])
            }

            self.plotData = generatedData
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
        x.axisConstraints       = CPTConstraints(relativeOffset: 0.5)

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

        // Create the plots
        // Bezier
        let bezierPlot = CPTScatterPlot(frame: CGRect.zero)
        bezierPlot.identifier = bezierCurveIdentifier
        // Catmull-Rom
        let cmUniformPlot = CPTScatterPlot(frame: CGRect.zero)
        cmUniformPlot.identifier = catmullRomUniformIdentifier
        let cmCentripetalPlot = CPTScatterPlot(frame: CGRect.zero)
        cmCentripetalPlot.identifier = catmullRomCentripetalIdentifier
        let cmChordalPlot = CPTScatterPlot(frame: CGRect.zero)
        cmChordalPlot.identifier = catmullRomChordalIdentifier
        // Hermite Cubic
        let hermitePlot = CPTScatterPlot(frame: CGRect.zero)
        hermitePlot.identifier = hermiteCubicIdentifier

        // set interpolation types
        bezierPlot.interpolation = .Curved
        cmUniformPlot.interpolation = .Curved
        cmCentripetalPlot.interpolation = .Curved
        cmChordalPlot.interpolation = .Curved
        hermitePlot.interpolation = .Curved

        bezierPlot.curvedInterpolationOption        = .Normal
        cmUniformPlot.curvedInterpolationOption     = .CatmullRomUniform
        cmChordalPlot.curvedInterpolationOption     = .CatmullRomChordal
        cmCentripetalPlot.curvedInterpolationOption = .CatmullRomCentripetal
        hermitePlot.curvedInterpolationOption       = .HermiteCubic

        // style plots
        let lineStyle = bezierPlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth = 2.0
        lineStyle.lineColor = CPTColor.greenColor()

        bezierPlot.dataLineStyle = lineStyle

        lineStyle.lineColor         = CPTColor.redColor()
        cmUniformPlot.dataLineStyle = lineStyle

        lineStyle.lineColor             = CPTColor.orangeColor()
        cmCentripetalPlot.dataLineStyle = lineStyle

        lineStyle.lineColor         = CPTColor.yellowColor()
        cmChordalPlot.dataLineStyle = lineStyle

        lineStyle.lineColor       = CPTColor.cyanColor()
        hermitePlot.dataLineStyle = lineStyle

        // set data source and add plots
        bezierPlot.dataSource = self
        cmUniformPlot.dataSource = self
        cmCentripetalPlot.dataSource = self
        cmChordalPlot.dataSource = self
        hermitePlot.dataSource = self

        graph.addPlot(bezierPlot)
        graph.addPlot(cmUniformPlot)
        graph.addPlot(cmCentripetalPlot)
        graph.addPlot(cmChordalPlot)
        graph.addPlot(hermitePlot)

        // Auto scale the plot space to fit the plot data
        plotSpace.scaleToFitPlots(graph.allPlots())
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange

        // Expand the ranges to put some space around the plot
        xRange.expandRangeByFactor(1.2)
        yRange.expandRangeByFactor(1.2)
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange

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
        plotSymbol.fill       = CPTFill(color: CPTColor.blueColor().colorWithAlphaComponent(0.5))
        plotSymbol.lineStyle  = symbolLineStyle
        plotSymbol.size       = CGSizeMake(5.0, 5.0)
        bezierPlot.plotSymbol = plotSymbol
        cmUniformPlot.plotSymbol = plotSymbol
        cmCentripetalPlot.plotSymbol = plotSymbol
        cmChordalPlot.plotSymbol = plotSymbol
        hermitePlot.plotSymbol = plotSymbol
        
        // Add legend
        graph.legend                 = CPTLegend(graph: graph)
        graph.legend?.numberOfRows    = 2
        graph.legend?.textStyle       = x.titleTextStyle
        graph.legend?.fill            = CPTFill(color: CPTColor.darkGrayColor())
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius    = 5.0
        graph.legendAnchor           = .Bottom
        graph.legendDisplacement     = CGPointMake( 0.0, self.titleSize * 2.0 )
    }

}

//MARK: - Plot Data Source Methods

extension CurvedInterpolationDemo: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
        let identifier = plot.identifier as! String

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return nil
        }

        if ( field == .X ) {
            return plotData[Int(index)]["x"]
        }

        let baseY = self.plotData[Int(index)]["y"]!
        var shift    = 0.0
        if identifier == catmullRomUniformIdentifier {
            shift = catmullRomUniformPlotYShift
        }
        else if identifier == catmullRomCentripetalIdentifier {
            shift = catmullRomCentripetalYShift
        }
        else if identifier == catmullRomChordalIdentifier {
            shift = catmullRomChordalYShift
        }
        else if identifier == hermiteCubicIdentifier {
            shift = hermiteCubicYShift
        }
        else if identifier == bezierCurveIdentifier {
            shift = bezierYShift
        }
        return baseY + shift
    }

}

//MARK: - Plot Space Delegate Methods

extension CurvedInterpolationDemo: CPTPlotSpaceDelegate {

    func plotSpace(space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, forCoordinate coordinate: CPTCoordinate) -> CPTPlotRange? {
        let theGraph = space.graph!
        let axisSet = theGraph.axisSet as! CPTXYAxisSet

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