//
// RealTimePlot.m
// CorePlotGallery
//

import CorePlot

let kFrameRate = 5.0  // frames per second
let kAlpha     = 0.25 // smoothing constant

let kMaxDataPoints = 52
let kPlotIdentifier = "Data Source Plot"

class RealTimePlot: PlotItem {

    var plotData: [Double] = []
    var currentIndex: UInt = 0
    var dataTimer: Timer? = nil

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Real Time Plot"
        section = kLinePlots
    }

    override func killGraph() {
        dataTimer?.invalidate()
        dataTimer = nil

        super.killGraph()
    }

    override func generateData() {
        plotData = []
        currentIndex = 0
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

        graph.plotAreaFrame?.paddingTop    = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingRight  = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingBottom = self.titleSize * 2.625
        graph.plotAreaFrame?.paddingLeft   = self.titleSize * 2.5
        graph.plotAreaFrame?.masksToBorder = false

        // Grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.1)

        // Axes
        // X axis
        let axisSet = graph.axisSet as! CPTXYAxisSet
        if let x          = axisSet.xAxis {
            x.labelingPolicy        = .automatic
            x.orthogonalPosition    = 0.0
            x.majorGridLineStyle    = majorGridLineStyle
            x.minorGridLineStyle    = minorGridLineStyle
            x.minorTicksPerInterval = 9
            x.labelOffset           = self.titleSize * 0.25
            x.title                 = "X Axis"
            x.titleOffset           = self.titleSize * 1.5

            let labelFormatter = NumberFormatter()
            labelFormatter.numberStyle = .none
            x.labelFormatter           = labelFormatter

            // Rotate the labels by 45 degrees, just to show it can be done.
            x.labelRotation = CGFloat(M_PI_4)
        }

        // Y axis
        if let y = axisSet.yAxis {
            y.labelingPolicy        = .automatic
            y.orthogonalPosition    = 0.0
            y.majorGridLineStyle    = majorGridLineStyle
            y.minorGridLineStyle    = minorGridLineStyle
            y.minorTicksPerInterval = 3
            y.labelOffset           = self.titleSize * 0.25
            y.title                 = "Y Axis"
            y.titleOffset           = self.titleSize * 1.25
            y.axisConstraints       = CPTConstraints(lowerOffset: 0.0)
        }


        // Create the plot
        let dataSourceLinePlot = CPTScatterPlot()
        dataSourceLinePlot.identifier     = kPlotIdentifier as (NSCoding & NSCopying & NSObjectProtocol)?
        dataSourceLinePlot.cachePrecision = .double

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth              = 3.0
        lineStyle.lineColor              = CPTColor.green()
        dataSourceLinePlot.dataLineStyle = lineStyle

        dataSourceLinePlot.dataSource = self
        graph.add(dataSourceLinePlot)

        // Plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: NSNumber(value: kMaxDataPoints - 2))
        plotSpace.yRange = CPTPlotRange(location: 0.0, length:1.0)

        dataTimer?.invalidate()

        if ( animated ) {
            let newTimer = Timer(timeInterval:1.0 / kFrameRate,
                                                        target: self,
                                                      selector: #selector(newData(_:)),
                                                      userInfo: nil,
                                                       repeats: true)
            self.dataTimer = newTimer
            RunLoop.main.add(newTimer, forMode: RunLoopMode.commonModes)
        }
        else {
            self.dataTimer = nil
        }
    }

    deinit {
        dataTimer?.invalidate()
    }

// MARK: - Timer callback

    func newData(_ theTimer: Timer) {
    let theGraph = graphs[0]
    let thePlot = theGraph.plot(withIdentifier: kPlotIdentifier as NSCopying?) // as! CPTPlot

    if thePlot != nil {
        if ( plotData.count >= kMaxDataPoints ) {
            plotData.remove(at: 0)
            thePlot?.deleteData(inIndexRange: NSRange(location: 0, length: 1))
        }

        let plotSpace = theGraph.defaultPlotSpace as! CPTXYPlotSpace
        let location = (Int(currentIndex) >= kMaxDataPoints ? Int(currentIndex) - kMaxDataPoints + 2 : 0)

        let oldRange = CPTPlotRange(location:  NSNumber(value: (location > 0) ? (location - 1) : 0), length:NSNumber(value: kMaxDataPoints - 2))
        let newRange = CPTPlotRange(location: NSNumber(value: location), length: NSNumber(value: kMaxDataPoints - 2))

        CPTAnimation.animate(plotSpace,
                             property:"xRange",
                             from:oldRange,
                             to:newRange,
                     duration: CGFloat(1.0 / kFrameRate))

        self.currentIndex += 1
        plotData.append(  (1.0 - kAlpha) * Double(plotData.last ?? 0.0) + kAlpha * Double(arc4random()) / Double(UInt32.max) )
        thePlot?.insertData(at: UInt(plotData.count - 1), numberOfRecords:1)
    }
}

    }

//MARK: - Plot Data Source Methods

extension RealTimePlot: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {
        var num: Double? = nil

        guard let field = CPTScatterPlotField(rawValue: Int(fieldEnum)) else {
            return num
        }

        switch ( field ) {
            case .X:
                num = Double(index + currentIndex - UInt(plotData.count))

            case .Y:
                num = self.plotData[Int(index)]
        }
        
        return num
    }
    
}
