#import <UIKit/UIKit.h>
#import <AVFoundation/AVFoundation.h>

static NSTimer *autoTimer = nil;
static NSTimer *keepAlive = nil;
static int step = 0;
static BOOL done = NO;
static UIView *tapCircle = nil;
static UILabel *watermark = nil;

UIWindow* getActiveWindow() {
    if (@available(iOS 13.0, *)) {
        for (UIScene *scene in [UIApplication sharedApplication].connectedScenes) {
            if (scene.activationState == UISceneActivationStateForegroundActive) {
                UIWindowScene *windowScene = (UIWindowScene *)scene;
                return windowScene.windows.firstObject;
            }
        }
    }
    #pragma clang diagnostic push
    #pragma clang diagnostic ignored "-Wdeprecated-declarations"
    return [[UIApplication sharedApplication] keyWindow];
    #pragma clang diagnostic pop
}

void showTapCircle(CGFloat x, CGFloat y) {
    UIWindow *win = getActiveWindow();
    if (!win) return;

    if (tapCircle) {
        [tapCircle removeFromSuperview];
        tapCircle = nil;
    }

    CGFloat size = 60;
    tapCircle = [[UIView alloc] initWithFrame:CGRectMake(x - size/2, y - size/2, size, size)];
    tapCircle.backgroundColor = [UIColor colorWithRed:1.0 green:0.2 blue:0.2 alpha:0.6];
    tapCircle.layer.cornerRadius = size/2;
    tapCircle.layer.borderWidth = 3;
    tapCircle.layer.borderColor = [UIColor whiteColor].CGColor;
    tapCircle.userInteractionEnabled = NO;

    CABasicAnimation *pulse = [CABasicAnimation animationWithKeyPath:@"transform.scale"];
    pulse.fromValue = @1.0;
    pulse.toValue = @1.3;
    pulse.duration = 0.3;
    pulse.autoreverses = YES;
    pulse.repeatCount = 2;
    [tapCircle.layer addAnimation:pulse forKey:@"pulse"];

    [win addSubview:tapCircle];

    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(1.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        if (tapCircle) {
            [UIView animateWithDuration:0.3 animations:^{
                tapCircle.alpha = 0;
            } completion:^(BOOL finished) {
                [tapCircle removeFromSuperview];
                tapCircle = nil;
            }];
        }
    });
}

void showWatermark() {
    UIWindow *win = getActiveWindow();
    if (!win || watermark) return;

    watermark = [[UILabel alloc] initWithFrame:CGRectMake(10, 50, 320, 30)];
    watermark.text = @"🎙️ Coconote AutoRecording ACTIVE";
    watermark.textColor = [UIColor greenColor];
    watermark.font = [UIFont boldSystemFontOfSize:14];
    watermark.backgroundColor = [UIColor colorWithRed:0 green:0 blue:0 alpha:0.7];
    watermark.layer.cornerRadius = 5;
    watermark.clipsToBounds = YES;
    watermark.userInteractionEnabled = NO;

    [win addSubview:watermark];
}

void updateWatermark(NSString *text) {
    if (watermark) {
        dispatch_async(dispatch_get_main_queue(), ^{
            watermark.text = text;
        });
    }
}

void tap(CGFloat x, CGFloat y) {
    CGPoint p = CGPointMake(x, y);
    UIWindow *win = getActiveWindow();
    if (!win) return;

    showTapCircle(x, y);

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
        case 0: 
            updateWatermark(@"🎙️ Step 1/6: Continue (1/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 1: 
            updateWatermark(@"🎙️ Step 2/6: Continue (2/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:1.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 2: 
            updateWatermark(@"🎙️ Step 3/6: Continue (3/3)");
            tap(w*0.5, h*0.65); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.5 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 3: 
            updateWatermark(@"🎙️ Step 4/6: New Note");
            tap(w*0.75, h*0.92); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 4: 
            updateWatermark(@"🎙️ Step 5/6: Record Audio");
            tap(w*0.5, h*0.35); 
            step++; 
            autoTimer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:[NSObject new] selector:@selector(nextStep) userInfo:nil repeats:NO]; 
            break;
        case 5: 
            updateWatermark(@"🎙️ Step 6/6: Start Recording");
            tap(w*0.5, h*0.85); 
            step++; 
            done = YES;
            [[UIApplication sharedApplication] setIdleTimerDisabled:YES];
            keepAlive = [NSTimer scheduledTimerWithTimeInterval:30 repeats:YES block:^(NSTimer *t) { }];
            updateWatermark(@"🎙️ RECORDING - 1hr+ mode");
            break;
    }
}

%hook UIApplication
- (void)applicationDidBecomeActive:(UIApplication *)application {
    %orig;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(0.5 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        showWatermark();
    });
    if (!done && step == 0) {
        updateWatermark(@"🎙️ Starting in 3s...");
        dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(3.0 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
            nextStep();
        });
    }
}
%end

__attribute__((constructor)) static void init() { }
