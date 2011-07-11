//
//  Level.mm
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 __MyCompanyName__. All rights reserved.
//

#import "Level.h"
#import "Constants.h"

@implementation Level

@synthesize world, ball;

- (id)init
{
    self = [super init];
    if (self) {
		gravity.Set(0.0f, -10.0f);
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
        
        CGRect rect = CGRectMake(0, 0, 1024, 768);
        [self createBoundaries:rect];        
        
        ball = [[Ball alloc] initWithPosition:b2Vec2(100, 300) forWorld:world];

        
        // temporary block stuff
        
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(600 / PTM_RATIO, 400 / PTM_RATIO);
        
        b2Body *blockBody = world->CreateBody(&blockBodyDef);
        
        b2PolygonShape blockShape;
        blockShape.SetAsBox(0.25, 4.0);
        
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &blockShape;
        blockShapeDef.density = 10.0;
        blockShapeDef.friction = 1.5;
        blockShapeDef.restitution = 0.1f;
        
        blockBody->CreateFixture(&blockShapeDef);
    }
    
    return self;
}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
    
    [ball dealloc];
    ball = NULL;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

- (void)createBoundaries:(CGRect)rect {
    // Define the ground body.
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    
    // Call the body factory which allocates memory for the ground body
    // from a pool and creates the ground box shape (also from a pool).
    // The body is also added to the world.
    b2Body* groundBody = world->CreateBody(&groundBodyDef);
    
    // Define the ground box shape.
    b2PolygonShape groundBox;		
    
    // bottom
    groundBox.SetAsEdge(b2Vec2(rect.origin.x, rect.origin.y), b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y));
    groundBody->CreateFixture(&groundBox,0);
    
    // top
    groundBox.SetAsEdge(b2Vec2(rect.origin.x, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x, rect.origin.y + rect.size.height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(rect.origin.x, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x, rect.origin.y));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y));
    groundBody->CreateFixture(&groundBox,0);

}

@end
