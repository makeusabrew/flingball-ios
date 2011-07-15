//
//  GameStatistics.h
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameStatistics : NSObject {
    NSInteger ballFlings;
    NSInteger ballBounces;
    
    NSTimeInterval startTime;
    NSTimeInterval endTime;
}

@property NSInteger ballFlings;
@property NSInteger ballBounces;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;

+ (GameStatistics *) sharedGameStatistics;
-(void) reset;

@end
