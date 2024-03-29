//
//  Pickup.mm
//  Flingball
//
//  Created by Nicholas Payne on 14/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Pickup.h"
#import "Constants.h"
#import "Ball.h"

@implementation Pickup

#pragma mark init methods

- (id)init
{
    self = [super init];
    if (self) {
        sprite = [CCSprite spriteWithSpriteFrameName:@"pickup.png"];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius:(float32)_radius {
    self = [super initWithPosition: _position forWorld: world withRadius: _radius];
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

#pragma mark collision callbacks

-(void) onCollision:(Entity *)target {
    if (dead) {
        return;
    }
    if ([target class] == [Ball class]) {
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ballHitPickup" object:self];
    }
}

@end
