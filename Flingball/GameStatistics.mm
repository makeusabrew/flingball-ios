//
//  GameStatistics.mm
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GameStatistics.h"

@implementation GameStatistics

@synthesize ballFlings, ballBounces, startTime, endTime;

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
        // Initialization code here.
    }
    
    return self;
}

-(void) reset {
    ballFlings = ballBounces = startTime = endTime = 0;
}

@end
