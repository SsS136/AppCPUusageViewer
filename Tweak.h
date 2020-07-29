#import <spawn.h>
#import <Foundation/Foundation.h>
#include <stdlib.h>
@interface SBApplicationProcessState

@property(nonatomic, readonly) int pid;

@end

@interface SBApplicationController

-(NSArray *)runningApplications;

@end

@interface SBApplication : NSObject

@property(nonatomic, readonly) SBApplicationProcessState *processState;

- (void)setActivationSetting:(NSUInteger)fp8 flag:(BOOL)fp12;
- (void)setActivationSetting:(NSUInteger)fp8 value:(id)fp12;
- (void)setDeactivationSetting:(NSUInteger)fp8 flag:(BOOL)fp12;
- (id)bundleIdentifier;
- (NSString *)displayIdentifier;
- (BOOL)shouldLaunchPNGless;
- (BOOL)showsProgress;
- (BOOL)isRunning;

-(id)processState;
-(NSString *)displayName;
@end

@interface SBSyncController

-(void) _killApplicationsIfNecessary;

@end

@interface SBApplicationInfo

- (NSString*) displayName;

@end


@interface SBMediaController : NSObject

- (BOOL)isPlaying;
- (SBApplication*)nowPlayingApplication;

@end

@interface SBAppLayout : NSObject

@property(nonatomic, copy) NSDictionary *rolesToLayoutItemsMap;

@end