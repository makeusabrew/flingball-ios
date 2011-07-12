//
//  Level.mm
//  Flingball
//
//  Created by Nicholas Payne on 11/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Level.h"
#import "Constants.h"
#import "GoalEntity.h"

@implementation Level

@synthesize world, ball, contactListener, goal;

- (id)init
{
    self = [super init];
    if (self) {
        // hard code some stuff for now which would come from a file or whatever
		gravity.Set(0.0f, -10.0f);
        startPos.Set(100, 64);
        endPos.Set(1900, 100);
        width = 1024*2;
        height = 768*2;
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
		
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		
		world->SetContinuousPhysics(true);
        
        contactListener = new ContactListener();
        world->SetContactListener(contactListener);
        
        [self createBoundaries:CGRectMake(0, 0, width, height)];        
        
        ball = [[Ball alloc] initWithPosition:startPos forWorld:world];

        
        // temporary block stuff
        block = [[Entity alloc] init];
        
        b2BodyDef blockBodyDef;
        blockBodyDef.type = b2_staticBody;
        blockBodyDef.position.Set(600 / PTM_RATIO, 400 / PTM_RATIO);
        blockBodyDef.userData = block;
        
        b2Body *blockBody = world->CreateBody(&blockBodyDef);
        
        b2PolygonShape blockShape;
        blockShape.SetAsBox(0.25, 4.0);
        
        b2FixtureDef blockShapeDef;
        blockShapeDef.shape = &blockShape;
        blockShapeDef.density = 10.0;
        blockShapeDef.friction = 1.0;
        blockShapeDef.restitution = 0.1f;
        
        blockBody->CreateFixture(&blockShapeDef);
        
        // temporary end goal
        goal = [[GoalEntity alloc] initWithPosition:endPos forWorld:world];

    }
    
    return self;
}

- (void)createBoundaries:(CGRect)rect {
    // Define the ground body.
    
    // temporary
    bounds = [[Entity alloc] init];
    
    b2BodyDef groundBodyDef;
    groundBodyDef.position.Set(0, 0); // bottom-left corner
    groundBodyDef.userData = bounds;
    
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
    groundBox.SetAsEdge(b2Vec2(rect.origin.x, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y + rect.size.height/PTM_RATIO));
    groundBody->CreateFixture(&groundBox,0);
    
    // left
    groundBox.SetAsEdge(b2Vec2(rect.origin.x, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x, rect.origin.y));
    groundBody->CreateFixture(&groundBox,0);
    
    // right
    groundBox.SetAsEdge(b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y + rect.size.height/PTM_RATIO), b2Vec2(rect.origin.x + rect.size.width/PTM_RATIO, rect.origin.y));
    groundBody->CreateFixture(&groundBox,0);

}

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
    
    delete contactListener;
    contactListener = NULL;
    
    [ball dealloc];
    ball = NULL;
    
    [bounds dealloc];
    [block dealloc];
    [goal dealloc];
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
