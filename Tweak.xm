#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static NSTimer *autoTimer = nil;
static NSTimer *keepAlive = nil;
static int step = 0;
static BOOL done = NO;

void tap(CGFloat x, CGFloat y) {
    CGPoint p = CGPointMake(x, y);
    UIWindow *win = [[UIApplication sharedApplication] keyWindow];
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
}

void nextStep() {
    UIScreen *s = [UIScreen mainScreen];
    CGFloat w = s.bounds.size.width, h = s.bounds.size.height;
    switch(step) {
        case 0: tap(w*0.5, h*0.65); step++; autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; break;
        case 1: tap(w*0.5, h*0.65); step++; autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.2 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; break;
        case 2: tap(w*0.5, h*0.65); step++; autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; break;
        case 3: tap(w*0.75, h*0.92); step++; autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; break;
        case 4: tap(w*0.5, h*0.35); step++; autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; break;
        case 5: tap(w*0.5, h*0.85); step++; done = YES;
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            keepAlive = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer *t) { NSLog(@"[Coconote] Alive"); }];
            NSLog(@"[Coconote] Recording started - 1hr+ mode"); break;
    }
}

%hook UIApplication
- (void)applicationDidBecomeActive:(id)app {
    %orig;
    if (!done && step == 0) dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(2.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{ nextStep(); });
}
%end

__attribute__((constructor)) static void init() { NSLog(@"[Coconote] Loaded"); }
