//
// LabelingPolicyDemo.m
// Plot Gallery
//

import CorePlot

class LabelingPolicyDemo: PlotItem {

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()

        title = "Axis Labeling Policies"
        section = kDemoPlots
    }

    override func renderInGraphHostingView(_ hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

        let majorTickLength: CGFloat = 12.0
        let minorTickLength: CGFloat = 8.0
        let titleOffset: CGFloat     = self.titleSize

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: CPTThemeName.slateTheme))

        graph.fill = CPTFill(color: .darkGray())

        // Plot area
        graph.plotAreaFrame?.paddingTop    = self.titleSize
        graph.plotAreaFrame?.paddingBottom = self.titleSize
        graph.plotAreaFrame?.paddingLeft   = self.titleSize
        graph.plotAreaFrame?.paddingRight  = self.titleSize
        graph.plotAreaFrame?.masksToBorder = false

        // Setup plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: 100.0)
        plotSpace.yRange = CPTPlotRange(location: 5.75, length: -5.0)

        // Line styles
        let axisLineStyle = CPTMutableLineStyle()
        axisLineStyle.lineWidth = 3.0

        let majorTickLineStyle = axisLineStyle.mutableCopy() as! CPTMutableLineStyle
        majorTickLineStyle.lineWidth = 3.0
        majorTickLineStyle.lineCap   = .round

        let minorTickLineStyle = axisLineStyle.mutableCopy() as! CPTMutableLineStyle
        minorTickLineStyle.lineWidth = 2.0
        minorTickLineStyle.lineCap   = .round

        // Text styles
        let axisTitleTextStyle = CPTMutableTextStyle()
        axisTitleTextStyle.fontName = "Helvetica-Bold"

        // Tick locations
        let majorTickLocations: Set<Double> = [0, 30, 50, 85, 100]
        let minorTickLocations: Set<Double> = [0, 10, 20, 30, 40, 50, 60, 70, 80, 90, 100]

        // Axes
        // CPTAxisLabelingPolicyNone
        let axisNone = CPTXYAxis()
        axisNone.plotSpace          = graph.defaultPlotSpace
        axisNone.labelingPolicy     = .none
        axisNone.orthogonalPosition = 1.0
        axisNone.tickDirection      = .none
        axisNone.axisLineStyle      = axisLineStyle
        axisNone.majorTickLength    = majorTickLength
        axisNone.majorTickLineStyle = majorTickLineStyle
        axisNone.minorTickLength    = minorTickLength
        axisNone.minorTickLineStyle = minorTickLineStyle
        axisNone.title              = "CPTAxisLabelingPolicyNone"
        axisNone.titleTextStyle     = axisTitleTextStyle
        axisNone.titleOffset        = titleOffset
        axisNone.majorTickLocations = majorTickLocations as Set<NSNumber>?
        axisNone.minorTickLocations = minorTickLocations as Set<NSNumber>?

        var newAxisLabels: Set<CPTAxisLabel> = []
        for i in 0..<6 {
            let newLabel = CPTAxisLabel(text: "Label \(i)", textStyle: axisNone.labelTextStyle)
            newLabel.tickLocation = NSNumber(value: i * 20)
            newLabel.offset = axisNone.labelOffset + axisNone.majorTickLength / 2.0

            newAxisLabels.insert(newLabel)
        }
        axisNone.axisLabels = newAxisLabels

        // CPTAxisLabelingPolicyLocationsProvided
        let axisLocationsProvided = CPTXYAxis()
        axisLocationsProvided.plotSpace          = graph.defaultPlotSpace
        axisLocationsProvided.labelingPolicy     = .locationsProvided
        axisLocationsProvided.orthogonalPosition = 2.0
        axisLocationsProvided.tickDirection      = .none
        axisLocationsProvided.axisLineStyle      = axisLineStyle
        axisLocationsProvided.majorTickLength    = majorTickLength
        axisLocationsProvided.majorTickLineStyle = majorTickLineStyle
        axisLocationsProvided.minorTickLength    = minorTickLength
        axisLocationsProvided.minorTickLineStyle = minorTickLineStyle
        axisLocationsProvided.title              = "CPTAxisLabelingPolicyLocationsProvided"
        axisLocationsProvided.titleTextStyle     = axisTitleTextStyle
        axisLocationsProvided.titleOffset        = titleOffset
        axisLocationsProvided.majorTickLocations = majorTickLocations as Set<NSNumber>?
        axisLocationsProvided.minorTickLocations = minorTickLocations as Set<NSNumber>?

        // CPTAxisLabelingPolicyFixedInterval
        let axisFixedInterval = CPTXYAxis()
        axisFixedInterval.plotSpace             = graph.defaultPlotSpace
        axisFixedInterval.labelingPolicy        = .fixedInterval
        axisFixedInterval.orthogonalPosition    = 3.0
        axisFixedInterval.majorIntervalLength   = 25.0
        axisFixedInterval.minorTicksPerInterval = 4
        axisFixedInterval.tickDirection         = .none
        axisFixedInterval.axisLineStyle         = axisLineStyle
        axisFixedInterval.majorTickLength       = majorTickLength
        axisFixedInterval.majorTickLineStyle    = majorTickLineStyle
        axisFixedInterval.minorTickLength       = minorTickLength
        axisFixedInterval.minorTickLineStyle    = minorTickLineStyle
        axisFixedInterval.title                 = "CPTAxisLabelingPolicyFixedInterval"
        axisFixedInterval.titleTextStyle        = axisTitleTextStyle
        axisFixedInterval.titleOffset           = titleOffset

        // CPTAxisLabelingPolicyAutomatic
        let axisAutomatic = CPTXYAxis()
        axisAutomatic.plotSpace             = graph.defaultPlotSpace
        axisAutomatic.labelingPolicy        = .automatic
        axisAutomatic.orthogonalPosition    = 4.0
        axisAutomatic.minorTicksPerInterval = 9
        axisAutomatic.tickDirection         = .none
        axisAutomatic.axisLineStyle         = axisLineStyle
        axisAutomatic.majorTickLength       = majorTickLength
        axisAutomatic.majorTickLineStyle    = majorTickLineStyle
        axisAutomatic.minorTickLength       = minorTickLength
        axisAutomatic.minorTickLineStyle    = minorTickLineStyle
        axisAutomatic.title                 = "CPTAxisLabelingPolicyAutomatic"
        axisAutomatic.titleTextStyle        = axisTitleTextStyle
        axisAutomatic.titleOffset           = titleOffset

        // CPTAxisLabelingPolicyEqualDivisions
        let axisEqualDivisions = CPTXYAxis()
        axisEqualDivisions.plotSpace                   = graph.defaultPlotSpace
        axisEqualDivisions.labelingPolicy              = .equalDivisions
        axisEqualDivisions.orthogonalPosition          = 5.0
        axisEqualDivisions.preferredNumberOfMajorTicks = 7
        axisEqualDivisions.minorTicksPerInterval       = 4
        axisEqualDivisions.tickDirection               = .none
        axisEqualDivisions.axisLineStyle               = axisLineStyle
        axisEqualDivisions.majorTickLength             = majorTickLength
        axisEqualDivisions.majorTickLineStyle          = majorTickLineStyle
        axisEqualDivisions.minorTickLength             = minorTickLength
        axisEqualDivisions.minorTickLineStyle          = minorTickLineStyle
        axisEqualDivisions.title                       = "CPTAxisLabelingPolicyEqualDivisions"
        axisEqualDivisions.titleTextStyle              = axisTitleTextStyle
        axisEqualDivisions.titleOffset                 = titleOffset
        
        // Add axes to the graph
        graph.axisSet?.axes = [axisNone, axisLocationsProvided, axisFixedInterval, axisAutomatic, axisEqualDivisions]
    }

}
