//
// PlotGalleryController.h
// CorePlotGallery
//

@import Cocoa;
//#import <CorePlot/CorePlot.h>
@import Quartz;

#import "PlotView.h"

@class PlotItem;

@interface PlotGalleryController : NSObject<NSSplitViewDelegate,
                                            NSCollectionViewDelegate,
                                            NSCollectionViewDataSource,
                                            PlotViewDelegate>

@property (nonatomic, strong, nullable) PlotItem *plotItem;
@property (nonatomic, copy, nullable) NSString *currentThemeName;

-(IBAction)themeSelectionDidChange:(nonnull id)sender;

@end
