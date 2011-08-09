//
//  Vortex.m
//  Flingball
//
//  Created by Nicholas Payne on 09/08/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//  @see https://projects.paynedigital.com/issues/223

#import "Vortex.h"
#import "Constants.h"

@implementation Vortex

@synthesize pullStrength;

#pragma mark init methods

- (id)init
{
    self = [super init];
    if (self) {
        sprite = [CCSprite spriteWithSpriteFrameName:@"goal.png"];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius: (float32)_radius {
    self = [super initWithPosition: _position forWorld: world withRadius: _radius];
    if (self) {
        CGRect spriteRect = [sprite textureRect];
        [sprite setScaleX: radius / spriteRect.size.width];
        [sprite setScaleY: radius / spriteRect.size.height];
        
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

@end
