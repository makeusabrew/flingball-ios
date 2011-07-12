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
        // amazing!
        NSLog(@"Goal reached!");
    }
}

@end
