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

        NotificationCenter.default.addObserver(self, selector: #selector(themeChanged(_:)), name:Notification.Name(PlotGalleryThemeDidChangeNotification), object:nil)
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

//        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NotificationCenter.default.removeObserver(self)
    }

    // MARK: - Segues

    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if segue.identifier == "showDetail" {
            let controller = (segue.destination as! UINavigationController).topViewController as! DetailViewController

            controller.navigationItem.leftBarButtonItem = self.splitViewController?.displayModeButtonItem
            controller.navigationItem.leftItemsSupplementBackButton = true

            controller.currentThemeName = self.currentThemeName

            if let indexPath = self.tableView.indexPathForSelectedRow {

                let plotItem = PlotGallery.sharedPlotGallery.objectInSection(indexPath.section, atIndex: indexPath.row)

                controller.detailItem = plotItem
            }
        }
    }

    // MARK: - Theme Selection

    func themeChanged(_ notification: Notification) {
        let themeInfo = notification.userInfo

        if let themeName = themeInfo?[PlotGalleryThemeNameKey] as? String {
            self.currentThemeName = themeName
        }
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return Int(PlotGallery.sharedPlotGallery.numberOfSections)
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return Int(PlotGallery.sharedPlotGallery.numberOfRowsInSection(section))
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "PlotCell", for: indexPath)

        let plotItem = PlotGallery.sharedPlotGallery.objectInSection(indexPath.section, atIndex: indexPath.row)

        cell.imageView?.image = plotItem.image()
        cell.textLabel?.text  = plotItem.title

        return cell
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return PlotGallery.sharedPlotGallery.sectionTitles[section]
    }

}
