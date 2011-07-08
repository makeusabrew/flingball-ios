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
        
        b2BodyDef ballBodyDef;
        ballBodyDef.type = b2_dynamicBody;
        ballBodyDef.userData = self;
        body = world->CreateBody(&ballBodyDef);
        
        b2CircleShape circle;
        circle.m_radius = 32.0/PTM_RATIO;
        
        b2FixtureDef ballShapeDef;
        ballShapeDef.shape = &circle;
        ballShapeDef.density = 1.0f;
        ballShapeDef.friction = 0.2f;
        ballShapeDef.restitution = 0.8f;
        body->CreateFixture(&ballShapeDef);
        
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
