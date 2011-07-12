//
//  GoalEntity.m
//  Flingball
//
//  Created by Nicholas Payne on 12/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "GoalEntity.h"
#import "Ball.h"
#import "SimpleAudioEngine.h"
#import "Constants.h"

@implementation GoalEntity

- (id)init
{
    self = [super init];
    if (self) {
        sprite = [CCSprite spriteWithFile:@"goal.png" rect:CGRectMake(0, 0, 128, 128)];
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
        circle.m_radius = 64.0/PTM_RATIO;
        
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
        Ball* ball = (Ball*)target;
        if (ball.atGoal) {
            return;
        }
        
        // for now, goal radius = 64
        // ball radius = 32. ok?
        
        float32 dx = [target getX] - [self getX];
        float32 dy = [target getY] - [self getY];
        float32 dist = sqrt((dx*dx) + (dy*dy));
        
        if (dist < 64 - (32)) {
            ball.atGoal = true;
            [[SimpleAudioEngine sharedEngine] playEffect:@"goal.wav"];
            NSLog(@"At goal!");
        }
    }
}

@end
