//
// PlotGallery.m
// CorePlotGallery
//

import Foundation
import CorePlot

class PlotGallery: NSObject {

    var plotItems: [PlotItem] = []
    var plotSections: NSCountedSet = NSCountedSet()

    var count: Int {
        return plotItems.count
    }

    var numberOfSections: Int {
        return plotSections.count
    }

    var sectionTitles: [String] {
        let titles = plotSections.allObjects as! [String]
        return titles.sorted { $0.lowercased() < $1.lowercased() }
    }

    class var sharedPlotGallery: PlotGallery {
        struct Static {
            static let instance = PlotGallery()
        }
        return Static.instance
    }

    override init() {
        super.init()
    }

    func addPlotItem(_ plotItem: PlotItem) {
        plotItems.append(plotItem)
        plotSections.add(plotItem.section!)
    }

    func numberOfRowsInSection(_ section: Int) -> Int {
        return plotSections.count(for: sectionTitles[section])
    }

    func objectInSection(_ section: Int, atIndex index: Int) -> PlotItem {
        var offset = 0

        for i in 0..<section {
            offset += numberOfRowsInSection(i)
        }

        return self.plotItems[offset + index]
    }

    func sortByTitle() {
        plotItems.sort { $0.titleCompare($1) == .orderedAscending }
    }

}
