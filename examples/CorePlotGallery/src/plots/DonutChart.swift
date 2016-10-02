
import CorePlot

let innerChartName = "Inner"
let outerChartName = "Outer"

class DonutChart: PlotItem {

    var plotData: [Double] = [20.0, 30.0, 60.0]

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Donut Chart"
        section = kPieCharts
    }

    override func generateData() {

    }

    override func renderInGraphHostingView(_ hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {
#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: CPTThemeName.darkGradientTheme))

        graph.plotAreaFrame?.masksToBorder = false
        graph.axisSet = nil

        let whiteLineStyle = CPTMutableLineStyle()
        whiteLineStyle.lineColor = CPTColor.white()

        let whiteShadow = CPTMutableShadow()
        whiteShadow.shadowOffset = CGSize(width: 2.0, height: -4.0)
        whiteShadow.shadowBlurRadius = 4.0
        whiteShadow.shadowColor = CPTColor.white().withAlphaComponent(0.25)

        // Add pie chart
        let outerRadius = min( 0.7 * (hostingView.frame.size.height - 2.0 * graph.paddingLeft) / 2.0,
                              0.7 * (hostingView.frame.size.width - 2.0 * graph.paddingTop) / 2.0 )
        let innerRadius = outerRadius / 2.0

        var piePlot = CPTPieChart()
        piePlot.dataSource      = self
        piePlot.pieRadius       = outerRadius
        piePlot.pieInnerRadius  = innerRadius + 5.0
        piePlot.identifier      = outerChartName as (NSCoding & NSCopying & NSObjectProtocol)?
        piePlot.borderLineStyle = whiteLineStyle
        piePlot.startAngle      = CGFloat(animated ? M_PI_2 : M_PI_4)
        piePlot.endAngle        = CGFloat(animated ? M_PI_2 : 3.0 * M_PI_4)
        piePlot.sliceDirection  = .counterClockwise
        piePlot.shadow          = whiteShadow
        piePlot.delegate        = self
        graph.add(piePlot)

        if ( animated ) {
            CPTAnimation.animate(piePlot,
                         property: "startAngle",
                             from: CGFloat(M_PI_2),
                               to: CGFloat(M_PI_4),
                         duration:0.25)
            CPTAnimation.animate(piePlot,
                         property: "endAngle",
                             from:CGFloat(M_PI_2),
                               to:CGFloat(3.0 * M_PI_4),
                         duration:0.25)
        }

        // Add another pie chart
        piePlot                 = CPTPieChart()
        piePlot.dataSource      = self
        piePlot.pieRadius       = CGFloat( animated ? 0.0 : innerRadius - 5.0 )
        piePlot.identifier      = innerChartName as (NSCoding & NSCopying & NSObjectProtocol)?
        piePlot.borderLineStyle = whiteLineStyle
        piePlot.startAngle      = CGFloat(M_PI_4)
        piePlot.sliceDirection  = .clockwise
        piePlot.shadow          = whiteShadow
        piePlot.delegate        = self

        graph.add(piePlot)

        if ( animated ) {
            CPTAnimation.animate(piePlot,
                         property: "pieRadius",
                             from: 0.0,
                               to:innerRadius - 5.0,
                         duration:0.5,
                        withDelay:0.25,
                   animationCurve: .bounceOut,
                         delegate:self)
        }
    }

}

extension DonutChart: CPTPieChartDelegate {

    func pieChart(_ plot: CPTPieChart, sliceWasSelectedAtRecord index: UInt) {
        NSLog("\(plot.identifier) slice was selected at index \(index). Value = \(plotData[Int(index)])")
    }

}

// MARK: - Plot Data Source Methods

extension DonutChart: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {
        var num: Double!

        let field = CPTPieChartField(rawValue: Int(fieldEnum))
        if field == .sliceWidth {
            num = self.plotData[Int(index)]
        } else {
            return index
        }

        return num
    }

    func dataLabel(for plot: CPTPlot, record index: UInt) -> CPTLayer? {

        if plot.identifier as! String == outerChartName {
            let whiteText = CPTMutableTextStyle()

            whiteText.color = CPTColor.white()
            whiteText.fontSize = self.titleSize * 0.5

            let text = String(format: "%.0f", self.plotData[Int(index)])
            let newLayer = CPTTextLayer(text: text, style: whiteText)
            newLayer.fill            = CPTFill(color: CPTColor.darkGray())
            newLayer.cornerRadius    = 5.0
            newLayer.paddingLeft     = 3.0
            newLayer.paddingTop      = 3.0
            newLayer.paddingRight    = 3.0
            newLayer.paddingBottom   = 3.0
            newLayer.borderLineStyle = CPTLineStyle()
            return newLayer
        }

        return nil
    }

    func radialOffsetForPieChart(_ pieChart: CPTPieChart, recordIndex index: UInt) -> CGFloat {
        var result: CGFloat = 0.0

        if pieChart.identifier as! String == outerChartName {
            result = index == 0 ? 15.0 : 0.0
        }

        return result
    }

}

// MARK: - Animation Delegate

extension DonutChart: CPTAnimationDelegate {

//    func animationDidStart(_ operation: CPTAnimationOperation) {
//        NSLog("animationDidStart: \(operation)")
//    }

    func animationDidFinish(_ operation: CPTAnimationOperation) {
        NSLog("animationDidFinish: \(operation)")
    }

    func animationCancelled(_ operation: CPTAnimationOperation) {
        NSLog("animationCancelled: \(operation)")
    }

    func animationWillUpdate(_ operation: CPTAnimationOperation) {
        NSLog("animationWillUpdate: \(operation)")
    }

    func animationDidUpdate(_ operation: CPTAnimationOperation) {
        NSLog("animationDidUpdate: \(operation)")
    }

}
