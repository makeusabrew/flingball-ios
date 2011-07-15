//
//  Polygon.h
//  Flingball
//
//  Created by Nicholas Payne on 13/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"
#import "Box2D.h"

@interface Polygon : Entity {
    //NSInteger vertexCount;
    //NSMutableArray *vertices;
    
    b2BodyDef bodyDef;    
    b2PolygonShape shapeDef;    
    b2FixtureDef fixtureDef;
}

@property b2BodyDef bodyDef;
@property b2PolygonShape shapeDef;
@property b2FixtureDef fixtureDef;


-(void) createForWorld: (b2World*)world;

@end
