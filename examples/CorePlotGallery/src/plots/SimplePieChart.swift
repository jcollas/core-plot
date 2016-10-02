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

        // Overlay gradient for pie chart
        var overlayGradient = CPTGradient()
        overlayGradient.gradientType = .radial
        overlayGradient = overlayGradient.addColorStop(CPTColor.black().withAlphaComponent(0.0), atPosition: 0.0)
        overlayGradient = overlayGradient.addColorStop(CPTColor.black().withAlphaComponent(0.3), atPosition: 0.9)
        overlayGradient = overlayGradient.addColorStop(CPTColor.black().withAlphaComponent(0.7), atPosition: 1.0)

        // Add pie chart
        let piePlot = CPTPieChart()
        piePlot.dataSource = self
        piePlot.pieRadius  = min( 0.7 * (hostingView.frame.size.height - 2.0 * graph.paddingLeft) / 2.0,
                                 0.7 * (hostingView.frame.size.width - 2.0 * graph.paddingTop) / 2.0 )
        piePlot.identifier     = self.title as (NSCoding & NSCopying & NSObjectProtocol)?
        piePlot.startAngle     = CGFloat(M_PI_4)
        piePlot.sliceDirection = .counterClockwise
        piePlot.overlayFill    = CPTFill(gradient: overlayGradient)

        piePlot.labelRotationRelativeToRadius = true
        piePlot.labelRotation = CGFloat(-M_PI_2)
        piePlot.labelOffset = -50.0

        piePlot.delegate = self
        graph.add(piePlot)

        // Add legend
        let theLegend = CPTLegend(graph: graph)
        theLegend.numberOfColumns = 1
        theLegend.fill            = CPTFill(color: .white())
        theLegend.borderLineStyle = CPTLineStyle()

        theLegend.entryFill = CPTFill(color: .lightGray())
        theLegend.entryBorderLineStyle = CPTLineStyle()
        theLegend.entryCornerRadius    = 3.0
        theLegend.entryPaddingLeft     = 3.0
        theLegend.entryPaddingTop      = 3.0
        theLegend.entryPaddingRight    = 3.0
        theLegend.entryPaddingBottom   = 3.0

        theLegend.cornerRadius = 5.0
        theLegend.delegate = self

        graph.legend = theLegend

        graph.legendAnchor = .right
        graph.legendDisplacement = CGPoint(x: -graph.paddingRight - 10.0, y: 0.0)
    }

}

// MARK: - CPTPieChartDelegate Methods

extension SimplePieChart: CPTPieChartDelegate {

    func plot(_ plot: CPTPlot, dataLabelWasSelectedAtRecord index: UInt) {
            NSLog("Data label for '\(plot.identifier)' was selected at index \(index).")
    }

    func pieChart(_ plot: CPTPieChart, sliceWasSelectedAtRecord index: UInt) {
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

        func legend(_ legend: CPTLegend, legendEntryFor plot: CPTPlot, wasSelectedAt idx: UInt) {
            NSLog("Legend entry for '\(plot.identifier)' was selected at index \(idx).")

            let startFrom: CGFloat = idx == self.offsetIndex ? .nan : 0.0  // If 1st has a value, should be NAN
            let endTo: CGFloat = idx == self.offsetIndex ? 0.0 : 35.0

            CPTAnimation.animate(self,
                         property: "sliceOffset",
                             from: startFrom,
                               to: endTo,
                         duration: 0.5,
                   animationCurve: .cubicOut,
                         delegate: nil)
            
            self.offsetIndex = idx
        }
        
}

// MARK: - Plot Data Source Methods

extension SimplePieChart: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(self.plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {

        if let field = CPTPieChartField(rawValue: Int(fieldEnum)) {
            if field == .sliceWidth {
                return plotData[Int(index)]
            }
        }

        return index

    }

    func dataLabel(for plot: CPTPlot, record index: UInt) -> CPTLayer? {
        let whiteText = CPTMutableTextStyle()

        whiteText.color = .white()
        whiteText.fontSize = self.titleSize * 0.5

        let value = String(format: "%1.0f", plotData[Int(index)])
        let newLayer = CPTTextLayer(text: "\(value)", style: whiteText)
        return newLayer
    }

    func attributedLegendTitleForPieChart(_ pieChart: CPTPieChart, recordIndex index: UInt) -> NSAttributedString {
#if os(iOS) || os(tvOS)
        let sliceColor = CPTPieChart.defaultPieSliceColor(for: index).uiColor
        let labelFont = UIFont(name: "Helvetica", size: self.titleSize * 0.5)
#else
        let sliceColor = CPTPieChart.defaultPieSliceColor(for: index).nsColor
        let labelFont = NSFont(name: "Helvetica", size: self.titleSize * 0.5)
#endif

            let title = NSMutableAttributedString(string:"Pie Slice \(index)")
            title.addAttribute(NSForegroundColorAttributeName,
                          value: sliceColor,
                          range: NSRange(location: 4, length: 5))

            title.addAttribute(NSFontAttributeName,
                          value: labelFont!,
                          range: NSRange(location: 0, length: title.length))

            return title
        }

    func radialOffsetForPieChart(_ pieChart: CPTPieChart, recordIndex index: UInt) -> CGFloat {
        return index == self.offsetIndex ? self.sliceOffset : 0.0
    }

}
