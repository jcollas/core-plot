//
// CompositePlot.m
// CorePlotGallery
//

import CorePlot

class CompositePlot: PlotItem {

    var dataForChart: [Double] = []
    var dataForPlot: [[String: Double]] = []

    var selectedIndex: Int?

    var scatterPlotView: CPTGraphHostingView?
    var barChartView: CPTGraphHostingView?
    var pieChartView: CPTGraphHostingView?

    var scatterPlot: CPTXYGraph?
    var barChart: CPTXYGraph?
    var pieChart: CPTXYGraph?

    override class func initialize()  {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Composite Plot"
        section = kDemoPlots
    }

    // MARK: - Plot construction methods

#if os(OSX)

    override func setFrameSize(newSize: NSSize) {
        self.scatterPlotView?.frame = NSMakeRect( 0.0,
                                                0.0,
                                                newSize.width,
                                                newSize.height * 0.5 )

        self.barChartView?.frame = NSMakeRect( 0.0,
                                             newSize.height * 0.5,
                                             newSize.width * 0.5,
                                             newSize.height * 0.5 )

        self.pieChartView?.frame = NSMakeRect( newSize.width * 0.5,
                                             newSize.height * 0.5,
                                             newSize.width * 0.5,
                                             newSize.height * 0.5 )

        self.scatterPlotView?.needsDisplay = true
        self.barChartView?.needsDisplay = true
        self.pieChartView?.needsDisplay = true
    }
#endif

    override func renderInView(hostingView: PlotGalleryNativeView, withTheme theme: CPTTheme?, animated: Bool) {
        killGraph()

        let scatterView = CPTGraphHostingView()
        let barView     = CPTGraphHostingView()
        let pieView     = CPTGraphHostingView()

#if os(iOS) || os(tvOS)
        for view in [scatterView, barView, pieView] {
            view.translatesAutoresizingMaskIntoConstraints = false
            hostingView.addSubview(view)

            hostingView.addConstraint(NSLayoutConstraint(item:view,
                                                                    attribute: .Height,
                                                                    relatedBy: .Equal,
                                                                       toItem: hostingView,
                                                                    attribute: .Height,
                                                                   multiplier: 0.5,
                                                                     constant: 0.0))
        }

        hostingView.addConstraint(NSLayoutConstraint(item: scatterView,
                                                     attribute: .Width,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Width,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: barView,
                                                     attribute: .Width,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Width,
                                                     multiplier: 0.5,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: pieView,
                                                     attribute: .Width,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Width,
                                                     multiplier: 0.5,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: scatterView,
                                                     attribute: .Left,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Left,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: barView,
                                                     attribute: .Left,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Left,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: pieView,
                                                     attribute: .Right,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Right,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: scatterView,
                                                     attribute: .Bottom,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Bottom,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: barView,
                                                     attribute: .Top,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Top,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

        hostingView.addConstraint(NSLayoutConstraint(item: pieView,
                                                     attribute: .Top,
                                                     relatedBy: .Equal,
                                                     toItem: hostingView,
                                                     attribute: .Top,
                                                     multiplier: 1.0,
                                                     constant: 0.0))

#else
        let viewRect = hostingView.bounds

        scatterView.frame = NSMakeRect( 0.0,
                                       0.0,
                                       viewRect.size.width,
                                       viewRect.size.height * 0.5 )

        barView.frame = NSMakeRect( 0.0,
                                   viewRect.size.height * 0.5,
                                   viewRect.size.width * 0.5,
                                   viewRect.size.height * 0.5 )

        pieView.frame = NSMakeRect( viewRect.size.width * 0.5,
                                   viewRect.size.height * 0.5,
                                   viewRect.size.width * 0.5,
                                   viewRect.size.height * 0.5 )

        for view in [scatterView, barView, pieView] {
            view.setAutoresizesSubviews = true
            view.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable

            hostingView.addSubview(view)
        }
#endif

        self.scatterPlotView = scatterView
        self.barChartView    = barView
        self.pieChartView    = pieView

        renderScatterPlotInHostingView(scatterView, withTheme: theme)
        renderBarPlotInHostingView(barView, withTheme: theme)
        renderPieChartInHostingView(pieView, withTheme: theme)

        self.formatAllGraphs()
    }

    override func killGraph() {

        self.scatterPlotView?.hostedGraph = nil
        self.barChartView?.hostedGraph = nil
        self.pieChartView?.hostedGraph = nil

        scatterPlotView?.removeFromSuperview()
        barChartView?.removeFromSuperview()
        pieChartView?.removeFromSuperview()

        self.scatterPlotView = nil
        self.barChartView = nil
        self.pieChartView = nil

        super.killGraph()
    }

    func renderScatterPlotInHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?) {

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let newGraph = CPTXYGraph(frame: bounds)
        scatterPlot = newGraph

        self.addGraph(newGraph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: newGraph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        scatterPlot?.plotAreaFrame?.plotArea?.delegate = self

        // Setup plot space
        let plotSpace = scatterPlot?.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.xRange = CPTPlotRange(location:1.0, length:2.0)
        plotSpace.yRange = CPTPlotRange(location:1.0, length:3.0)

        // Axes
        let axisSet = scatterPlot?.axisSet as! CPTXYAxisSet
        if let x = axisSet.xAxis {
            x.majorIntervalLength   = 0.5
            x.orthogonalPosition    = 2.0
            x.minorTicksPerInterval = 2
            let exclusionRanges = [CPTPlotRange(location:1.99, length:0.02),
                                   CPTPlotRange(location:0.99, length:0.02),
                                   CPTPlotRange(location:2.99, length:0.02)]
            x.labelExclusionRanges = exclusionRanges
        }

        if let y = axisSet.yAxis {
            y.majorIntervalLength   = 0.5
            y.minorTicksPerInterval = 5
            y.orthogonalPosition    = 2.0
            let exclusionRanges         = [CPTPlotRange(location:1.99, length:0.02),
                                           CPTPlotRange(location:0.99, length:0.02),
                                           CPTPlotRange(location:3.99, length:0.02)]
            y.labelExclusionRanges = exclusionRanges
        }

        // Create a blue plot area
        let boundLinePlot = CPTScatterPlot()
        boundLinePlot.identifier = "Blue Plot"

        var lineStyle = boundLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.miterLimit        = 1.0
        lineStyle.lineWidth         = 3.0
        lineStyle.lineColor         = CPTColor.blueColor()
        boundLinePlot.dataLineStyle = lineStyle
        boundLinePlot.dataSource    = self
        scatterPlot?.addPlot(boundLinePlot)

        // Do a blue gradient
        let areaColor1 = CPTColor(componentRed: 0.3, green: 0.3, blue: 1.0, alpha: 0.8)
        let areaGradient1 = CPTGradient(beginningColor: areaColor1, endingColor: CPTColor.clearColor())
        areaGradient1.angle = -90.0
        var areaGradientFill = CPTFill(gradient: areaGradient1)
        boundLinePlot.areaFill = areaGradientFill
        boundLinePlot.areaBaseValue = 0.0
        boundLinePlot.delegate = self

        // Add plot symbols
        let symbolLineStyle = CPTMutableLineStyle()
        symbolLineStyle.lineColor = CPTColor.blackColor()
        let plotSymbol = CPTPlotSymbol.ellipsePlotSymbol()
        plotSymbol.fill          = CPTFill(color: CPTColor.blueColor())
        plotSymbol.lineStyle     = symbolLineStyle
        plotSymbol.size          = CGSize(width: 10.0, height: 10.0)
        boundLinePlot.plotSymbol = plotSymbol

        // Create a green plot area
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier = "Green Plot"

        lineStyle             = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth   = 3.0
        lineStyle.lineColor   = CPTColor.greenColor()
        lineStyle.dashPattern = [5, 5]

        dataSourceLinePlot.dataLineStyle = lineStyle
        dataSourceLinePlot.dataSource    = self

        // Put an area gradient under the plot above
        let areaColor = CPTColor(componentRed: 0.3, green:1.0, blue: 0.3, alpha: 0.8)
        let areaGradient = CPTGradient(beginningColor: areaColor, endingColor: CPTColor.clearColor())
        areaGradient.angle               = -90.0
        areaGradientFill                 = CPTFill(gradient: areaGradient)
        dataSourceLinePlot.areaFill      = areaGradientFill
        dataSourceLinePlot.areaBaseValue = 1.75

        // Animate in the new plot, as an example
        dataSourceLinePlot.opacity = 1.0
        scatterPlot?.addPlot(dataSourceLinePlot)

        // Add some initial data
        var contentArray: [[String: Double]] = []
        for i in 0..<60 {
            let xVal = 1 + Double(i) * 0.05
            let yVal = 1.2 * Double(arc4random()) / Double(UInt32.max) + 1.2
            contentArray.append([ "x": xVal, "y": yVal ])
        }
        self.dataForPlot = contentArray
    }

    func renderBarPlotInHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?) {

#if os(iOS) || os(tvOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let newGraph = CPTXYGraph(frame: bounds)
        barChart = newGraph

        self.addGraph(newGraph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: newGraph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        barChart?.plotAreaFrame?.masksToBorder = false

        let plotSpace = barChart?.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.yRange = CPTPlotRange(location:0.0, length: 300.0)
        plotSpace.xRange = CPTPlotRange(location:-1.0, length: 17.0)

        let axisSet = barChart?.axisSet as! CPTXYAxisSet
        if let x          = axisSet.xAxis {
        x.axisLineStyle       = nil
        x.majorTickLineStyle  = nil
        x.minorTickLineStyle  = nil
        x.majorIntervalLength = 5.0
        x.orthogonalPosition  = 0.0

        // Define some custom labels for the data elements
        x.labelOffset    = 2.0
        x.labelRotation  = CGFloat(M_PI_4)
        x.labelingPolicy = .None
        let customTickLocations: [Double]  = [1, 5, 10, 15]
        let xAxisLabels = ["Label A", "Label B", "Label C", "Label D"]
        var labelLocation = 0
        var customLabels: Set<CPTAxisLabel> = []
        for tickLocation in customTickLocations {
            let newLabel = CPTAxisLabel(text: xAxisLabels[labelLocation], textStyle: x.labelTextStyle)
            labelLocation += 1
            newLabel.tickLocation = tickLocation
            newLabel.offset       = x.labelOffset
            newLabel.rotation     = CGFloat(M_PI_4)
            customLabels.insert(newLabel)
        }

        x.axisLabels = customLabels
        }

        if let y = axisSet.yAxis {
        y.axisLineStyle       = nil
        y.majorTickLineStyle  = nil
        y.minorTickLineStyle  = nil
        y.majorIntervalLength = 50.0
        y.orthogonalPosition  = 0.0
        }

        // First bar plot
        var barPlot = CPTBarPlot.tubularBarPlotWithColor(CPTColor.redColor(), horizontalBars: false)
        barPlot.dataSource  = self
        barPlot.identifier  = "Bar Plot 1"
        barPlot.labelOffset = 2.0
        barChart?.addPlot(barPlot, toPlotSpace: plotSpace)

        // Second bar plot
        barPlot = CPTBarPlot.tubularBarPlotWithColor(CPTColor.blueColor(), horizontalBars: false)
        barPlot.dataSource      = self
        barPlot.barOffset       = 0.25 // 25% offset, 75% overlap
        barPlot.barCornerRadius = 2.0
        barPlot.identifier      = "Bar Plot 2"
        barPlot.delegate        = self
        barChart?.addPlot(barPlot, toPlotSpace: plotSpace)
    }

    func renderPieChartInHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?) {

#if os(iOS) || os(tvOS)
        hostingView.layoutIfNeeded()
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let newGraph = CPTXYGraph(frame: bounds)
        pieChart = newGraph

        self.addGraph(newGraph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: newGraph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        self.pieChart?.plotAreaFrame?.masksToBorder = false

        self.pieChart?.axisSet = nil

        // Add pie chart
        let piePlot = CPTPieChart()
        piePlot.dataSource = self
        piePlot.pieRadius  = min( 0.7 * ((hostingView.frame.size.height - 2.0 * pieChart!.paddingLeft) / 2.0),
                                 0.7 * ((hostingView.frame.size.width - 2.0 * pieChart!.paddingTop) / 2.0) )
        piePlot.identifier      = "Pie Chart 1"
        piePlot.startAngle      = CGFloat(M_PI_4)
        piePlot.sliceDirection  = .CounterClockwise
        piePlot.borderLineStyle = CPTLineStyle()
        pieChart?.addPlot(piePlot)

        // Add some initial data
        self.dataForChart = [20.0, 30.0, 60.0]
    }

}

// MARK: - CPTBarPlot delegate

extension CompositePlot: CPTBarPlotDelegate {

    func barPlot(plot: CPTBarPlot, barWasSelectedAtRecordIndex index: UInt) {
        NSLog("barWasSelectedAtRecordIndex \(index)")
    }

}

// MARK: - CPTScatterPlot delegate

extension CompositePlot: CPTScatterPlotDelegate {
        
    func scatterPlot(plot: CPTScatterPlot, plotSymbolWasSelectedAtRecordIndex index: UInt) {
        if plot.identifier as! String == "Blue Plot" {
            self.selectedIndex = Int(index)
        }
    }

}

// MARK: - Plot area delegate

extension CompositePlot: CPTPlotAreaDelegate {

    func plotAreaWasSelected(plotArea: CPTPlotArea) {
        let theGraph = plotArea.graph

        if theGraph == scatterPlot {
            self.selectedIndex = nil
        }
    }

}

// MARK: - Plot Data Source

extension CompositePlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {

        if plot is CPTPieChart {
            return UInt(dataForChart.count)
        }
        else if plot is CPTBarPlot  {
            return 16
        }
        else {
            return UInt(dataForPlot.count)
        }
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
        var num: Double? = nil


        if plot is CPTPieChart {

            guard let field = CPTPieChartField(rawValue: Int(fieldEnum)) else {
                return nil
            }

            if ( Int(index) >= dataForChart.count ) {
                return nil
            }

            if ( field == .SliceWidth ) {
                return (self.dataForChart)[Int(index)]
            }
            else {
                return index
            }
        } else if plot is CPTBarPlot {

            guard let field = CPTBarPlotField(rawValue: Int(fieldEnum)) else {
                return nil
            }

            switch ( field ) {
                case .BarLocation:
                    num = Double(index)

                case .BarTip:
                    num = Double((index + 1) * (index + 1))
                    if plot.identifier as! String == "Bar Plot 2" {
                        num = num! - 10
                    }

                case .BarBase:
                    break
            }
        } else {
            guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
                return nil
            }

            let key = (field == .X ? "x" : "y")
            num = self.dataForPlot[Int(index)][key]

            // Green plot gets shifted above the blue
            if plot.identifier as! String == "Green Plot" {
                if ( field == .Y ) {
                    num = num! + 1.0
                }
            }
        }

        return num
    }

    func dataLabelForPlot(plot: CPTPlot, recordIndex index: UInt) -> CPTLayer? {
        var newLayer: CPTTextLayer? = nil

        if plot.identifier as! String == "Bar Plot 1" {
            let whiteText = CPTMutableTextStyle()
            whiteText.color = CPTColor.whiteColor()
            whiteText.fontSize = self.titleSize * 0.5

            let redText = CPTMutableTextStyle()
            redText.color = CPTColor.redColor()
            redText.fontSize = self.titleSize * 0.5

            switch ( index ) {
                case 0:
                    break

                case 1:
                    newLayer = CPTTextLayer(text: "\(index)", style: redText)

                default:
                    newLayer = CPTTextLayer(text: "\(index)", style: whiteText)
            }
        }
        
        return newLayer
    }

    func symbolForScatterPlot(plot: CPTScatterPlot, recordIndex index: UInt) -> CPTPlotSymbol? {
        var symbol: CPTPlotSymbol? = nil // Use the default symbol

        if plot.identifier as! String == "Blue Plot" && Int(index) == self.selectedIndex {
            let redDot = CPTPlotSymbol()
            redDot.symbolType = .Ellipse
            redDot.size = CGSize(width: 10.0, height: 10.0)
            redDot.fill = CPTFill(color: CPTColor.redColor())
            redDot.lineStyle = CPTLineStyle()

            symbol = redDot
        }

        return symbol
    }

// MARK: - Accessors

    func setSelectedIndex(newIndex: Int?) {
        if ( newIndex != selectedIndex ) {
            let oldIndex = selectedIndex
            
            selectedIndex = newIndex
            
            let thePlot = scatterPlot?.plotWithIdentifier("Blue Plot") as? CPTScatterPlot
            if ( oldIndex != nil ) {
                thePlot?.reloadPlotSymbolsInIndexRange(NSRange(location: oldIndex!, length: 1))
            }
            if ( newIndex != nil ) {
                thePlot?.reloadPlotSymbolsInIndexRange(NSRange(location: newIndex!, length: 1))
            }
        }
    }
    
    }
