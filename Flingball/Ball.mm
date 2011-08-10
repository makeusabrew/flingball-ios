//
//  Ball.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"
#import "Polygon.h"
#import "GameState.h"

@implementation Ball

@synthesize atGoal;

- (id)init
{
    self = [super init];
    if (self) {
        atGoal = NO;
        sprite = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius:(float32)_radius {
    self = [super initWithPosition: _position forWorld: world withRadius: _radius];
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
        shapeDef.friction = 0.4f;
        shapeDef.restitution = 0.5f;
        body->CreateFixture(&shapeDef);
        
        [self setPosition: _position];
        
    }
    
    return self;
}

-(void) fling:(b2Vec2)vector {
    // this is nothing more than an alias now really
    [self applyImpulse: vector];
}

-(void) applyImpulse:(b2Vec2)vector {
    body->ApplyLinearImpulse(vector, body->GetPosition());  
}

-(void) onCollisionStart:(Entity *)target {
    if ([target isKindOfClass:[Polygon class]]) {
        // add bounce, but only if we're currently 'active'
        if ([[GameState sharedGameState] getValueAsInt: @"ballFlings"] > 0 && atGoal == NO) {
            [[GameState sharedGameState] addBounce];
        }
    }
}

-(void) onCollision:(Entity *)target {
    // each bounce seems to trigger two collisions so we need
    // this variable to be an integer. It's not ideal but it'll
    // do for now
    if (inContactTicks > 2) {
        [self doRollingFriction];
    }
    inContactTicks++;
}

-(void) onCollisionEnd:(Entity *)target {
    inContactTicks = 0;
}

-(void) doRollingFriction {
    float32 v = body->GetAngularVelocity();
    if (v > 0) {
        v -= BALL_ROLLING_FRICTION;
    } else if (v < 0) {
        v += BALL_ROLLING_FRICTION;
    }
    if (abs(v) <= BALL_ROLLING_FRICTION) {
        v = 0.0f;
    }
    body->SetAngularVelocity(v);
}

-(BOOL) canFling {
    b2Vec2 v = body->GetLinearVelocity();
    return (v.x < FLING_SPEED_THRESHOLD && v.y < FLING_SPEED_THRESHOLD);
}

@end