//
// SimpleBarGraph.m
// CorePlotGallery
//

import CorePlot

class VerticalBarChart: PlotItem {

    let kUseHorizontalBars = false

    var symbolTextAnnotation: CPTPlotSpaceAnnotation? = nil

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Vertical Bar Chart"
        section = kBarPlots
    }

    override func killGraph() {

        if ( graphs.count != 0 ) {
            let graph = graphs[0] as! CPTXYGraph

            if let annotation = self.symbolTextAnnotation {
                graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
                self.symbolTextAnnotation = nil
            }
        }
        
        super.killGraph()
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
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: .darkGradientTheme))

        let textSize = self.titleSize

        graph.plotAreaFrame?.masksToBorder = false
        if ( kUseHorizontalBars ) {
            graph.plotAreaFrame?.paddingBottom += self.titleSize
        }
        else {
            graph.plotAreaFrame?.paddingLeft += self.titleSize
        }

        // Add plot space for bar charts
        let barPlotSpace = CPTXYPlotSpace()
        barPlotSpace.setScaleType(.category, for: .X)
        if ( kUseHorizontalBars ) {
            barPlotSpace.xRange = CPTPlotRange(location: -10.0, length: 120.0)
            barPlotSpace.yRange = CPTPlotRange(location: -1.0, length: 11.0)
        }
        else {
            barPlotSpace.xRange = CPTPlotRange(location: -1.0, length: 11.0)
            barPlotSpace.yRange = CPTPlotRange(location: -10.0, length: 120.0)
        }
        graph.add(barPlotSpace)

        // Create grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 1.0
        majorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 1.0
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.25)

        // Create axes
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let
            x = axisSet.xAxis,
            let y = axisSet.yAxis else {
                return
        }

            x.majorIntervalLength   = (kUseHorizontalBars ? 10.0 : 1.0)
            x.minorTicksPerInterval = (kUseHorizontalBars ? 9 : 0)
            x.orthogonalPosition    = (kUseHorizontalBars ? -0.5 : 0.0)

            x.majorGridLineStyle = majorGridLineStyle
            x.minorGridLineStyle = minorGridLineStyle
            x.axisLineStyle      = nil
            x.majorTickLineStyle = nil
            x.minorTickLineStyle = nil

            x.labelOffset = self.titleSize * 0.5
            if ( kUseHorizontalBars ) {
                x.visibleRange = CPTPlotRange(location: 0.0, length: 100.0)
                x.gridLinesRange = CPTPlotRange(location: -0.5, length: 10.0)
            }
            else {
                x.visibleRange = CPTPlotRange(location: -0.5, length: 10.0)
                x.gridLinesRange = CPTPlotRange(location: 0.0, length: 100.0)
            }

            x.title = "X Axis"
            x.titleOffset = self.titleSize * 1.5

            x.titleLocation = (kUseHorizontalBars ? 55.0 : 5.0)

            x.plotSpace = barPlotSpace

            y.majorIntervalLength   = (kUseHorizontalBars ? 1.0 : 10.0)
            y.minorTicksPerInterval = (kUseHorizontalBars ? 0 : 9)
            y.orthogonalPosition    = ( kUseHorizontalBars ? 0.0 : -0.5 )

            y.preferredNumberOfMajorTicks = 8
            y.majorGridLineStyle          = majorGridLineStyle
            y.minorGridLineStyle          = minorGridLineStyle
            y.axisLineStyle               = nil
            y.majorTickLineStyle          = nil
            y.minorTickLineStyle          = nil
            y.labelOffset                 = self.titleSize * 0.5
            y.labelRotation               = CGFloat(M_PI_2)

            if ( self.kUseHorizontalBars ) {
                y.visibleRange   = CPTPlotRange(location:-0.5, length:10.0)
                y.gridLinesRange = CPTPlotRange(location:0.0, length:100.0)
            }
            else {
                y.visibleRange   = CPTPlotRange(location:0.0, length:100.0)
                y.gridLinesRange = CPTPlotRange(location: -0.5, length:10.0)
            }

            y.title = "Y Axis"
            y.titleOffset = self.titleSize * 1.5

            y.titleLocation = (kUseHorizontalBars ? 5.0 : 55.0)

            y.plotSpace = barPlotSpace

        // Set axes
        graph.axisSet?.axes = [x, y]

        // Create a bar line style
        let barLineStyle = CPTMutableLineStyle()
        barLineStyle.lineWidth = 1.0
        barLineStyle.lineColor = .white()

        // Create first bar plot
        let barPlot = CPTBarPlot()
        barPlot.lineStyle       = barLineStyle
        barPlot.fill = CPTFill(color: CPTColor(componentRed:1.0, green:0.0, blue:0.5, alpha:0.5))
        barPlot.barBasesVary    = true
        barPlot.barWidth        = 0.5 // bar is 50% of the available space
        barPlot.barCornerRadius = 10.0

        barPlot.barsAreHorizontal = kUseHorizontalBars

        let whiteTextStyle = CPTMutableTextStyle()
        whiteTextStyle.color = .white()

        barPlot.labelTextStyle = whiteTextStyle
        barPlot.labelOffset    = 0.0

        barPlot.delegate   = self
        barPlot.dataSource = self
        barPlot.identifier = "Bar Plot 1" as (NSCoding & NSCopying & NSObjectProtocol)?

        graph.add(barPlot, to:barPlotSpace)

        // Create second bar plot
        let barPlot2 = CPTBarPlot.tubularBarPlot(with: CPTColor.blue(), horizontalBars: false)

        barPlot2.lineStyle       = barLineStyle
        barPlot2.fill = CPTFill(color: CPTColor(componentRed:0.0, green:1.0, blue:0.5, alpha:0.5))
        barPlot2.barBasesVary    = true
        barPlot2.barWidth        = 1.0 // bar is full (100%) width
        barPlot2.barCornerRadius = 2.0

        barPlot2.barsAreHorizontal = kUseHorizontalBars

        barPlot2.delegate   = self
        barPlot2.dataSource = self
        barPlot2.identifier = "Bar Plot 2" as (NSCoding & NSCopying & NSObjectProtocol)?

        graph.add(barPlot2, to: barPlotSpace)

        // Add legend
        let theLegend = CPTLegend(graph: graph)
        theLegend.numberOfRows    = 2
        theLegend.fill = CPTFill(color: CPTColor(genericGray: 0.15))
        theLegend.borderLineStyle = barLineStyle
        theLegend.cornerRadius    = textSize * 0.25
        theLegend.swatchSize      = CGSize(width: textSize * 0.75, height: textSize * 0.75)
        whiteTextStyle.fontSize   = textSize * 0.5
        theLegend.textStyle       = whiteTextStyle
        theLegend.rowMargin       = textSize * 0.25
        
        theLegend.paddingLeft   = textSize * 0.375
        theLegend.paddingTop    = textSize * 0.375
        theLegend.paddingRight  = textSize * 0.375
        theLegend.paddingBottom = textSize * 0.375
        
        let plotPoint = (kUseHorizontalBars ? [95, 0] : [0, 95])
        
        let legendAnnotation = CPTPlotSpaceAnnotation(plotSpace:barPlotSpace, anchorPlotPoint: plotPoint as [NSNumber]?)
        legendAnnotation.contentLayer = theLegend
        
        legendAnnotation.contentAnchorPoint = kUseHorizontalBars ? CGPoint(x: 1.0, y: 0.0) : CGPoint(x: 0.0, y: 1.0)
        
        graph.plotAreaFrame?.plotArea?.addAnnotation(legendAnnotation)
    }

}

//MARK: - CPTBarPlot delegate methods

extension VerticalBarChart: CPTBarPlotDelegate {

    func plot(_ plot: CPTPlot, dataLabelWasSelectedAtRecord index: UInt) {
        NSLog("Data label for '\(plot.identifier)' was selected at index \(index).")
    }

    func barPlot(_ plot: CPTBarPlot, barWasSelectedAtRecord index: UInt) {
        let value = number(for: plot, field: UInt(CPTBarPlotField.barTip.rawValue), record: index)

        NSLog("Bar for '\(plot.identifier)' was selected at index \(index). Value = \(value)")

        let graph = graphs[0] as! CPTXYGraph

        var annotation = self.symbolTextAnnotation
        if annotation != nil {
            graph.plotAreaFrame?.plotArea?.removeAnnotation(annotation)
            self.symbolTextAnnotation = nil
        }

        // Setup a style for the annotation
        let hitAnnotationTextStyle = CPTMutableTextStyle()
        hitAnnotationTextStyle.color    = CPTColor.orange()
        hitAnnotationTextStyle.fontSize = 16.0
        hitAnnotationTextStyle.fontName = "Helvetica-Bold"

        // Determine point of symbol in plot coordinates
        let x = Double(index)
        let y = 2.0

        let anchorPoint: [Double] = kUseHorizontalBars ? [y, x] : [x, y]

        // Add annotation
        // First make a string for the y value
        let formatter = NumberFormatter()
        formatter.maximumFractionDigits = 2
        let yString = formatter.string(from: value as! NSNumber)

        // Now add the annotation to the plot area
        if let space = plot.plotSpace {
            let textLayer = CPTTextLayer(text:yString, style:hitAnnotationTextStyle)
            annotation = CPTPlotSpaceAnnotation(plotSpace: space, anchorPlotPoint: anchorPoint as [NSNumber]?)
            annotation?.contentLayer   = textLayer
            annotation?.displacement   = CGPoint(x: 0.0, y: 0.0)
            self.symbolTextAnnotation = annotation
            
            graph.plotAreaFrame?.plotArea?.addAnnotation(annotation)
        }
    }

}

// MARK: - Plot Data Source Methods

extension VerticalBarChart: CPTPlotDataSource {

    func numberOfRecords(for plot: CPTPlot) -> UInt {
        return 10
    }

    func number(for plot: CPTPlot, field fieldEnum: UInt, record index: UInt) -> Any? {

        guard let field = CPTBarPlotField(rawValue: Int(fieldEnum)) else {
            return nil
        }

        switch field {

        case .barLocation:
            // location
            return "Cat \(index)"

        case .barTip:
            // length
            return plot.identifier as! String == "Bar Plot 2" ? index : (index + 1) * (index + 1)

        default:
            // base
            return plot.identifier as! String == "Bar Plot 2" ? 0 : index
        }
    }
    
}
