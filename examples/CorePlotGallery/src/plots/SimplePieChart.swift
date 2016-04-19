//
// SimplePieChart.m
// CorePlotGallery
//

import CorePlot

class SimplePieChart: PlotItem { //<CPTPlotSpaceDelegate>

    var plotData: [Double] = [20.0, 30.0, 60.0]
    var offsetIndex: UInt? = nil
    var sliceOffset: CGFloat = 0.0 {
        didSet {
            if ( oldValue != sliceOffset ) {
                self.graphs[0].reloadData()

                if sliceOffset == 0.0 {
                    self.offsetIndex = nil
                }
            }
        }
    }

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Simple Pie Chart"
        section = kPieCharts
    }

    override func generateData() {
        if ( self.plotData.isEmpty ) {
            self.plotData = [20.0, 30.0, 60.0]
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
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        graph.plotAreaFrame?.masksToBorder = false
        graph.axisSet = nil

        // Overlay gradient for pie chart
        var overlayGradient = CPTGradient()
        overlayGradient.gradientType = .Radial
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.0), atPosition: 0.0)
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.3), atPosition: 0.9)
        overlayGradient = overlayGradient.addColorStop(CPTColor.blackColor().colorWithAlphaComponent(0.7), atPosition: 1.0)

        // Add pie chart
        let piePlot = CPTPieChart()
        piePlot.dataSource = self
        piePlot.pieRadius  = min( 0.7 * (hostingView.frame.size.height - 2.0 * graph.paddingLeft) / 2.0,
                                 0.7 * (hostingView.frame.size.width - 2.0 * graph.paddingTop) / 2.0 )
        piePlot.identifier     = self.title
        piePlot.startAngle     = CGFloat(M_PI_4)
        piePlot.sliceDirection = .CounterClockwise
        piePlot.overlayFill    = CPTFill(gradient: overlayGradient)

        piePlot.labelRotationRelativeToRadius = true
        piePlot.labelRotation = CGFloat(-M_PI_2)
        piePlot.labelOffset = -50.0

        piePlot.delegate = self
        graph.addPlot(piePlot)

        // Add legend
        let theLegend = CPTLegend(graph: graph)
        theLegend.numberOfColumns = 1
        theLegend.fill            = CPTFill(color: CPTColor.whiteColor())
        theLegend.borderLineStyle = CPTLineStyle()

        theLegend.entryFill = CPTFill(color: CPTColor.lightGrayColor())
        theLegend.entryBorderLineStyle = CPTLineStyle()
        theLegend.entryCornerRadius    = 3.0
        theLegend.entryPaddingLeft     = 3.0
        theLegend.entryPaddingTop      = 3.0
        theLegend.entryPaddingRight    = 3.0
        theLegend.entryPaddingBottom   = 3.0

        theLegend.cornerRadius = 5.0
        theLegend.delegate = self

        graph.legend = theLegend

        graph.legendAnchor = .Right
        graph.legendDisplacement = CGPoint(x: -graph.paddingRight - 10.0, y: 0.0)
    }

    func dataLabelForPlot(plot: CPTPlot, recordIndex index: UInt) -> CPTLayer? {
        let whiteText = CPTMutableTextStyle()

        whiteText.color = CPTColor.whiteColor()
        whiteText.fontSize = self.titleSize * 0.5

        let value = String(format: "%1.0f", plotData[Int(index)])
        let newLayer = CPTTextLayer(text: "\(value)", style: whiteText)
        return newLayer
    }
    
}

// MARK: - CPTPieChartDelegate Methods

extension SimplePieChart: CPTPieChartDelegate {

    func plot(plot: CPTPlot, dataLabelWasSelectedAtRecordIndex index: UInt) {
            NSLog("Data label for '\(plot.identifier)' was selected at index \(index).")
    }

    func pieChart(plot: CPTPieChart, sliceWasSelectedAtRecordIndex index: UInt) {
            NSLog("Slice was selected at index \(index). Value = \(plotData[Int(index)])")

            self.offsetIndex = nil

            var newData: [Double] = []
            let dataCount = lrint( ceil(10.0 * Double(arc4random()) / Double(UInt32.max)) ) + 1
            for _ in 1..<dataCount {
                newData.append(100.0 * Double(arc4random()) / Double(UInt32.max))
            }
            NSLog("newData: \(newData)")
            
            self.plotData = newData
            
            plot.reloadData()
        }
        
}

// MARK: - CPTLegendDelegate Methods

extension SimplePieChart: CPTLegendDelegate {

        func legend(legend: CPTLegend, legendEntryForPlot plot: CPTPlot, wasSelectedAtIndex idx: UInt) {
            NSLog("Legend entry for '\(plot.identifier)' was selected at index \(idx).")

            CPTAnimation.animate(self,
                         property: "sliceOffset",
                             from: idx == self.offsetIndex ? 0.0 : 0.0,  // If 1st has a value, should be NAN
                               to: idx == self.offsetIndex ? 0.0 : 35.0,
                         duration: 0.5,
                   animationCurve: .CubicOut,
                         delegate: nil)
            
            self.offsetIndex = idx
        }
        
}

// MARK: - Plot Data Source Methods

extension SimplePieChart: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {

        if let field = CPTPieChartField(rawValue: Int(fieldEnum)) {
            if field == .SliceWidth {
                return plotData[Int(index)]
            }
        }

        return index

    }

    func attributedLegendTitleForPieChart(pieChart: CPTPieChart, recordIndex index: UInt) -> NSAttributedString {
//#if TARGET_IPHONE_SIMULATOR || TARGET_OS_IPHONE
        let sliceColor = CPTPieChart.defaultPieSliceColorForIndex(index).uiColor
        let labelFont = UIFont(name: "Helvetica", size: self.titleSize * 0.5)
//#else
//            NSColor *sliceColor = [CPTPieChart defaultPieSliceColorForIndex:index].nsColor
//            NSFont *labelFont   = [NSFont fontWithName:"Helvetica" size:self.titleSize * 0.5]
//#endif

            let title = NSMutableAttributedString(string:"Pie Slice \(index)")
            title.addAttribute(NSForegroundColorAttributeName,
                          value: sliceColor,
                          range: NSRange(location: 4, length: 5))

            title.addAttribute(NSFontAttributeName,
                          value: labelFont!,
                          range: NSRange(location: 0, length: title.length))

            return title
        }

    func radialOffsetForPieChart(pieChart: CPTPieChart, recordIndex index: UInt) -> CGFloat {
        return index == self.offsetIndex ? self.sliceOffset : 0.0
    }

}
