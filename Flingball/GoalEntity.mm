//
//  GoalEntity.m
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GoalEntity.h"
#import "Ball.h"
#import "Constants.h"

@implementation GoalEntity

- (id)init
{
    self = [super init];
    if (self) {
        radius = 64.0;
        sprite = [CCSprite spriteWithFile:@"goal.png" rect:CGRectMake(0, 0, radius*2, radius*2)];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world {
    self = [self init];
    if (self) {        
        
        b2BodyDef bodyDef;
        bodyDef.userData = self;
        
        body = world->CreateBody(&bodyDef);
        
        b2CircleShape circle;
        circle.m_radius = radius/PTM_RATIO;
        
        b2FixtureDef shapeDef;
        shapeDef.shape = &circle;
        shapeDef.isSensor = true;
        body->CreateFixture(&shapeDef);
        
        [self setPosition: _position];        
    }
    
    return self;
}

-(void) onCollision:(Entity *)target {
    if ([target class] == [Ball class]) {
        Ball* ball = (Ball*) target;
        
        float32 dx = [ball getX] - [self getX];
        float32 dy = [ball getY] - [self getY];
        float32 dist = sqrt((dx*dx) + (dy*dy));
        
        // if the ball is *entirely* within the goal's radius
        if (dist < radius - [ball radius]) {
            [[NSNotificationCenter defaultCenter] postNotificationName:@"ballAtGoal" object:self];
        }
    }
}

@end
