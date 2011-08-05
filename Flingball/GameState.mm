//
//  GameState.mm
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GameState.h"

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
        
        // listen out for game center action!
        [[NSNotificationCenter defaultCenter] addObserver: self selector: @selector(authenticationChanged) name: GKPlayerAuthenticationDidChangeNotificationName object: nil];
        
        [self reset];
    }
    
    return self;
}

-(void) dealloc {
    [values release];
    values = nil;
    
    [super dealloc];
}

-(void) reset {
    [values removeAllObjects];
}

-(double) getElapsedTime {
    double elapsedTime;
    if ([self getValueAsDouble:@"endTime"] > 0) {
        elapsedTime = [self getValueAsDouble:@"endTime"] - [self getValueAsDouble:@"startTime"];
    } else {
        elapsedTime = [NSDate timeIntervalSinceReferenceDate] - [self getValueAsDouble:@"startTime"];
    }
    return elapsedTime;
}

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

-(void) addFling {
    NSInteger flings = [[self getValue: @"ballFlings"] intValue] +1;
    [self updateKey: @"ballFlings" withInt: flings];
}

-(void) addBounce {
    NSInteger flings = [[self getValue: @"ballBounces"] intValue] +1;
    [self updateKey: @"ballBounces" withInt: flings];
}

# pragma mark Game Center stuff

-(void) authenticateLocalUser {
    NSLog(@"checking local user state");
    if ([GKLocalPlayer localPlayer].authenticated == NO) {
        NSLog(@"authing local user...");
        [[GKLocalPlayer localPlayer] authenticateWithCompletionHandler: nil];
    }
}

-(void) authenticationChanged {
    dispatch_async(dispatch_get_main_queue(), ^(void) {
        gameCenterAuthed = [GKLocalPlayer localPlayer].isAuthenticated;
    });
}

@end
