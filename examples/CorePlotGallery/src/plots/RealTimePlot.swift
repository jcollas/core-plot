//
// RealTimePlot.m
// CorePlotGallery
//

import Foundation
import CorePlot

let kFrameRate = 5.0  // frames per second
let kAlpha     = 0.25 // smoothing constant

let kMaxDataPoints = 52
let kPlotIdentifier = "Data Source Plot"

class RealTimePlot: PlotItem {

    var plotData: [Double] = []
    var currentIndex: UInt = 0
    var dataTimer: NSTimer? = nil

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

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTDarkGradientTheme))

        graph.plotAreaFrame?.paddingTop    = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingRight  = self.titleSize * 0.5
        graph.plotAreaFrame?.paddingBottom = self.titleSize * 2.625
        graph.plotAreaFrame?.paddingLeft   = self.titleSize * 2.5
        graph.plotAreaFrame?.masksToBorder = false

        // Grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).colorWithAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.whiteColor().colorWithAlphaComponent(0.1)

        // Axes
        // X axis
        let axisSet = graph.axisSet as! CPTXYAxisSet
        if let x          = axisSet.xAxis {
            x.labelingPolicy        = .Automatic
            x.orthogonalPosition    = 0.0
            x.majorGridLineStyle    = majorGridLineStyle
            x.minorGridLineStyle    = minorGridLineStyle
            x.minorTicksPerInterval = 9
            x.labelOffset           = self.titleSize * 0.25
            x.title                 = "X Axis"
            x.titleOffset           = self.titleSize * 1.5

            let labelFormatter = NSNumberFormatter()
            labelFormatter.numberStyle = .NoStyle
            x.labelFormatter           = labelFormatter

            // Rotate the labels by 45 degrees, just to show it can be done.
            x.labelRotation = CGFloat(M_PI_4)
        }

        // Y axis
        if let y = axisSet.yAxis {
            y.labelingPolicy        = .Automatic
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
        dataSourceLinePlot.identifier     = kPlotIdentifier
        dataSourceLinePlot.cachePrecision = .Double

        let lineStyle = dataSourceLinePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
        lineStyle.lineWidth              = 3.0
        lineStyle.lineColor              = CPTColor.greenColor()
        dataSourceLinePlot.dataLineStyle = lineStyle

        dataSourceLinePlot.dataSource = self
        graph.addPlot(dataSourceLinePlot)

        // Plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: kMaxDataPoints - 2)
        plotSpace.yRange = CPTPlotRange(location: 0.0, length:1.0)

        dataTimer?.invalidate()

        if ( animated ) {
            let newTimer = NSTimer(timeInterval:1.0 / kFrameRate,
                                                        target: self,
                                                      selector: #selector(newData(_:)),
                                                      userInfo: nil,
                                                       repeats: true)
            self.dataTimer = newTimer
            NSRunLoop.mainRunLoop().addTimer(newTimer, forMode: NSRunLoopCommonModes)
        }
        else {
            self.dataTimer = nil
        }
    }

    deinit {
        dataTimer?.invalidate()
    }

// MARK: - Timer callback

    func newData(theTimer: NSTimer) {
    let theGraph = graphs[0]
    let thePlot = theGraph.plotWithIdentifier(kPlotIdentifier) // as! CPTPlot

    if thePlot != nil {
        if ( plotData.count >= kMaxDataPoints ) {
            plotData.removeAtIndex(0)
            thePlot?.deleteDataInIndexRange(NSMakeRange(0, 1))
        }

        let plotSpace = theGraph.defaultPlotSpace as! CPTXYPlotSpace
        let location = (Int(currentIndex) >= kMaxDataPoints ? Int(currentIndex) - kMaxDataPoints + 2 : 0)

        let oldRange = CPTPlotRange(location:  (location > 0) ? (location - 1) : 0, length:kMaxDataPoints - 2)
        let newRange = CPTPlotRange(location: location, length: kMaxDataPoints - 2)

        CPTAnimation.animate(plotSpace,
                     property:"xRange",
                fromPlotRange:oldRange,
                  toPlotRange:newRange,
                     duration: CGFloat(1.0 / kFrameRate))

        self.currentIndex += 1
        plotData.append(  (1.0 - kAlpha) * Double(plotData.last ?? 0.0) + kAlpha * Double(arc4random()) / Double(UInt32.max) )
        thePlot?.insertDataAtIndex(UInt(plotData.count - 1), numberOfRecords:1)
    }
}

    }

//MARK: - Plot Data Source Methods

extension RealTimePlot: CPTPlotDataSource {

    func numberOfRecordsForPlot(plot: CPTPlot) -> UInt {
        return UInt(plotData.count)
    }

    func numberForPlot(plot: CPTPlot, field fieldEnum: UInt, recordIndex index: UInt) -> AnyObject? {
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
