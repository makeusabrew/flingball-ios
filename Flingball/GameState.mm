//
//  GameState.mm
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GameState.h"

@implementation GameState

@synthesize ballFlings, ballBounces, startTime, endTime, levelStarted, levelTitle;

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
        [self reset];
    }
    
    return self;
}

-(void) reset {
    ballFlings = ballBounces = startTime = endTime = 0;
    levelStarted = NO;
    levelTitle = @"";
}

-(double) getElapsedTime {
    double elapsedTime;
    if (endTime > 0) {
        elapsedTime = endTime - startTime;
    } else {
        elapsedTime = [NSDate timeIntervalSinceReferenceDate] - startTime;
    }
    return elapsedTime;
}

@end
