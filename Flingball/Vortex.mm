//
//  Vortex.m
//  Flingball
//
//  Created by Nicholas Payne on 09/08/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//  @see https://projects.paynedigital.com/issues/223

#import "Vortex.h"
#import "Constants.h"
#import "Ball.h"

@implementation Vortex

@synthesize pullStrength;

#pragma mark init methods

- (id)init
{
    self = [super init];
    if (self) {
        sprite = [CCSprite spriteWithSpriteFrameName:@"vortex.png"];
    }
    
    return self;
}

- (id)initWithPosition: (b2Vec2)_position forWorld: (b2World*)world withRadius: (float32)_radius {
    self = [super initWithPosition: _position forWorld: world withRadius: _radius];
    if (self) {
        
        CGRect spriteRect = [sprite textureRect];
        [sprite setScaleX: (radius*2) / spriteRect.size.width];
        [sprite setScaleY: (radius*2) / spriteRect.size.height];
        
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

#pragma mark update methods

-(void) updateBody:(b2Body *)b withDelta:(ccTime)dt {
    // why do we need to set position below? It should be set when calling setPosition initially, surely?
    //position.Set(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
    
    b->SetTransform(b2Vec2(b->GetPosition().x, b->GetPosition().y), CC_DEGREES_TO_RADIANS(angle));
    
    float a = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
    [self setSpritePosition: position withAngle: a];
    angle += pullStrength * dt;
}

#pragma mark collision callbacks

-(void) onCollision:(Entity *)target {
    if ([target class] == [Ball class]) {
        Ball* ball = (Ball*) target;
        
        float32 dx = [ball getX] - [self getX];
        float32 dy = [ball getY] - [self getY];
        float32 dist = sqrt((dx*dx) + (dy*dy));
        
        // take off the ball's radius - we care if *any* edge touches
        // here for clarity
        dist -= [ball radius];
        
        // if the ball is anywhere in our radius, take action!
        if (dist < radius) {
            float32 a = atan2f(dy, dx);
            float32 strength = ((radius - dist) / radius) * pullStrength;
            CCLOG(@"vortex strength [%.2f]", strength);
            b2Vec2 v;
            v.x = -(cos(a) * strength);
            v.y = -(sin(a) * strength);
            [ball applyImpulse:v];
        }
    }
}

@end
