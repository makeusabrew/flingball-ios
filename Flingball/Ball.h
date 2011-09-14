//
//  Ball.h
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "CircleEntity.h"

@interface Ball : CircleEntity
{
    BOOL atGoal;
    NSInteger inContactTicks; // crude way of determining "on the floor" (ish)
    double lastFlingTime;
}

@property BOOL atGoal;

-(void) fling: (b2Vec2)vector;
-(void) applyImpulse: (b2Vec2)vector;
-(void) doRollingFriction;
-(BOOL) canFling;
-(BOOL) isMoving;
-(BOOL) canApplySpin;
-(void) applySpin:(float32)v;

@end
