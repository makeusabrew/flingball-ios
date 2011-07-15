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

- (id)init
{
    self = [super init];
    if (self) {
        radius = 20.0;
        sprite = [CCSprite spriteWithFile:@"pickup.png" rect:CGRectMake(0, 0, radius*2, radius*2)];
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
        [[NSNotificationCenter defaultCenter] postNotificationName:@"ballHitPickup" object:self];
    }
}

@end
