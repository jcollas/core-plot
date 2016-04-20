//
// PlotItem.m
// CorePlotGallery
//

import CorePlot

#if os(iOS) || os(tvOS)
    typealias CGNSRect=CGRect
    typealias PlotGalleryNativeView=UIView
#else
    typealias CGNSRect=NSRect
    typealias PlotGalleryNativeView=NSView
#endif

let kDemoPlots      = "Demos"
let kPieCharts      = "Pie Charts"
let kLinePlots      = "Line Plots"
let kBarPlots       = "Bar Plots"
let kFinancialPlots = "Financial Plots"

class PlotItem: NSObject {

    var defaultLayerHostingView: CPTGraphHostingView? = nil
    var graphs: [CPTGraph] = []
    var section: String? = nil
    var title: String? = nil
    var titleSize: CGFloat {
#if os(iOS)
        switch ( UI_USER_INTERFACE_IDIOM() ) {
            case .Pad:
                return 24.0

            case .Phone:
                return 16.0

            default:
                return 12.0
        }
#else
        return 24.0
#endif
    }

    var cachedImage: UIImage!

    class func registerPlotItem(itemClass: PlotItem.Type) {

        NSLog("registerPlotItem for class \(itemClass)")

        // There's no autorelease pool here yet...
        let plotItem = itemClass.init()
        PlotGallery.sharedPlotGallery.addPlotItem(plotItem)
    }

    override required init() {
        super.init()

        defaultLayerHostingView = nil

        graphs = []
        section = nil
        title = nil
    }

    func addGraph(graph: CPTGraph, toHostingView hostingView: CPTGraphHostingView?) {
        graphs.append(graph)

        hostingView?.hostedGraph = graph
    }

    func addGraph(graph: CPTGraph) {
        self.addGraph(graph, toHostingView: nil)
    }

    func killGraph() {
        CPTAnimation.sharedInstance().removeAllAnimationOperations()

        // Remove the CPTLayerHostingView
        if let hostingView = self.defaultLayerHostingView  {
            hostingView.removeFromSuperview()

            hostingView.hostedGraph = nil
            self.defaultLayerHostingView = nil
        }

        self.cachedImage = nil
        
        graphs.removeAll()
    }

    deinit {
        self.killGraph()
    }

// override to generate data for the plot if needed
    func generateData() {

    }

    func titleCompare(other: PlotItem) -> NSComparisonResult {
        var comparisonResult = section!.caseInsensitiveCompare(other.section!)

        if comparisonResult == .OrderedSame {
            comparisonResult = title!.caseInsensitiveCompare(other.title!)
        }

        return comparisonResult
    }

    func setPaddingDefaultsForGraph(graph: CPTGraph) {
        let boundsPadding = self.titleSize

        graph.paddingLeft = boundsPadding

        if graph.titleDisplacement.y > 0.0 {
            graph.paddingTop = graph.titleTextStyle!.fontSize * 2.0
        }
        else {
            graph.paddingTop = boundsPadding
        }

        graph.paddingRight  = boundsPadding
        graph.paddingBottom = boundsPadding
    }

    func formatAllGraphs() {
        let graphTitleSize = self.titleSize

        for graph in self.graphs {
            // Title
            let textStyle = CPTMutableTextStyle()
            textStyle.color = CPTColor.grayColor()
            textStyle.fontName = "Helvetica-Bold"
            textStyle.fontSize = graphTitleSize

            graph.title = (self.graphs.count == 1 ? self.title : nil)
            graph.titleTextStyle = textStyle
            graph.titleDisplacement = CGPointMake( 0.0, textStyle.fontSize * 1.5 )
            graph.titlePlotAreaFrameAnchor = .Top

            // Padding
            let boundsPadding = graphTitleSize
            graph.paddingLeft = boundsPadding

            if ( graph.title?.isEmpty == false ) {
                graph.paddingTop = max(graph.titleTextStyle!.fontSize * 2.0, boundsPadding)
            }
            else {
                graph.paddingTop = boundsPadding
            }

            graph.paddingRight  = boundsPadding
            graph.paddingBottom = boundsPadding

            // Axis labels
            let axisTitleSize = graphTitleSize * 0.75
            let labelSize = graphTitleSize * 0.5

            for axis in graph.axisSet?.axes ?? [] {
                // Axis title
                if let textStyle = axis.titleTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                    textStyle.fontSize = axisTitleSize
                    axis.titleTextStyle = textStyle
                }

                // Axis labels
                if let textStyle = axis.titleTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                    textStyle.fontSize = labelSize
                    axis.labelTextStyle = textStyle
                }

                if let textStyle = axis.minorTickLabelTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                    textStyle.fontSize = labelSize
                    axis.minorTickLabelTextStyle = textStyle
                }
            }

            // Plot labels
            for plot in graph.allPlots() {
                if let textStyle = plot.labelTextStyle?.mutableCopy() as? CPTMutableTextStyle {
                    textStyle.fontSize = labelSize
                    plot.labelTextStyle = textStyle
                }
            }

            // Legend
            if let theLegend = graph.legend {
                if let textStyle = theLegend.textStyle?.mutableCopy() as? CPTMutableTextStyle {
                    textStyle.fontSize = labelSize
                    theLegend.textStyle  = textStyle
                }

                theLegend.swatchSize = CGSizeMake( labelSize * 1.5, labelSize * 1.5 )

                theLegend.rowMargin    = labelSize * 0.75
                theLegend.columnMargin = labelSize * 0.75

                theLegend.paddingLeft   = labelSize * 0.375
                theLegend.paddingTop    = labelSize * 0.375
                theLegend.paddingRight  = labelSize * 0.375
                theLegend.paddingBottom = labelSize * 0.375
            }
        }
    }

#if os(iOS) || os(tvOS)

    func image() -> UIImage {
        if ( self.cachedImage == nil ) {
            let imageFrame = CGRectMake(0, 0, 400, 300)
            let imageView = UIView(frame: imageFrame)
            imageView.opaque = true
            imageView.userInteractionEnabled = false

            self.renderInView(imageView, withTheme:nil, animated: false)
            imageView.layoutIfNeeded()

            let boundsSize = imageView.bounds.size

            UIGraphicsBeginImageContextWithOptions(boundsSize, true, 0.0)

            let context = UIGraphicsGetCurrentContext()

            CGContextSetAllowsAntialiasing(context, true)

            for subView in imageView.subviews {
                if subView is CPTGraphHostingView {
                    let hostingView = subView as! CPTGraphHostingView
                    let frame = hostingView.frame

                    CGContextSaveGState(context)

                    CGContextTranslateCTM(context, frame.origin.x, frame.origin.y + frame.size.height)
                    CGContextScaleCTM(context, 1.0, -1.0)
                    hostingView.hostedGraph?.layoutAndRenderInContext(context!)

                    CGContextRestoreGState(context)
                }
            }
            
            CGContextSetAllowsAntialiasing(context, false)
            
            self.cachedImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsEndImageContext()
        }
        
        return self.cachedImage
    }

#else // OSX

    func image() -> NSImage {
        if ( self.cachedImage == nil ) {
            let imageFrame = CGRectMake(0, 0, 400, 300)

            let imageView = NSView(frame: NSRectFromCGRect(imageFrame))
            imageView.setWantsLayer(true)

            self.renderInView(imageView, withTheme:nil, animated: false)

            let boundsSize = imageFrame.size

            let layerImage = NSBitmapImageRep(bitmapDataPlanes:NULL,
                                            pixelsWide: boundsSize.width,
                                            pixelsHigh: boundsSize.height,
                                            bitsPerSample:8,
                                            samplesPerPixel:4,
                                            hasAlpha:true,
                                            isPlanar:false,
                                            colorSpaceName:NSCalibratedRGBColorSpace,
                                            bytesPerRow: boundsSize.width * 4,
                                            bitsPerPixel: 32)

            let bitmapContext = NSGraphicsContext(bitmapImageRep:layerImage)
            let context = bitmapContext.graphicsPort

            CGContextClearRect( context, CGRectMake(0.0, 0.0, boundsSize.width, boundsSize.height) )
            CGContextSetAllowsAntialiasing(context, true)
            CGContextSetShouldSmoothFonts(context, false)
            imageView.layer.renderInContext(context)
            CGContextFlush(context)

            self.cachedImage = NSImage(size:NSSizeFromCGSize(boundsSize))
            self.cachedImage.addRepresentation(layerImage)
        }
        
        return self.cachedImage
    }
#endif

    func applyTheme(theme: CPTTheme?, toGraph graph: CPTGraph, withDefault defaultTheme: CPTTheme?) {
        graph.applyTheme(theme ?? defaultTheme)
    }

#if !os(iOS) && !os(tvOS)

    func setFrameSize(size: NSSize) {

    }
#endif

    func renderInView(inView: PlotGalleryNativeView, withTheme theme: CPTTheme?, animated: Bool) {

        killGraph()

        let hostingView = CPTGraphHostingView(frame: inView.bounds)

        inView.addSubview(hostingView)

#if os(iOS) || os(tvOS)
        hostingView.translatesAutoresizingMaskIntoConstraints = false
        inView.addConstraint(NSLayoutConstraint(item:hostingView,
                                                           attribute: .Left,
                                                           relatedBy: .Equal,
                                                              toItem: inView,
                                                           attribute: .Left,
                                                          multiplier: 1.0,
                                                            constant: 0.0))
        inView.addConstraint(NSLayoutConstraint(item:hostingView,
                                                           attribute: .Top,
                                                           relatedBy: .Equal,
                                                              toItem:inView,
                                                           attribute: .Top,
                                                          multiplier: 1.0,
                                                            constant: 0.0))
        inView.addConstraint(NSLayoutConstraint(item:hostingView,
                                                           attribute: .Right,
                                                           relatedBy: .Equal,
                                                              toItem: inView,
                                                           attribute: .Right,
                                                          multiplier: 1.0,
                                                            constant: 0.0))
        inView.addConstraint(NSLayoutConstraint(item:hostingView,
                                                           attribute: .Bottom,
                                                           relatedBy: .Equal,
                                                              toItem: inView,
                                                           attribute: .Bottom,
                                                          multiplier: 1.0,
                                                            constant: 0.0))
#else
        hostingView.autoresizingMask = NSViewWidthSizable | NSViewHeightSizable
        hostingView.setAutoresizesSubviews(true)
#endif

        self.generateData()
        self.renderInGraphHostingView(hostingView, withTheme: theme, animated: animated)
        
        formatAllGraphs()
        
        self.defaultLayerHostingView = hostingView
    }

    func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {
        NSLog("PlotItem:renderInLayer: Override me")
    }

    func reloadData() {
        for graph in graphs {
            graph.reloadData()
        }
    }

//MARK: - IKImageBrowserItem methods

#if !os(iOS) && !os(tvOS)

    func imageUID() -> String {
        return self.title
    }

    func imageRepresentationType() -> String {
        return IKImageBrowserNSImageRepresentationType
    }

    func imageRepresentation() -> AnyObject {
        return self.image()
    }

    func imageTitle() -> String {
        return self.title
    }
#endif

}
