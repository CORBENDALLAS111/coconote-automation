#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static NSTimer *autoTimer = nil;
static NSTimer *keepAlive = nil;
static int step = 0;
static BOOL done = NO;

// iOS 13+ compatible keyWindow replacement
UIWindow* getActiveWindow() {
    if (@available(iOS 13.0, *)) {
        // Modern approach using UIScene
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                // Return the first window (keyWindow equivalent)
                return windowScene.windows.firstObject;
            }
        }
        // Fallback: try to find key window in any active scene
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                for (UIWindow *window in windowScene.windows) {
                    if (window.isKeyWindow) {
                        return window;
                    }
                }
            }
        }
    }
    // Fallback for older iOS (deprecated but works)
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[UIApplication sharedApplication] keyWindow];
    #pragma clang diagnostic pop
}

void tap(CGFloat x, CGFloat y) {
    CGPoint p = CGPointMake(x, y);
    UIWindow *win = getActiveWindow();

    if (!win) {
        NSLog(@"[Coconote] Error: No active window found");
        return;
    }

    UITouch *touch = [[UITouch alloc] init];
    [touch setValue:[NSValue valueWithCGPoint:p] forKey:@"locationInWindow"];
    [touch setValue:win forKey:@"window"];
    [touch setValue:@(UITouchPhaseBegan) forKey:@"phase"];
    UIEvent *evt = [[UIEvent alloc] init];
    [evt setValue:touch forKey:@"_touch"];
    [win sendEvent:evt];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.1 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        [touch setValue:@(UITouchPhaseEnded) forKey:@"phase"];
        [win sendEvent:evt];
    });

    NSLog(@"[Coconote] Tapped at (%.0f, %.0f)", x, y);
}

void nextStep() {
    UIScreen *s = [UIScreen mainScreen];
    CGFloat w = s.bounds.size.width, h = s.bounds.size.height;

    switch(step) {
        case 0: 
            NSLog(@"[Coconote] Step 1/6: Continue (1/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 1: 
            NSLog(@"[Coconote] Step 2/6: Continue (2/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 2: 
            NSLog(@"[Coconote] Step 3/6: Continue (3/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 3: 
            NSLog(@"[Coconote] Step 4/6: New Note button");
            tap(w*0.75, h*0.92); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 4: 
            NSLog(@"[Coconote] Step 5/6: Record audio");
            tap(w*0.5, h*0.35); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 5: 
            NSLog(@"[Coconote] Step 6/6: Start Recording");
            tap(w*0.5, h*0.85); 
            step++; 
            done = YES;
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            keepAlive = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer *t) { 
                NSLog(@"[Coconote] Keep-alive ping"); 
            }];
            NSLog(@"[Coconote] Recording started - 1hr+ mode enabled"); 
            break;
    }
}

%hook UIApplication
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    if (!done && step == 0) {
        NSLog(@"[Coconote] App active, starting automation in 2.5s...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            nextStep();
        });
    }
}
%end

__attribute__((constructor)) static void init() { 
    NSLog(@"[Coconote] AutoRecording tweak loaded - iOS 26 compatible"); 
}
