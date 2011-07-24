//
//  GameStatistics.mm
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GameStatistics.h"

@implementation GameStatistics

@synthesize ballFlings, ballBounces, startTime, endTime, levelStarted, levelTitle;

static GameStatistics* sharedGameStatistics = nil;

+ (GameStatistics *) sharedGameStatistics {
	@synchronized(self)     {
		if (!sharedGameStatistics)
			sharedGameStatistics = [[GameStatistics alloc] init];
	}
	return sharedGameStatistics;
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
