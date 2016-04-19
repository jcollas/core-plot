//
// AppDelegate.m
// CorePlotGallery
//

import UIKit

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {

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
        navigationController?.topViewController?.navigationItem.leftBarButtonItem = splitViewController.displayModeButtonItem()

        return true
    }

}

//MARK: - UISplitViewControllerDelegate

extension AppDelegate: UISplitViewControllerDelegate {

    func splitViewController(splitViewController: UISplitViewController, collapseSecondaryViewController secondaryViewController:UIViewController, ontoPrimaryViewController primaryViewController:UIViewController) -> Bool {

        if let
            navController = secondaryViewController as? UINavigationController,
            detailViewController = navController.topViewController as? DetailViewController {

            // Return YES to indicate that we have handled the collapse by doing nothing; the secondary controller will be discarded.
            if detailViewController.detailItem == nil {
                return true
            }
        }

        return false

    }

}
