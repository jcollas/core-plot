//
// AxisDemo.m
// Plot Gallery-Mac
//

import CorePlot

class AxisDemo: PlotItem {

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Axis Demo"
        section = kDemoPlots
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
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: .slateTheme))

        graph.fill = CPTFill(color: CPTColor.darkGray())

        // Plot area
        graph.plotAreaFrame?.fill          = CPTFill(color: CPTColor.lightGray())
        graph.plotAreaFrame?.paddingTop    = self.titleSize
        graph.plotAreaFrame?.paddingBottom = self.titleSize * 2.0
        graph.plotAreaFrame?.paddingLeft   = self.titleSize * 2.0
        graph.plotAreaFrame?.paddingRight  = self.titleSize * 2.0
        graph.plotAreaFrame?.cornerRadius  = 10.0
        graph.plotAreaFrame?.masksToBorder = false

        graph.plotAreaFrame?.axisSet?.borderLineStyle = CPTLineStyle()

        graph.plotAreaFrame?.plotArea?.fill = CPTFill(color: .white())

        // Setup plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: -10.0)
        plotSpace.yRange = CPTPlotRange(location: 0.5, length: 10.0)

        // Line styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 3.0
        axisLineStyle.lineCap   = .round

        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = .red()

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = .blue()

        // Text styles
        let axisTitleTextStyle = CPTMutableTextStyle()
        axisTitleTextStyle.fontName = "Helvetica-Bold"

        // Axes
        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let x = axisSet.xAxis else {
            return
        }

        x.separateLayers        = false
        x.orthogonalPosition    = 0.5
        x.majorIntervalLength   = 0.5
        x.minorTicksPerInterval = 4
        x.tickDirection         = .none
        x.axisLineStyle         = axisLineStyle
        x.majorTickLength       = 12.0
        x.majorTickLineStyle    = axisLineStyle
        x.majorGridLineStyle    = majorGridLineStyle
        x.minorTickLength       = 8.0
        x.minorGridLineStyle    = minorGridLineStyle
        x.title                 = "X Axis"
        x.titleTextStyle        = axisTitleTextStyle
        x.titleOffset           = self.titleSize

        let redAlpha = CPTColor.red().withAlphaComponent(0.1)
        let greenAlpha = CPTColor.green().withAlphaComponent(0.1)
        let blueAlpha = CPTColor.blue().withAlphaComponent(0.1)

        x.alternatingBandFills  = [CPTFill(color: redAlpha), CPTFill(color: greenAlpha)]
        x.delegate              = self

        // Label y with an automatic labeling policy.
        axisLineStyle.lineColor = CPTColor.green()

        guard let y = axisSet.yAxis else {
            return
        }
        y.labelingPolicy        = .automatic
        y.separateLayers        = true
        y.minorTicksPerInterval = 9
        y.tickDirection         = .negative
        y.axisLineStyle         = axisLineStyle
        y.majorTickLength       = 6.0
        y.majorTickLineStyle    = axisLineStyle
        y.majorGridLineStyle    = majorGridLineStyle
        y.minorTickLength       = 4.0
        y.minorGridLineStyle    = minorGridLineStyle
        y.title                 = "Y Axis"
        y.titleTextStyle        = axisTitleTextStyle
        y.titleOffset           = self.titleSize * 1.1
        y.alternatingBandFills  = [CPTFill(color: blueAlpha)]  // TODO
        y.delegate              = self

        let bandFill = CPTFill(color: CPTColor.darkGray().withAlphaComponent(0.5))
        y.addBackgroundLimitBand(CPTLimitBand(range: CPTPlotRange(location: 7.0, length: 1.5), fill:bandFill))
        y.addBackgroundLimitBand(CPTLimitBand(range: CPTPlotRange(location: 1.5, length: 3.0), fill:bandFill))

        // Label y2 with an equal division labeling policy.
        axisLineStyle.lineColor = CPTColor.orange()

        let y2 = CPTXYAxis()
        y2.coordinate                  = .Y
        y2.plotSpace                   = plotSpace
        y2.orthogonalPosition          = -10.0
        y2.labelingPolicy              = .equalDivisions
        y2.separateLayers              = false
        y2.preferredNumberOfMajorTicks = 6
        y2.minorTicksPerInterval       = 9
        y2.tickDirection               = .none
        y2.tickLabelDirection          = .positive
        y2.labelTextStyle              = y.labelTextStyle
        y2.axisLineStyle               = axisLineStyle
        y2.majorTickLength             = 12.0
        y2.majorTickLineStyle          = axisLineStyle
        y2.minorTickLength             = 8.0
        y2.title                       = "Y2 Axis"
        y2.titleTextStyle              = axisTitleTextStyle
        y2.titleOffset                 = self.titleSize * -2.1
        y2.delegate                    = self

        // Add the y2 axis to the axis set
        graph.axisSet?.axes = [x, y, y2]
    }
    
}

// MARK: - Axis delegate

extension AxisDemo: CPTAxisDelegate {

    func axis(_ axis: CPTAxis, labelWasSelected label: CPTAxisLabel) {
        NSLog("\(axis.title) label was selected at location \(label.tickLocation)")
    }
    
}
