//
// RootViewController.m
// CorePlotGallery
//

import UIKit

class RootViewController: UITableViewController {

    var currentThemeName: String = "None"

    override func viewDidLoad() {
        super.viewDidLoad()

        self.clearsSelectionOnViewWillAppear = false

        self.currentThemeName = kThemeTableViewControllerDefaultTheme

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(themeChanged(_:)), name:PlotGalleryThemeDidChangeNotification, object:nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

//        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - Segues

    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {

        if segue.identifier == "showDetail" {
            let controller = (segue.destinationViewController as! UINavigationController).topViewController as! DetailViewController

            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem()
            controller.navigationItem.leftItemsSupplementBackButton = true

            controller.currentThemeName = self.currentThemeName

            let indexPath = self.tableView.indexPathForSelectedRow

            let plotItem = PlotGallery.sharedPlotGallery.objectInSection(indexPath!.section,
                                                                          atIndex: indexPath!.row)

            controller.detailItem = plotItem
        }
    }

    // MARK: - Theme Selection

    func themeChanged(notification: NSNotification) {
        let themeInfo = notification.userInfo

        if let themeName = themeInfo?[PlotGalleryThemeNameKey] as? String {
            self.currentThemeName = themeName
        }
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return Int(PlotGallery.sharedPlotGallery.numberOfSections)
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(PlotGallery.sharedPlotGallery.numberOfRowsInSection(section))
    }

    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCellWithIdentifier("PlotCell", forIndexPath: indexPath)

        let plotItem = PlotGallery.sharedPlotGallery.objectInSection(indexPath.section, atIndex: indexPath.row)

        cell.imageView?.image = plotItem.image()
        cell.textLabel?.text  = plotItem.title

        return cell
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return PlotGallery.sharedPlotGallery.sectionTitles[section]
    }

}
