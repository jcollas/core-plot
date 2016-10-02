//
// AppDelegate.m
// CorePlotGallery
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplicationLaunchOptionsKey: Any]?) -> Bool {

        // initialize the charts.
        _ = ColoredBarChart()
        _ = VerticalBarChart()

        _ = AxisDemo()
        _ = LabelingPolicyDemo()
        _ = CompositePlot()
        _ = ImageDemo()
        _ = LineCapDemo()
        _ = PlotSpaceDemo()

        _ = CandlestickPlot()
        _ = OHLCPlot()
        _ = RangePlot()

        _ = ControlChart()
        _ = CurvedInterpolationDemo()
        _ = CurvedScatterPlot()
        _ = DatePlot()
        _ = GradientScatterPlot()
        _ = FunctionPlot()
        _ = RealTimePlot()
        _ = SimpleScatterPlot()
        _ = SteppedScatterPlot()

        _ = DonutChart()
        _ = SimplePieChart()

        PlotGallery.sharedPlotGallery.sortByTitle()

        let splitViewController = self.window!.rootViewController as! UISplitViewController
        splitViewController.delegate = self

        let navigationController = splitViewController.viewControllers.last as? UINavigationController
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem

        return true
    }

}

//MARK: - UISplitViewControllerDelegate

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(_ splitViewController: UISplitViewController, collapseSecondary secondaryViewController:UIViewController, onto primaryViewController:UIViewController) -> Bool {

        if let
            navController = secondaryViewController as? UINavigationController,
            let detailViewController = navController.topViewController as? DetailViewController {

            // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            if detailViewController.detailItem == nil {
                return true
            }
        }

        return false

    }

}
