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
		if (!sharedGameState)
			sharedGameState = [[GameState alloc] init];
	}
	return sharedGameState;
}

- (id)init
{
    self = [super init];
    if (self) {
        values = [[NSMutableDictionary alloc] init];
        
        // N.B not yet used
        allowedKeys = [[NSArray alloc] initWithObjects: 
                       @"ballFlings", 
                       @"ballBounces",
                       @"starTime",
                       @"endTime",
                       @"levelStarted",
                       @"levelTitle",
                       nil];
        [self reset];
    }
    
    return self;
}

-(void) dealloc {
    [values release];
    values = nil;
    [allowedKeys release];
    allowedKeys = nil;
    
    [super dealloc];
}

-(void) reset {
    [values setValue: 0 forKey: @"ballFlings"];
    [values setValue: 0 forKey: @"ballBounces"];
    [values setValue: 0 forKey: @"startTime"];
    [values setValue: 0 forKey: @"endTime"];
    [values setValue: 0 forKey: @"levelStarted"];
    [values setValue: 0 forKey: @"currentLevel"];
    [values setValue: @"" forKey: @"levelTitle"];
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

@end
