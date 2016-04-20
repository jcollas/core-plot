//
// LineCapDemo.m
// Plot Gallery
//

import CorePlot

class LineCapDemo: PlotItem {

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        
        title = "Line Caps"
        section = kDemoPlots
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {
        
        #if os(iOS) || os(tvOS)
            let bounds = hostingView.bounds
        #else
            let bounds = NSRectToCGRect(hostingView.bounds)
        #endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTSlateTheme))

        graph.fill = CPTFill(color: CPTColor.darkGrayColor())

        // Plot area
        graph.plotAreaFrame?.paddingTop    = self.titleSize
        graph.plotAreaFrame?.paddingBottom = self.titleSize
        graph.plotAreaFrame?.paddingLeft   = self.titleSize
        graph.plotAreaFrame?.paddingRight  = self.titleSize
        graph.plotAreaFrame?.masksToBorder = false

        // Setup plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: 100.0)
        plotSpace.yRange = CPTPlotRange(location: 5.5, length: -6.0)

        // Line styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 3.0

        // Line cap
        let lineCap = CPTLineCap()
        lineCap.size      = CGSize(width: 15.0, height: 15.0)
        lineCap.lineStyle = axisLineStyle
        lineCap.fill      = CPTFill(color: CPTColor.blueColor())

        // Axes
        var axes: [CPTAxis] = []
        let maxCapType = CPTLineCapType.Custom.rawValue
        var lineCapType = 0

        while ( lineCapType < maxCapType ) {
            let axis = CPTXYAxis()
            axis.plotSpace          = graph.defaultPlotSpace
            axis.labelingPolicy     = .None
            axis.orthogonalPosition = lineCapType / 2
            axis.axisLineStyle      = axisLineStyle

            lineCap.lineCapType = CPTLineCapType(rawValue: lineCapType)!
            axis.axisLineCapMin = lineCap
            lineCapType += 1

            lineCap.lineCapType = CPTLineCapType(rawValue: lineCapType)!
            axis.axisLineCapMax = lineCap
            lineCapType += 1

            axes.append(axis)
        }
        
        // Add axes to the graph
        graph.axisSet?.axes = axes
    }

}
