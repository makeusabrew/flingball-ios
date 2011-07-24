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
    
    BOOL levelStarted;
    
    NSString* levelTitle;
}

@property NSInteger ballFlings;
@property NSInteger ballBounces;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property BOOL levelStarted;
@property (nonatomic, copy) NSString* levelTitle;

+ (GameStatistics *) sharedGameStatistics;
-(void) reset;
-(double) getElapsedTime;

@end
