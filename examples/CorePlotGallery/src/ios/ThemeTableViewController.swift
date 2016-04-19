//
// ThemeTableViewController.m
// CorePlotGallery
//

import UIKit
import CorePlot

let kThemeTableViewControllerNoTheme      = "None"
let kThemeTableViewControllerDefaultTheme = "Default"

let PlotGalleryThemeDidChangeNotification = "PlotGalleryThemeDidChangeNotification"
let PlotGalleryThemeNameKey               = "PlotGalleryThemeNameKey"

class ThemeTableViewController: UITableViewController {

    var themes: [String] = []

    func setupThemes() {
        var themeList: [String] = []

        themeList.append(kThemeTableViewControllerDefaultTheme)
        themeList.append(kThemeTableViewControllerNoTheme)

        for themeClass in CPTTheme.themeClasses() ?? [] {
            themeList.append(themeClass.name())
        }

        self.themes = themeList
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupThemes()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

       self.setupThemes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themes.count
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("ThemeCell", forIndexPath: indexPath)

        cell.textLabel?.text = self.themes[indexPath.row]

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        let themeInfo = [PlotGalleryThemeNameKey: self.themes[indexPath.row]]

        NSNotificationCenter.defaultCenter().postNotificationName(PlotGalleryThemeDidChangeNotification,
                                                        object: self,
                                                      userInfo: themeInfo)

        self.dismissViewControllerAnimated(true, completion: nil)
    }

}
