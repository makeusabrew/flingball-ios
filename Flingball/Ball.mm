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

#pragma mark init methods
- (id)init
{
    self = [super init];
    if (self) {
        atGoal = NO;
        sprite = [CCSprite spriteWithSpriteFrameName:@"ball.png"];
        distanceMoved.SetZero();
        lastPosition.SetZero();
        currentState = BALL_STOPPED;
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

#pragma mark update methods

- (void)updateBody:(b2Body *)b withDelta:(ccTime)dt {
    // can't find a clean method of tracking distance - using velocity etc
    // doesn't seem to work. So we have to keep track of the *last* position
    // and then take a manual delta. Less than ideal.
    distanceMoved.x += fabs(b->GetPosition().x - lastPosition.x);
    distanceMoved.y += fabs(b->GetPosition().y - lastPosition.y);
    lastPosition = b->GetPosition();
    
    if (currentState == BALL_STOPPED) {
        if ([self isMoving]) {
            CCLOG(@"Ball started moving");
            currentState = BALL_MOVING;
        }
    } else if (currentState == BALL_MOVING) {
        if (![self isMoving]) {
            CCLOG(@"Ball stopped moving");
            currentState = BALL_STOPPED;
            b2Vec2 flingDistance = b->GetPosition() - lastFlingPosition;
            
            if (flingDistance.y > 0.00) {
                heightGained += flingDistance.y;
                
                if ([[GameState sharedGameState] getAchievementPercentage: ACHIEVEMENT_EVEREST] < 100.0) {
                    // @see https://projects.paynedigital.com/issues/206
                    if (heightGained >= ACHIEVEMENT_EVEREST_HEIGHT) {
                        CCLOG(@"got everest achievement!");
                        [[GameState sharedGameState] reportAchievementIdentifier: ACHIEVEMENT_EVEREST percentComplete:100.0];
                    } else {
                        float32 pc = (heightGained / ACHIEVEMENT_EVEREST_HEIGHT) * 100.0f;
                        [[GameState sharedGameState] reportAchievementIdentifier:ACHIEVEMENT_EVEREST percentComplete:pc];
                        CCLOG(@"Everest percentage [%.2f]", pc);
                    }
                }
            }
            CCLOG(@"fling distance [%.2f, %.2f]", flingDistance.x, flingDistance.y);
        }
    }
    
    [super updateBody:b withDelta: dt];
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

#pragma mark Query methods

-(BOOL) isMoving {
    b2Vec2 v = body->GetLinearVelocity();
    return (v.x != 0 || v.y != 0);
    
}

-(BOOL) canFling {
    b2Vec2 v = body->GetLinearVelocity();
    return (v.x <= FLING_SPEED_THRESHOLD && v.y <= FLING_SPEED_THRESHOLD);
}

-(BOOL) canApplySpin {
    double timeSinceFling = [NSDate timeIntervalSinceReferenceDate] - lastFlingTime;
    return (timeSinceFling <= MAX_SPIN_TIME);
}

#pragma mark User interactions

-(void) applySpin:(float32) v {
    float32 cv = body->GetAngularVelocity();
    cv += v;
    body->SetAngularVelocity(cv);
}

-(void) fling:(b2Vec2)vector {
    // record the fling time
    lastFlingTime = [NSDate timeIntervalSinceReferenceDate];
    lastFlingPosition = body->GetPosition();
    [self applyImpulse: vector];
}

-(void) applyImpulse:(b2Vec2)vector {
    body->ApplyLinearImpulse(vector, body->GetPosition());  
}

#pragma mark Collision Handlers

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

@end