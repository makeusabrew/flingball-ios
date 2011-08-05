//
//  GameState.mm
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GameState.h"
#import "Constants.h"

@implementation GameState

static GameState* sharedGameState = nil;

+ (GameState *) sharedGameState {
	@synchronized(self)     {
		if (!sharedGameState) {
			[[self alloc] init];
        }
        return sharedGameState;
	}
	return nil;
}

+(id) alloc {
    @synchronized ([GameState class]) {
        NSAssert(sharedGameState == nil, @"Attempted to allocate second instance of GameState singleton");
        sharedGameState = [super alloc];
        return sharedGameState;
    }
    return nil;
}

- (id)init
{
    self = [super init];
    if (self) {
        values = [[NSMutableDictionary alloc] init];
        achievements = [[NSMutableDictionary alloc] init];
        
        // listen out for game center action!
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(authenticationChanged) name: GKPlayerAuthenticationDidChangeNotificationName object: nil];
        
        [self reset];
    }
    
    return self;
}

-(void) dealloc {
    [values release];
    values = nil;
    
    [achievements release];
     achievements = nil;
    
    [super dealloc];
}

-(void) reset {
    [values removeAllObjects];
}

# pragma mark Core setters

-(void) updateKey: (NSString*)str withValue:(id) value {
    [values setValue: value forKey: str];
}

-(void) updateKey: (NSString*)str withInt:(int) value {
    [values setValue: [NSNumber numberWithInt: value] forKey: str];
}

-(void) updateKey: (NSString*)str withDouble:(double) value {
    [values setValue: [NSNumber numberWithDouble: value] forKey: str];
}

-(void) updateKey: (NSString*)str withBool:(BOOL) value {
    [values setValue: [NSNumber numberWithBool: value] forKey: str];
}

#pragma mark Core getters

-(id) getValue: (NSString*)key {
    return [values valueForKey: key];
}

-(double) getValueAsDouble: (NSString*) key {
    return [[values valueForKey: key] doubleValue];
}

-(int) getValueAsInt: (NSString*) key {
    return [[values valueForKey: key] intValue];
}
-(BOOL) getValueAsBool:(NSString *)key {
    return [[values valueForKey: key] boolValue];
}

#pragma mark Helpful wrapper methods

-(void) addFling {
    NSInteger flings = [[self getValue: STATE_FLINGS] intValue] +1;
    [self updateKey: STATE_FLINGS withInt: flings];
}

-(void) addBounce {
    NSInteger flings = [[self getValue: STATE_BOUNCES] intValue] +1;
    [self updateKey: STATE_BOUNCES withInt: flings];
}

-(double) getElapsedTime {
    double elapsedTime;
    if ([self getValueAsDouble: STATE_ENDTIME] > 0) {
        elapsedTime = [self getValueAsDouble: STATE_ENDTIME] - [self getValueAsDouble: STATE_STARTTIME];
    } else {
        elapsedTime = [NSDate timeIntervalSinceReferenceDate] - [self getValueAsDouble: STATE_STARTTIME];
    }
    return elapsedTime;
}

# pragma mark Game Center stuff

-(void) authenticateLocalUser {
    NSLog(@"checking local user state");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        NSLog(@"authing local user...");
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"error authenticating user");
                return;
            }
            
            NSLog(@"authenticated user, loading achievements");
            if ([GKLocalPlayer localPlayer].authenticated) {
                [GKAchievement loadAchievementsWithCompletionHandler:^(NSArray *_achievements, NSError *error) {
                    if (error != nil) {
                        NSLog(@"error loading achievements");
                    }
                    NSLog(@"loaded achievements");
                    for (GKAchievement *achievement in _achievements) {
                        NSLog(@"loading achievement %@ with percentage %.2f", achievement.identifier, achievement.percentComplete);
                        [achievements setValue: achievement forKey: achievement.identifier]; 
                    }
                }];
            }
            
            /* DEBUG - use to reset achievements
            [GKAchievement resetAchievementsWithCompletionHandler:^(NSError *error) {
                if (error != nil) {
                    NSLog(@"error resetting achievements");
                    return;
                }
                NSLog(@"reset achievements");
            }];
            */
        }];
    }
}

-(void) authenticationChanged {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        gameCenterAuthed = [GKLocalPlayer localPlayer].isAuthenticated;
    });
}

-(void) reportAchievementIdentifier:(NSString *)identifier percentComplete:(float)percent {
    GKAchievement *achievement = [[[GKAchievement alloc] initWithIdentifier: identifier] autorelease];
    if (achievement) {
        achievement.percentComplete = percent;
        NSLog(@"updating achievement %@ with value %.2f", achievement.identifier, achievement.percentComplete);
        [achievements setValue: achievement forKey: achievement.identifier];
        [achievement reportAchievementWithCompletionHandler:^(NSError *error) {
            if (error != nil) {
                NSLog(@"error reporting identifier %@ with percentage %.2f", identifier, percent);
            }
        }];
    }
}

-(double) getAchievementPercentage:(NSString *)identifier {
    GKAchievement *achievement = [achievements objectForKey: identifier];
    if (achievement == nil) {
        NSLog(@"returning zero value for non existant achievement %@", identifier);
        return 0.0;
    }
    return achievement.percentComplete;
}

@end
