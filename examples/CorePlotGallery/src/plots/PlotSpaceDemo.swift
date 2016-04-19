//
// PlotSpaceDemo.m
// Plot Gallery
//

import CorePlot

class PlotSpaceDemo: PlotItem {

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Plot Space Demo"
        section = kDemoPlots
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {
        let majorTickLength: CGFloat = 12.0
        let minorTickLength: CGFloat = 8.0
        let titleOffset: CGFloat = self.titleSize

        #if os(iOS)
            let bounds = hostingView.bounds
        #else
            let bounds = NSRectToCGRect(hostingView.bounds)
        #endif

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        graph.fill = CPTFill(color: CPTColor.darkGrayColor())

        // Plot area
        graph.plotAreaFrame?.paddingTop    = self.titleSize
        graph.plotAreaFrame?.paddingBottom = self.titleSize
        graph.plotAreaFrame?.paddingLeft   = self.titleSize
        graph.plotAreaFrame?.paddingRight  = self.titleSize
        graph.plotAreaFrame?.masksToBorder = false

        // Line styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 3.0

        let majorTickLineStyle = axisLineStyle.mutableCopy() as! CPTMutableLineStyle
        majorTickLineStyle.lineWidth = 3.0
        majorTickLineStyle.lineCap   = .Round

        let minorTickLineStyle = axisLineStyle.mutableCopy() as! CPTMutableLineStyle
        minorTickLineStyle.lineWidth = 2.0
        minorTickLineStyle.lineCap   = .Round

        // Text styles
        let axisTitleTextStyle = CPTMutableTextStyle()
        axisTitleTextStyle.fontName = "Helvetica-Bold"

        // Plot Spaces
        let linearPlotSpace = CPTXYPlotSpace()
        linearPlotSpace.xRange = CPTPlotRange(location: 0.0, length: 100.0)
        linearPlotSpace.yRange = CPTPlotRange(location: 6.5, length: -6.0)

        let negativeLinearPlotSpace = CPTXYPlotSpace()
        negativeLinearPlotSpace.xRange = CPTPlotRange(location: 100.0, length: -100.0)
        negativeLinearPlotSpace.yRange = linearPlotSpace.yRange

        let logPlotSpace = CPTXYPlotSpace()
        logPlotSpace.xScaleType = .Log
        logPlotSpace.xRange     = CPTPlotRange(location: 0.1, length: 99.9)
        logPlotSpace.yRange     = linearPlotSpace.yRange

        let negativeLogPlotSpace = CPTXYPlotSpace()
        negativeLogPlotSpace.xScaleType = .Log
        negativeLogPlotSpace.xRange     = CPTPlotRange(location: 100.0, length: -99.9)
        negativeLogPlotSpace.yRange     = linearPlotSpace.yRange

        let logModulusPlotSpace = CPTXYPlotSpace()
        logModulusPlotSpace.xScaleType = .LogModulus
        logModulusPlotSpace.xRange     = CPTPlotRange(location: -100.0, length: 1100.0)
        logModulusPlotSpace.yRange     = linearPlotSpace.yRange

        let negativeLogModulusPlotSpace = CPTXYPlotSpace()
        negativeLogModulusPlotSpace.xScaleType = .LogModulus
        negativeLogModulusPlotSpace.xRange     = CPTPlotRange(location: 0.1, length: -0.2)
        negativeLogModulusPlotSpace.yRange     = linearPlotSpace.yRange

        graph.removePlotSpace(graph.defaultPlotSpace)
        graph.addPlotSpace(linearPlotSpace)
        graph.addPlotSpace(negativeLinearPlotSpace)
        graph.addPlotSpace(logPlotSpace)
        graph.addPlotSpace(negativeLogPlotSpace)
        graph.addPlotSpace(logModulusPlotSpace)
        graph.addPlotSpace(negativeLogModulusPlotSpace)

        // Axes
        // Linear axis--positive direction
        let linearAxis = CPTXYAxis()
        linearAxis.plotSpace             = linearPlotSpace
        linearAxis.labelingPolicy        = .Automatic
        linearAxis.orthogonalPosition    = 1.0
        linearAxis.minorTicksPerInterval = 9
        linearAxis.tickDirection         = .None
        linearAxis.axisLineStyle         = axisLineStyle
        linearAxis.majorTickLength       = majorTickLength
        linearAxis.majorTickLineStyle    = majorTickLineStyle
        linearAxis.minorTickLength       = minorTickLength
        linearAxis.minorTickLineStyle    = minorTickLineStyle
        linearAxis.title                 = "Linear Plot Space—Positive Length"
        linearAxis.titleTextStyle        = axisTitleTextStyle
        linearAxis.titleOffset           = titleOffset

        // Linear axis--negative direction
        let negativeLinearAxis = CPTXYAxis()
        negativeLinearAxis.plotSpace             = negativeLinearPlotSpace
        negativeLinearAxis.labelingPolicy        = .Automatic
        negativeLinearAxis.orthogonalPosition    = 2.0
        negativeLinearAxis.minorTicksPerInterval = 4
        negativeLinearAxis.tickDirection         = .None
        negativeLinearAxis.axisLineStyle         = axisLineStyle
        negativeLinearAxis.majorTickLength       = majorTickLength
        negativeLinearAxis.majorTickLineStyle    = majorTickLineStyle
        negativeLinearAxis.minorTickLength       = minorTickLength
        negativeLinearAxis.minorTickLineStyle    = minorTickLineStyle
        negativeLinearAxis.title                 = "Linear Plot Space—Negative Length"
        negativeLinearAxis.titleTextStyle        = axisTitleTextStyle
        negativeLinearAxis.titleOffset           = titleOffset

        // Log axis--positive direction
        let logAxis = CPTXYAxis()
        logAxis.plotSpace             = logPlotSpace
        logAxis.labelingPolicy        = .Automatic
        logAxis.orthogonalPosition    = 3.0
        logAxis.minorTicksPerInterval = 8
        logAxis.tickDirection         = .None
        logAxis.axisLineStyle         = axisLineStyle
        logAxis.majorTickLength       = majorTickLength
        logAxis.majorTickLineStyle    = majorTickLineStyle
        logAxis.minorTickLength       = minorTickLength
        logAxis.minorTickLineStyle    = minorTickLineStyle
        logAxis.title                 = "Log Plot Space—Positive Length"
        logAxis.titleTextStyle        = axisTitleTextStyle
        logAxis.titleOffset           = titleOffset

        // Log axis--negative direction
        let negativeLogAxis = CPTXYAxis()
        negativeLogAxis.plotSpace             = negativeLogPlotSpace
        negativeLogAxis.labelingPolicy        = .Automatic
        negativeLogAxis.orthogonalPosition    = 4.0
        negativeLogAxis.minorTicksPerInterval = 4
        negativeLogAxis.tickDirection         = .None
        negativeLogAxis.axisLineStyle         = axisLineStyle
        negativeLogAxis.majorTickLength       = majorTickLength
        negativeLogAxis.majorTickLineStyle    = majorTickLineStyle
        negativeLogAxis.minorTickLength       = minorTickLength
        negativeLogAxis.minorTickLineStyle    = minorTickLineStyle
        negativeLogAxis.title                 = "Log Plot Space—Negative Length"
        negativeLogAxis.titleTextStyle        = axisTitleTextStyle
        negativeLogAxis.titleOffset           = titleOffset

        // Log modulus axis--positive direction
        let logModulusAxis = CPTXYAxis()
        logModulusAxis.plotSpace             = logModulusPlotSpace
        logModulusAxis.labelingPolicy        = .Automatic
        logModulusAxis.orthogonalPosition    = 5.0
        logModulusAxis.minorTicksPerInterval = 8
        logModulusAxis.tickDirection         = .None
        logModulusAxis.axisLineStyle         = axisLineStyle
        logModulusAxis.majorTickLength       = majorTickLength
        logModulusAxis.majorTickLineStyle    = majorTickLineStyle
        logModulusAxis.minorTickLength       = minorTickLength
        logModulusAxis.minorTickLineStyle    = minorTickLineStyle
        logModulusAxis.title                 = "Log Modulus Plot Space—Positive Length"
        logModulusAxis.titleTextStyle        = axisTitleTextStyle
        logModulusAxis.titleOffset           = titleOffset

        // Log modulus axis--negative direction
        let negativeLogModulusAxis = CPTXYAxis()
        negativeLogModulusAxis.plotSpace             = negativeLogModulusPlotSpace
        negativeLogModulusAxis.labelingPolicy        = .Automatic
        negativeLogModulusAxis.orthogonalPosition    = 6.0
        negativeLogModulusAxis.minorTicksPerInterval = 4
        negativeLogModulusAxis.tickDirection         = .None
        negativeLogModulusAxis.axisLineStyle         = axisLineStyle
        negativeLogModulusAxis.majorTickLength       = majorTickLength
        negativeLogModulusAxis.majorTickLineStyle    = majorTickLineStyle
        negativeLogModulusAxis.minorTickLength       = minorTickLength
        negativeLogModulusAxis.minorTickLineStyle    = minorTickLineStyle
        negativeLogModulusAxis.title                 = "Log Modulus Plot Space—Negative Length"
        negativeLogModulusAxis.titleTextStyle        = axisTitleTextStyle
        negativeLogModulusAxis.titleOffset           = titleOffset
        
        // Add axes to the graph
        graph.axisSet?.axes = [linearAxis, negativeLinearAxis, logAxis, negativeLogAxis, logModulusAxis, negativeLogModulusAxis]
    }
    
}
