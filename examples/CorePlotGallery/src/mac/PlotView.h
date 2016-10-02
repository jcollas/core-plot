//
// PlotView.h
// CorePlotGallery
//

@import Cocoa;

@protocol PlotViewDelegate<NSObject>

-(void)setFrameSize:(NSSize)newSize;

@end

@interface PlotView : NSView<PlotViewDelegate>
@property (nonatomic, weak, nullable) id<PlotViewDelegate> delegate;

@end
