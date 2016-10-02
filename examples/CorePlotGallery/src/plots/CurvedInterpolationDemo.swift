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

    override func renderInGraphHostingView(_ hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: CPTThemeName.darkGradientTheme))

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
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.1)

        let redLineStyle = CPTMutableLineStyle()
        redLineStyle.lineWidth = 10.0
        redLineStyle.lineColor = CPTColor.red().withAlphaComponent(0.5)

        let lineCap = CPTLineCap.sweptArrowPlot()
        lineCap.size = CGSize(width: self.titleSize * 0.625, height: self.titleSize * 0.625)

        // Axes
        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let x = axisSet.xAxis, let y = axisSet.yAxis else {
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
        y.labelingPolicy              = .automatic
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
        bezierPlot.identifier = bezierCurveIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        // Catmull-Rom
        let cmUniformPlot = CPTScatterPlot(frame: CGRect.zero)
        cmUniformPlot.identifier = catmullRomUniformIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        let cmCentripetalPlot = CPTScatterPlot(frame: CGRect.zero)
        cmCentripetalPlot.identifier = catmullRomCentripetalIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        let cmChordalPlot = CPTScatterPlot(frame: CGRect.zero)
        cmChordalPlot.identifier = catmullRomChordalIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        // Hermite Cubic
        let hermitePlot = CPTScatterPlot(frame: CGRect.zero)
        hermitePlot.identifier = hermiteCubicIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?

        // set interpolation types
        bezierPlot.interpolation = .curved
        cmUniformPlot.interpolation = .curved
        cmCentripetalPlot.interpolation = .curved
        cmChordalPlot.interpolation = .curved
        hermitePlot.interpolation = .curved

        bezierPlot.curvedInterpolationOption        = .normal
        cmUniformPlot.curvedInterpolationOption     = .catmullRomUniform
        cmChordalPlot.curvedInterpolationOption     = .catmullRomChordal
        cmCentripetalPlot.curvedInterpolationOption = .catmullRomCentripetal
        hermitePlot.curvedInterpolationOption       = .hermiteCubic

        // style plots
        let lineStyle = bezierPlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth = 2.0
        lineStyle.lineColor = .green()

        bezierPlot.dataLineStyle = lineStyle

        lineStyle.lineColor         = .red()
        cmUniformPlot.dataLineStyle = lineStyle

        lineStyle.lineColor             = .orange()
        cmCentripetalPlot.dataLineStyle = lineStyle

        lineStyle.lineColor         = .yellow()
        cmChordalPlot.dataLineStyle = lineStyle

        lineStyle.lineColor       = .cyan()
        hermitePlot.dataLineStyle = lineStyle

        // set data source and add plots
        bezierPlot.dataSource = self
        cmUniformPlot.dataSource = self
        cmCentripetalPlot.dataSource = self
        cmChordalPlot.dataSource = self
        hermitePlot.dataSource = self

        graph.add(bezierPlot)
        graph.add(cmUniformPlot)
        graph.add(cmCentripetalPlot)
        graph.add(cmChordalPlot)
        graph.add(hermitePlot)

        // Auto scale the plot space to fit the plot data
        plotSpace.scale(toFit: graph.allPlots())
        let xRange = plotSpace.xRange.mutableCopy() as! CPTMutablePlotRange
        let yRange = plotSpace.yRange.mutableCopy() as! CPTMutablePlotRange

        // Expand the ranges to put some space around the plot
        xRange.expand(byFactor: 1.2)
        yRange.expand(byFactor: 1.2)
        plotSpace.xRange = xRange
        plotSpace.yRange = yRange

        xRange.expand(byFactor: 1.025)
        xRange.location = plotSpace.xRange.location
        yRange.expand(byFactor: 1.05)
        x.visibleAxisRange = xRange
        y.visibleAxisRange = yRange

        xRange.expand(byFactor: 3.0)
        yRange.expand(byFactor: 3.0)
        plotSpace.globalXRange = xRange
        plotSpace.globalYRange = yRange

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.black().withAlphaComponent(0.5)
        let plotSymbol = CPTPlotSymbol.ellipse()
        plotSymbol.fill       = CPTFill(color: CPTColor.blue().withAlphaComponent(0.5))
        plotSymbol.lineStyle  = symbolLineStyle
        plotSymbol.size       = CGSize(width: 5.0, height: 5.0)
        bezierPlot.plotSymbol = plotSymbol
        cmUniformPlot.plotSymbol = plotSymbol
        cmCentripetalPlot.plotSymbol = plotSymbol
        cmChordalPlot.plotSymbol = plotSymbol
        hermitePlot.plotSymbol = plotSymbol
        
        // Add legend
        graph.legend                 = CPTLegend(graph: graph)
        graph.legend?.numberOfRows    = 2
        graph.legend?.textStyle       = x.titleTextStyle
        graph.legend?.fill            = CPTFill(color: .darkGray())
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius    = 5.0
        graph.legendAnchor           = .bottom
        graph.legendDisplacement     = CGPoint(x: 0.0, y: self.titleSize * 2.0)
    }

}

//MARK: - Plot Data Source Methods

extension CurvedInterpolationDemo: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {
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

    func plotSpace(_ space: CPTPlotSpace, willChangePlotRangeTo newRange: CPTPlotRange, for coordinate: CPTCoordinate) -> CPTPlotRange? {
        let theGraph = space.graph!
        let axisSet = theGraph.axisSet as! CPTXYAxisSet

        let changedRange = newRange.mutableCopy() as! CPTMutablePlotRange

        switch ( coordinate ) {
            case .X:
                changedRange.expand(byFactor: 1.025)
                changedRange.location = newRange.location
                axisSet.xAxis?.visibleAxisRange = changedRange

            case .Y:
                changedRange.expand(byFactor: 1.05)
                axisSet.yAxis?.visibleAxisRange = changedRange

            default:
                break
        }
        
        return newRange
    }

}
