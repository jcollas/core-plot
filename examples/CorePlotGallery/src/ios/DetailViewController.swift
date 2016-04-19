//
// DetailViewController.m
// CorePlotGallery
//

import UIKit
import CorePlot

class DetailViewController: UIViewController {

    @IBOutlet weak var hostingView: UIView!
    @IBOutlet weak var themeBarButton: UIBarButtonItem!

    var detailItem: PlotItem? {
        didSet {
            if detailItem != oldValue {
                detailItem?.killGraph()

                if let hostView = self.hostingView {
                    detailItem?.renderInView(hostView, withTheme: self.currentTheme(), animated: true)
                }
            }
        }
    }

    var currentThemeName: String = "None" {
        didSet {
            self.themeBarButton.title = "Theme: \(currentThemeName)"
        }
    }

    // MARK: - Initialization and Memory Management

    func setupView() {

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(themeChanged(_:)), name: PlotGalleryThemeDidChangeNotification, object: nil)

        if let hostView = self.hostingView {
            detailItem?.renderInView(hostView, withTheme: self.currentTheme(), animated: true)
        }

    }

    override func awakeFromNib() {
        super.awakeFromNib()

        self.setupView()
    }

    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: NSBundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)

        self.setupView()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }

    deinit {
        NSNotificationCenter.defaultCenter().removeObserver(self)
    }

    // MARK: - View lifecycle

    override func viewDidAppear(animated: Bool) {
        super.viewDidAppear(animated)

        self.setupView()
    }

    // MARK: - Theme Selection

    func currentTheme() -> CPTTheme? {

        if currentThemeName == kThemeTableViewControllerNoTheme {
            return nil
        }

        if currentThemeName == kThemeTableViewControllerDefaultTheme {
            return nil
        }

        return CPTTheme(named: currentThemeName)
    }

    func themeSelectedWithName(themeName: String) {
        self.currentThemeName = themeName

        if let hostView = self.hostingView {
            detailItem?.renderInView(hostView, withTheme: self.currentTheme(), animated: true)
        }
    }

    func themeChanged(notification: NSNotification) {
        let themeInfo = notification.userInfo

        if let themeName = themeInfo?[PlotGalleryThemeNameKey] as? String {
            self.themeSelectedWithName(themeName)
        }
    }

}
