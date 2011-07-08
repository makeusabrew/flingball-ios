//
//  Ball.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Ball.h"
#import "Constants.h"

@implementation Ball

- (id)init
{
    self = [super init];
    if (self) {
        sprite = [CCSprite spriteWithFile:@"ball.png" rect:CGRectMake(0, 0, 64, 64)];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)position forWorld: (b2World*)world {
    self = [self init];
    if (self) {
        
        b2BodyDef bodyDef;
        bodyDef.type = b2_dynamicBody;
        bodyDef.userData = self;
        bodyDef.angularDamping = 0.1f;
        body = world->CreateBody(&bodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 32.0/PTM_RATIO;
        
        b2FixtureDef shapeDef;
        shapeDef.shape = &circle;
        shapeDef.density = 1.0f;
        shapeDef.friction = 0.2f;
        shapeDef.restitution = 0.7f;
        body->CreateFixture(&shapeDef);
        
        [self setPosition: position];
    }
    
    return self;
}

- (void)setPosition: (b2Vec2)position {
    b2Vec2 ptmPos = b2Vec2(position.x / PTM_RATIO, position.y / PTM_RATIO);
    body->SetTransform(ptmPos, 0);
    
    [self setSpritePosition:position withAngle:0];
}

- (void)setSpritePosition:(b2Vec2)position withAngle:(float)angle {
    sprite.position = ccp(position.x, position.y);
    sprite.rotation = angle;
}

- (void)fling:(b2Vec2)vector {
    body->ApplyLinearImpulse(vector, body->GetPosition());
}

- (void)dealloc {
    body = NULL;
    
    [super dealloc];
}

@end
