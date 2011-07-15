//
//  Ball.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"
#import "SimpleAudioEngine.h"
#import "Polygon.h"
#import "GameStatistics.h"

@implementation Ball

@synthesize atGoal, radius;

- (id)init
{
    self = [super init];
    if (self) {
        radius = 32.0;  // @todo obviously change this!
        atGoal = NO;
        sprite = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, radius*2, radius*2)];
        [[SimpleAudioEngine sharedEngine] preloadEffect:@"goal.wav"];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world {
    self = [self init];
    if (self) {
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.userData = self;
        bodyDef.angularDamping = 0.1f;
        body = world->CreateBody(&bodyDef);
        
        b2CircleShape circle;
        circle.m_radius = radius/PTM_RATIO;
        
        b2FixtureDef shapeDef;
        shapeDef.shape = &circle;
        shapeDef.density = 1.0f;
        shapeDef.friction = 0.2f;
        shapeDef.restitution = 0.7f;
        body->CreateFixture(&shapeDef);
        
        [self setPosition: _position];
        
    }
    
    return self;
}

- (void)fling:(b2Vec2)vector {
    body->ApplyLinearImpulse(vector, body->GetPosition());
    [[SimpleAudioEngine sharedEngine] playEffect:@"boing.wav"];
    [GameStatistics sharedGameStatistics].ballFlings ++;
}

-(void) onCollisionStart:(Entity *)target {
    if ([target isKindOfClass:[Polygon class]]) {
        // add bounce, but only if we're currently 'active'
        if ([GameStatistics sharedGameStatistics].ballFlings > 0 && atGoal == NO) {
            [GameStatistics sharedGameStatistics].ballBounces ++;
        }
    }
}

-(void) onCollision:(Entity *)target {
    
}

@end