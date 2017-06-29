

#import <UIKit/UIKit.h>
#import <AudioToolbox/AudioToolbox.h>

@class SectionsViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
    UIWindow *window;
    SectionsViewController *viewController;
}
+(void)playSound:(int)soundID;
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet SectionsViewController *viewController;

@end

