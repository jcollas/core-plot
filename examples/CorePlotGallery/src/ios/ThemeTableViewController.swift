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
            themeList.append(themeClass.name().rawValue)
        }

        self.themes = themeList
    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupThemes()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

       self.setupThemes()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return self.themes.count
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        let cell = tableView.dequeueReusableCell(withIdentifier: "ThemeCell", for: indexPath)

        cell.textLabel?.text = self.themes[(indexPath as NSIndexPath).row]

        return cell
    }

    // MARK: - Table view delegate

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let themeInfo = [PlotGalleryThemeNameKey: self.themes[(indexPath as NSIndexPath).row]]

        NotificationCenter.default.post(name: Notification.Name(rawValue: PlotGalleryThemeDidChangeNotification),
                                                        object: self,
                                                      userInfo: themeInfo)

        self.dismiss(animated: true, completion: nil)
    }

}
