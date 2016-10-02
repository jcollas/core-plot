
import CorePlot

class FunctionPlot: PlotItem {

    var dataSources: Set<CPTFunctionDataSource> = []

#if os(iOS) || os(tvOS)
    typealias CPTFont=UIFont
#else
    typealias CPTFont=NSFont
#endif

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Math Function Plot"
        section = kLinePlots
    }

    override func killGraph() {
        dataSources = []

        super.killGraph()
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

        graph.plotAreaFrame?.paddingLeft += titleSize * 2.25

        // Setup scatter plot space
        let plotSpace = graph.defaultPlotSpace as! CPTXYPlotSpace
        plotSpace.allowsUserInteraction = true
        plotSpace.xRange = CPTPlotRange(location: 0.0, length: NSNumber(value: 2.0 * .pi))
        plotSpace.yRange = CPTPlotRange(location: -1.1, length: 2.2)

        // Grid line styles
        let majorGridLineStyle = CPTMutableLineStyle()
        majorGridLineStyle.lineWidth = 0.75
        majorGridLineStyle.lineColor = CPTColor(genericGray: 0.2).withAlphaComponent(0.75)

        let minorGridLineStyle = CPTMutableLineStyle()
        minorGridLineStyle.lineWidth = 0.25
        minorGridLineStyle.lineColor = CPTColor.white().withAlphaComponent(0.1)

        // Axes
        let formatter = PiNumberFormatter()
        formatter.multiplier = 4

        // Label x axis with a fixed interval policy
        let axisSet = graph.axisSet as! CPTXYAxisSet

        guard let x = axisSet.xAxis else {
            return
        }

            x.majorIntervalLength   = M_PI_4 as NSNumber?
            x.minorTicksPerInterval = 3
            x.labelFormatter        = formatter
            x.majorGridLineStyle    = majorGridLineStyle
            x.minorGridLineStyle    = minorGridLineStyle
            x.axisConstraints       = CPTConstraints(relativeOffset: 0.5)

            x.title       = "X Axis"
            x.titleOffset = self.titleSize * 1.25

        // Label y with an automatic label policy.
        if let y = axisSet.yAxis {
            y.labelingPolicy              = .automatic
            y.minorTicksPerInterval       = 4
            y.preferredNumberOfMajorTicks = 8
            y.majorGridLineStyle          = majorGridLineStyle
            y.minorGridLineStyle          = minorGridLineStyle
            y.labelOffset                 = 2.0
            y.axisConstraints             = CPTConstraints(lowerOffset: 0.0)

            y.title       = "Y Axis"
            y.titleOffset = self.titleSize * 1.25
        }

        // Create some function plots
        for plotNum in 0..<3 {
            var titleString: String? = nil
            var block: CPTDataSourceBlock? = nil
            var lineColor: CPTColor? = nil

            switch ( plotNum ) {
                case 0:
                    titleString = "y = sin(x)"
                    block = { (xVal: Double) -> Double in return sin(xVal) }
                    lineColor   = CPTColor.red()

                case 1:
                    titleString = "y = cos(x)"
                    block = { (xVal: Double) -> Double in return cos(xVal) }
                    lineColor = CPTColor.green()

                case 2:
                    titleString = "y = tan(x)"
                    block = { (xVal: Double) -> Double in return tan(xVal) }
                    lineColor   = CPTColor.blue()

                default:
                    break
            }

            let linePlot = CPTScatterPlot()
            linePlot.identifier = "Function Plot \(plotNum + 1)" as (NSCoding & NSCopying & NSObjectProtocol)?

            let textAttributes: [String: Any] = x.titleTextStyle!.attributes

            let title = NSMutableAttributedString(string: titleString!, attributes: textAttributes)

            if let fontAttribute = textAttributes[NSFontAttributeName] as? CPTFont {
                if let italicFont = italicFontForFont(fontAttribute) {

                    title.addAttribute(NSFontAttributeName,
                                       value: italicFont,
                                       range: NSRange(location: 0, length: 1))
                    title.addAttribute(NSFontAttributeName,
                                       value: italicFont,
                                       range: NSRange(location: 8, length: 1))
                }
            }

            if let labelFont = CPTFont(name: "Helvetica", size: self.titleSize * 0.5) {
                title.addAttribute(NSFontAttributeName,
                                   value: labelFont,
                                   range: NSRange(location: 0, length: title.length))
            }

            linePlot.attributedTitle = title

            let lineStyle = linePlot.dataLineStyle?.mutableCopy() as! CPTMutableLineStyle
            lineStyle.lineWidth    = 3.0
            lineStyle.lineColor    = lineColor
            linePlot.dataLineStyle = lineStyle

            linePlot.alignsPointsToPixels = false

            let plotDataSource = CPTFunctionDataSource(for: linePlot, with: block!)
            plotDataSource.resolution = 2.0

            dataSources.insert(plotDataSource)
            
            graph.add(linePlot)
        }
        
        // Restrict y range to a global range
        let globalYRange = CPTPlotRange(location: -2.5, length: 5.0)
        plotSpace.globalYRange = globalYRange
        
        // Add legend
        graph.legend                 = CPTLegend(graph: graph)
        graph.legend?.fill            = CPTFill(color: CPTColor.darkGray())
        graph.legend?.borderLineStyle = x.axisLineStyle
        graph.legend?.cornerRadius    = 5.0
        graph.legend?.numberOfRows    = 1
        graph.legend?.delegate        = self
        graph.legendAnchor           = .bottom
        graph.legendDisplacement     = CGPoint(x: 0.0, y: self.titleSize * 1.25)
    }

#if os(iOS) || os(tvOS)
    func italicFontForFont(_ oldFont: UIFont) -> UIFont? {
        var italicName: String? = nil

        let fontNames = UIFont.fontNames(forFamilyName: oldFont.familyName)

        for fontName in fontNames {
            if fontName.uppercased().contains("ITALIC") {
                italicName = fontName
                break
            }
        }

        if italicName == nil {
            for fontName in fontNames {
                if fontName.uppercased().contains("OBLIQUE") {
                    italicName = fontName
                    break
                }
            }
        }

        if let italicName = italicName {
            return UIFont(name: italicName, size:oldFont.pointSize)
        }
        
        return nil
    }

#else
    func italicFontForFont(_ oldFont: NSFont) -> NSFont? {
        return NSFontManager.shared().convert(oldFont, toHaveTrait: NSFontTraitMask(rawValue: UInt(NSFontItalicTrait)))
    }
#endif

}

// MARK: - Legend delegate

extension FunctionPlot: CPTLegendDelegate {

    func legend(_ legend: CPTLegend, legendEntryFor plot: CPTPlot, wasSelectedAt idx: UInt) {
        plot.isHidden = !plot.isHidden
    }

}
