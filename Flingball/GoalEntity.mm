//
//  GoalEntity.m
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GoalEntity.h"
#import "Ball.h"

@implementation GoalEntity

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
    }
    
    return self;
}

-(void) onCollision:(Entity *)target {
    if ([target class] == [Ball class]) {
        // for now, goal radius = 64
        // ball radius = 32. ok?
        
        float32 dx = [target getX] - [self getX];
        float32 dy = [target getY] - [self getY];
        float32 dist = sqrt((dx*dx) + (dy*dy));
        
        if (dist < 64 - (32)) {
            NSLog(@"At goal!");
        }
    }
}

@end
