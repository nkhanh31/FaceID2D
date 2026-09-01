#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>
#import <Vision/Vision.h>

// Khai bao cac interface an cua SpringBoard
@interface SBLockScreenManager : NSObject
+ (id)sharedInstance;
- (BOOL)isUILocked;
- (void)unlockUIFromSource:(int)arg1 withOptions:(id)arg2;
- (void)start2DFaceScan;
@end

static BOOL isEnabled = YES;

// Ham doc cai dat tu Preferences
static void loadPrefs() {
    NSDictionary *prefs = [[NSDictionary alloc] initWithContentsOfFile:@"/var/mobile/Library/Preferences/com.yourname.faceid2d.plist"];
    if (prefs) {
        isEnabled = [prefs objectForKey:@"isEnabled"] ? [[prefs objectForKey:@"isEnabled"] boolValue] : YES;
    }
}

%hook SBLockScreenManager

- (void)_setBacklightLevel:(double)arg1 keepTime:(double)arg2 deductFromSystemSleep:(BOOL)arg3 unlock:(BOOL)arg4 {
    %orig;
    
    // Khi man hinh sang len va thiet bi dang khoa
    if (arg1 > 0.0 && [self isUILocked] && isEnabled) {
        [self start2DFaceScan];
    }
}

%new
- (void)start2DFaceScan {
    // Quet camera an o Background Thread
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        // Logic Vision se duoc dua vao day o buoc sau
    });
}

%end

%ctor {
    loadPrefs();
}
