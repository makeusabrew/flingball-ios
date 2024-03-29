//
//  Polygon.mm
//  Flingball
//
//  Created by Nicholas Payne on 13/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Polygon.h"
#import "Constants.h"

@implementation Polygon

@synthesize bodyDef, shapeDef, fixtureDef;

#pragma mark add to world

-(void) createForWorld: (b2World*)world {
    CCLOG(@"adding polygon to world at %.2f, %.2f", bodyDef.position.x, bodyDef.position.y);
    
    // we assume that we've only set our bodyDef's position, and strictly speaking
    // our position gets updated the minute we start to tick() but make sure it
    // starts off correctly too
    position.Set(bodyDef.position.x * PTM_RATIO, bodyDef.position.y * PTM_RATIO);
    bodyDef.userData = self;    
    body = world->CreateBody(&bodyDef);    
    fixtureDef.shape = &shapeDef;
    body->CreateFixture(&fixtureDef);
}

@end
