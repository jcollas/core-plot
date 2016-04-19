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
        return titles.sort { $0.lowercaseString < $1.lowercaseString }
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

    func addPlotItem(plotItem: PlotItem) {
        plotItems.append(plotItem)
        plotSections.addObject(plotItem.section!)
    }

    func numberOfRowsInSection(section: Int) -> Int {
        return plotSections.countForObject(sectionTitles[section])
    }

    func objectInSection(section: Int, atIndex index: Int) -> PlotItem {
        var offset = 0

        for i in 0..<section {
            offset += numberOfRowsInSection(i)
        }

        return self.plotItems[offset + index]
    }

    func sortByTitle() {
        plotItems.sortInPlace { $0.titleCompare($1) == .OrderedAscending }
    }

}
