//
// ImageDemo.m
// Plot Gallery
//

import CorePlot

class ImageDemo: PlotItem {

    override class func initialize() {
        super.registerPlotItem(self)
    }

    required init() {
        super.init()
        title = "Image Demo"
        section = kDemoPlots
    }

    override func renderInGraphHostingView(hostingView: CPTGraphHostingView, withTheme theme: CPTTheme?, animated: Bool) {

#if os(iOS)
        let bounds = hostingView.bounds
#else
        let bounds = NSRectToCGRect(hostingView.bounds)
#endif

        // Create graph
        let graph = CPTXYGraph(frame: bounds)
        self.addGraph(graph, toHostingView: hostingView)
        self.applyTheme(theme, toGraph: graph, withDefault: CPTTheme(named: kCPTSlateTheme))

        graph.fill = CPTFill(color: CPTColor.darkGrayColor())

        graph.plotAreaFrame?.fill = CPTFill(color: CPTColor.lightGrayColor())
        graph.plotAreaFrame?.paddingTop    = self.titleSize
        graph.plotAreaFrame?.paddingBottom = self.titleSize * 2.0
        graph.plotAreaFrame?.paddingLeft   = self.titleSize * 2.0
        graph.plotAreaFrame?.paddingRight  = self.titleSize * 2.0
        graph.plotAreaFrame?.cornerRadius  = self.titleSize * 2.0

        graph.axisSet?.axes = nil

        let textStyle = CPTMutableTextStyle()
        textStyle.fontName      = "Helvetica"
        textStyle.fontSize      = self.titleSize * 0.5
        textStyle.textAlignment = .Center

        let thePlotArea = graph.plotAreaFrame?.plotArea

        // Note
        var titleLayer = CPTTextLayer(text: "Standard images have a blue tint.\nHi-res (@2x) images have a green tint.\n@3x images have a red tint.", style: textStyle)
        let titleAnnotation = CPTLayerAnnotation(anchorLayer: thePlotArea!)
        titleAnnotation.rectAnchor         = .Top
        titleAnnotation.contentLayer       = titleLayer
        titleAnnotation.contentAnchorPoint = CGPoint(x: 0.5, y: 1.0)
        thePlotArea?.addAnnotation(titleAnnotation)

        textStyle.color = CPTColor.darkGrayColor()

        // Tiled
        titleLayer = CPTTextLayer(text:"Tiled image", style: textStyle)
        let fillImage = CPTImage(named: "Checkerboard")
        fillImage.tiled = true
        titleLayer.fill = CPTFill(image: fillImage)
        titleLayer.paddingLeft   = self.titleSize
        titleLayer.paddingRight  = self.titleSize
        titleLayer.paddingTop    = self.titleSize * 4.0
        titleLayer.paddingBottom = self.titleSize * 0.25

        var annotation = CPTLayerAnnotation(anchorLayer: thePlotArea!)
        annotation.rectAnchor         = .BottomLeft
        annotation.contentLayer       = titleLayer
        annotation.contentAnchorPoint = CGPoint(x: 0.0, y: 0.0)
        thePlotArea?.addAnnotation(annotation)

        // Stretched
        titleLayer = CPTTextLayer(text: "Stretched image", style: textStyle)
        fillImage.tiled          = false
        titleLayer.fill = CPTFill(image: fillImage)
        titleLayer.paddingLeft   = self.titleSize
        titleLayer.paddingRight  = self.titleSize
        titleLayer.paddingTop    = self.titleSize * 4.0
        titleLayer.paddingBottom = self.titleSize * 0.25

        if let anchorLayer = graph.plotAreaFrame?.plotArea {
            annotation = CPTLayerAnnotation(anchorLayer: anchorLayer)
            annotation.rectAnchor = .BottomRight
            annotation.contentLayer       = titleLayer
            annotation.contentAnchorPoint = CGPoint(x: 1.0, y: 0.0)
            graph.plotAreaFrame?.plotArea?.addAnnotation(annotation)
        }
    }

}
