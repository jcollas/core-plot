#import "AppDelegateTV.h"

#import "Plot_Gallery_tvOS-Swift.h"

@implementation AppDelegateTV

@synthesize window;

-(BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions
{
    PlotItem *temp;

    temp = [[ColoredBarChart alloc] init];
    temp = [[VerticalBarChart alloc] init];

    temp = [[AxisDemo alloc] init];
    temp = [[LabelingPolicyDemo alloc] init];
    temp = [[CompositePlot alloc] init];
    temp = [[ImageDemo alloc] init];
    temp = [[LineCapDemo alloc] init];
    temp = [[PlotSpaceDemo alloc] init];

    temp = [[CandlestickPlot alloc] init];
    temp = [[OHLCPlot alloc] init];
    temp = [[RangePlot alloc] init];

    temp = [[ControlChart alloc] init];
    temp = [[CurvedInterpolationDemo alloc] init];
    temp = [[CurvedScatterPlot alloc] init];
    temp = [[DatePlot alloc] init];
    temp = [[GradientScatterPlot alloc] init];
    temp = [[FunctionPlot alloc] init];
    temp = [[RealTimePlot alloc] init];
    temp = [[SimpleScatterPlot alloc] init];
    temp = [[SteppedScatterPlot alloc] init];

    temp = [[DonutChart alloc] init];
    temp = [[SimplePieChart alloc] init];

    [[PlotGallery sharedPlotGallery] sortByTitle];

    return YES;
}

@end
