#include <math.h>
#import "UIImage+.h"
#import "Tweak.h"
#import "NSString+split.h"
#import <NSTask.h>
#define W [UIScreen mainScreen].bounds.size.width
#define H [UIScreen mainScreen].bounds.size.height

static UIWindow *uv2;
static UILabel *labe;
static NSTimer *timer;
static NSString *rtnStr = @"";
static UIWindow *uv;
static float slideValue = 1.0;
static UISwitch *sw;
static NSString *nowLaunchName = @"NONE";
static UILabel *labelNowLaunching;
static float cpu_usage = 0.0;
static UIScrollView *us;
static NSMutableArray *checkChange = [@[] mutableCopy];    
static NSMutableArray *bundleids = [@[] mutableCopy];

static NSArray *removeids = [NSArray arrayWithObjects:
        @"com.apple.Spotlight",
        @"com.apple.SafariViewService",
        @"com.apple.Screenshots", 
        @"com.apple.iMessageAppsViewService", 
        @"com.apple.InCallService" , 
        @"com.apple.iTunes" , 
        @"com.apple.webapp" , 
        @"com.apple.ios.StoreKitUIService" , 
nil];

inline NSString *substring(NSString *a,int b) {
    NSString *str2 = [a substringFromIndex:b];
    return str2;
}

@interface UIApplication ()
- (BOOL)launchApplicationWithIdentifier:(NSString *)identifier suspended:(BOOL)suspend;
@end

@interface SpringBoard : UIApplication

- (BOOL)isLocked;
- (SBApplication *)_accessibilityRunningApplications;
- (SBApplication *)_accessibilityFrontMostApplication;
-(NSString *)launchCommand:(NSString *)command option:(int)option;
-(void)makeTimersInstance;
-(void)movePoint:(UIPanGestureRecognizer*)uigr view:(UIView*)view;
-(UILabel *)makeLabel:(NSString *)text size:(CGRect)size;
-(UIScrollView *)makeScrollView:(CGRect)size viewSize:(CGRect)view;
-(NSMutableArray *)backgroundApplicationsBundleId;
-(int)checkBackgroundApplicationsCount:(NSMutableArray *)array;
-(NSMutableArray *)backgroundApplicationsIconArray:(NSMutableArray *)bundleids;
-(BOOL)checkChangeArray:(NSMutableArray *)before after:(NSMutableArray *)after;
-(UIButton *)makeButton:(CGRect)rect title:(NSString *)title;
-(UIWindow *)makeWindow:(CGRect)rect cornerRadius:(int)radius alpha:(float)alpha;
-(UISwitch *)makeSwitch:(CGPoint)point on:(BOOL)on;
-(UISlider *)makeSlider:(CGRect)rect min:(float)min max:(float)max def:(float)def;
-(id)makeRecognizer:(SEL)method gesture:(int)ges;

@end

%hook SpringBoard

%new
-(NSMutableArray *)backgroundApplicationsIconArray:(NSMutableArray *)bundleids {
    NSMutableArray *icons = [@[] mutableCopy];    
    for(NSString *bundle in bundleids) {
        UIImage *texture = [UIImage _applicationIconImageForBundleIdentifier:bundle format:2];
        if(texture == nil) continue;
        UIImageView *textureImageView = [[UIImageView alloc] initWithImage:texture]; 
        [icons addObject:textureImageView];
    }
    return icons;
}

%new
-(NSMutableArray *)backgroundApplicationsBundleId{
    SpringBoard *spring = (SpringBoard *)[UIApplication sharedApplication];
    SBApplication *sb = [spring _accessibilityRunningApplications];
    NSMutableArray *bundleIDs = [NSMutableArray array];
    for(SBApplication *a in (NSArray *)sb){
        [bundleIDs addObject:[a bundleIdentifier]];
        for(NSString *remove in removeids) {
            [bundleIDs removeObject:remove];
        }
    }
    return bundleIDs;
}

%new
-(int)checkBackgroundApplicationsCount:(NSMutableArray *)array {
    int count = array.count;
    int ans = floor((double)count/(double)4);
    return ans <= 1 ? 2 : ans+1;
}

%new
-(void)killBackgroundTask:(id)a {
    SpringBoard *spring = (SpringBoard *)[UIApplication sharedApplication];
    SBApplication *sb = [spring _accessibilityRunningApplications];
    for(SBApplication *a in (NSArray*)sb) {
        SBApplicationProcessState *ab = [a processState];
        NSString *x = [self launchCommand:[NSString stringWithFormat:@"kill %d",ab.pid] option:2];
        NSLog(@"%@",x);
    }
}

%new
-(NSString *)launchCommand:(NSString *)command option:(int)option {

    NSTask *task  = [[NSTask alloc] init];
    NSPipe *pipe  = [[NSPipe alloc] init];
    NSPipe *errPipe = [NSPipe pipe];
    [task setStandardError:errPipe];
    [task setLaunchPath: @"/bin/sh"];
    [task setArguments: [NSArray arrayWithObjects:@"-c",command,nil]];
    [task setStandardOutput:pipe];
    [task launch];
    NSData *data = [[pipe fileHandleForReading] readDataToEndOfFile];
    NSData *errdata = [[errPipe fileHandleForReading] readDataToEndOfFile];
    NSString *result = [[NSString alloc] initWithData:data
encoding:NSUTF8StringEncoding];
    NSString *resulterr = [[NSString alloc] initWithData:errdata
encoding:NSUTF8StringEncoding];
    NSString *result1 = @"";

    return option == 0 ? resulterr.length < 2 ? result1 = result : result1 = resulterr : result;

}

%new
-(void)makeTimersInstance {
     timer = [NSTimer scheduledTimerWithTimeInterval:slideValue target:self
     selector:@selector(time:)
     userInfo:nil
     repeats:YES];
}

%new
-(UILabel *)makeLabel:(NSString *)text size:(CGRect)size {
    UILabel *label = [[UILabel alloc] init];
    label.frame = size;
    label.textColor = [UIColor blackColor];
    //label.textAlignment = NSTextAlignmentCenter;
    label.text = text;
    label.adjustsFontSizeToFitWidth = YES;
    label.minimumScaleFactor = 0.1f;
    return label;
}

%new
-(UIScrollView *)makeScrollView:(CGRect)size viewSize:(CGRect)view {
    UIScrollView *sv = [[UIScrollView alloc] initWithFrame:size];
    sv.backgroundColor = [UIColor blueColor];
    UIView *uv = [[UIView alloc] init];
    uv.frame = view;
    [sv addSubview:uv];
    sv.contentSize = uv.bounds.size;
    return sv;
}

%new
-(UIButton *)makeButton:(CGRect)rect title:(NSString *)title {
    UIButton *btn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
    btn.frame = rect;
    [btn setTitle:title forState:UIControlStateNormal];
    [btn addTarget:self action:@selector(killBackgroundTask:) forControlEvents:UIControlEventTouchDown];
    return btn;
}

%new
-(UIWindow *)makeWindow:(CGRect)rect cornerRadius:(int)radius alpha:(float)alpha {
    UIWindow *uv = [[UIWindow alloc] init];
    uv.frame = rect;
    uv.backgroundColor = [UIColor whiteColor];
    uv.layer.cornerRadius = radius;
    uv.alpha = alpha;
    uv.windowLevel = 100000000;
    return uv;
}
%new 
-(UISwitch *)makeSwitch:(CGPoint)point on:(BOOL)on {
    UISwitch *sw = [[UISwitch alloc] init];
    sw.center = point;
    sw.on = on;
    [sw addTarget:self action:@selector(timerFire:) forControlEvents:UIControlEventValueChanged];
    return sw;
}
%new
-(UISlider *)makeSlider:(CGRect)rect min:(float)min max:(float)max def:(float)def {
    UISlider *sl = [[UISlider alloc] initWithFrame:rect];
    sl.minimumValue = min; 
    sl.maximumValue = max;
    sl.value = def;
    [sl addTarget:self action:@selector(slider:)
    forControlEvents:UIControlEventValueChanged];
    return sl;
}
%new 
-(id)makeRecognizer:(SEL)method gesture:(int)ges {
    if(ges == 1) {
        UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:method];
        return pangr;
    }else{
        UITapGestureRecognizer *tapGestureh = [[UITapGestureRecognizer alloc] initWithTarget:self action:method];
        return tapGestureh;
    }
}
- (void)applicationDidFinishLaunching:(id)x {
    %orig;
    UILabel *label = [self makeLabel:@"Set interval" size:CGRectMake(0,9,W/6, 13)];
    UILabel *labelsw = [self makeLabel:@"ON/OFF" size:CGRectMake(0,40,W/6, 13)];
    labelNowLaunching = [self makeLabel:nowLaunchName size:CGRectMake(W/4-W/12,75,W/6, 13)];
    us = [self makeScrollView:CGRectMake(0,W/4,W/2,W/4) viewSize:CGRectMake(0,W/2,W/2,W/4)];
    UIButton *btn = [self makeButton:CGRectMake(0,75,W/6,13) title:@"Kill"];
    uv = [self makeWindow:CGRectMake(W/2,0,W/2,W/2) cornerRadius:5 alpha:0.0];
    sw = [self makeSwitch:CGPointMake(W/3,50) on:YES];
    UISlider *sl = [self makeSlider:CGRectMake(W/4,10,W/4, 10) min:0.01 max:2.0 def:0.5];
    uv2 = [self makeWindow:CGRectMake(W/2,0, 50, 50) cornerRadius:25 alpha:1.0];
    labe = [self makeLabel:@"0%" size:CGRectMake(3, 0, 50, 50)];
    NSArray *ar = [NSArray arrayWithObjects:label,labelsw, labelNowLaunching,us,btn,sw,sl, nil];
    UIPanGestureRecognizer *pangr = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan:)];
    UIPanGestureRecognizer *pangr2 = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(handlePan2:)];
    UITapGestureRecognizer *tapGestureh = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(taph:)];
    for(id object in ar) {
        [uv addSubview:object];
    }
    [uv2 addGestureRecognizer:tapGestureh];
    [uv2 addGestureRecognizer:pangr];
    [uv addGestureRecognizer:pangr2];
    [uv2 addSubview:labe];
    [uv2 makeKeyAndVisible];
    [uv makeKeyAndVisible];
    [self makeTimersInstance];
}

%new
-(void)timerFire:(id)a {
    if([timer isValid] == 0) {
        labe.text = @"0.0";
        labelNowLaunching.text = @"";
        [self makeTimersInstance];
    }else{
        [timer invalidate];
        labe.text = @"Stoped";
        labelNowLaunching.text = @"Stoped";
    }
}

%new
-(void)slider:(UISlider *)sender {
    slideValue = sender.value;
    [timer invalidate];
    BOOL value = sw.on;
    if(value) {
        [self makeTimersInstance];
    }
}

%new
-(void)taph:(UITapGestureRecognizer *)sender {
    if(uv.alpha == 0.0) {
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{        
            uv.alpha = 1.0;
        } completion:^(BOOL finished) {
        }];
    }else{
        [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{        
            uv.alpha = 0.0;
        } completion:^(BOOL finished) {
        }];
    }
}

%new 
-(BOOL)checkChangeArray:(NSMutableArray *)before after:(NSMutableArray *)after {
    int a = 0;
    if(before.count == after.count) {
        for(int i=0;i<before.count;i++) {
            NSString *bef = [before objectAtIndex:i];
            NSString *aft = [after objectAtIndex:i];
            if([bef isEqualToString:aft]) {
                a++;
            }
        }
        return a == before.count ? NO : YES;
    }
    return YES;
}

%new
-(void)time:(id)a {
    SpringBoard *springBoard = (SpringBoard *)[UIApplication sharedApplication];
    SBApplication *SB_B = [springBoard _accessibilityFrontMostApplication];
    labelNowLaunching.text = [SB_B displayName];
    SBApplicationProcessState *aa = [SB_B processState];
    rtnStr = [NSString stringWithFormat:@"ps -p %d -o %@",aa.pid,@"%cpu"];
    bundleids = [self backgroundApplicationsBundleId];
    int count = [self checkBackgroundApplicationsCount:bundleids];
    if([self checkChangeArray:checkChange after:bundleids]) {
        us = nil;
        us = [self makeScrollView:CGRectMake(0,W/4,W/2,W/4) viewSize:CGRectMake(0,W/2,W/2,count*45)];
        NSMutableArray *icons = [self backgroundApplicationsIconArray:bundleids];
        int cnt = 0,stageup = 0,c=1;
        for(UIImageView *icon in icons) {
            if((cnt % 4) == 0) {
                cnt = 0;
                stageup++;
            }
            icon.userInteractionEnabled = YES;
            UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(launchApplicationevent:)];
            [icon addGestureRecognizer:tap];
            icon.frame = CGRectMake(7+W/8*cnt,5+40*(stageup-1),35,35);
            icon.tag = c;
            icon.layer.masksToBounds = YES;
            icon.layer.cornerRadius = 7;
            [us addSubview:icon];
            cnt++;c++;
        }
        [uv addSubview:us];
    }
    NSString *result = [self launchCommand:rtnStr option:2];
    NSString *check2 = @"";
    if(result.length > 7) {
        NSString *chec = substring(result,6);
        cpu_usage = [chec floatValue];
        if(cpu_usage <= 10) {
            labelNowLaunching.textColor = [UIColor blueColor];
        }
        else if(cpu_usage <= 50 && cpu_usage > 10) {
            labelNowLaunching.textColor = [UIColor greenColor];
        }
        else if(cpu_usage <= 100 && cpu_usage > 50) {
            labelNowLaunching.textColor = [UIColor orangeColor];
        }
        else if(cpu_usage > 100) {
            labelNowLaunching.textColor = [UIColor redColor];
        }
        check2 = [NSString stringWithFormat:@"%@%@",chec,@"％"];
    }else{
        check2 = @"None";
        labelNowLaunching.text = check2;
    }
    labe.text = check2;
    checkChange = bundleids;
}

%new
- (void)launchApplicationevent:(UITapGestureRecognizer *)gesture{
    if(gesture.view.tag == 0)return;
    [[UIApplication sharedApplication]  launchApplicationWithIdentifier:[bundleids objectAtIndex:gesture.view.tag-1] suspended:FALSE];
    [UIView animateWithDuration:0.2f delay:0.0f options:UIViewAnimationOptionCurveEaseIn animations:^{        
        uv.alpha = 0.0;
    } completion:^(BOOL finished) {
    }];
}

%new
-(void)movePoint:(UIPanGestureRecognizer*)uigr view:(UIView*)view {
    CGPoint delta = [uigr translationInView:view];
    CGPoint movedPoint = CGPointMake(view.center.x + delta.x, view.center.y + delta.y);
    view.center = movedPoint;
    [uigr setTranslation:CGPointZero inView: view];
}

%new
-(void)handlePan:(UIPanGestureRecognizer*)uigr {
    [self movePoint:uigr view:uv2];
}

%new
-(void)handlePan2:(UIPanGestureRecognizer*)uigr {
    [self movePoint:uigr view:uv];
}
%end

/*
/var/mobile/appcpuusageviewer
*/