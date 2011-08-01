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
#import "CJSONDeserializer.h"

@implementation Level

@synthesize world, ball, contactListener, goal;

- (id)init
{
    self = [super init];
    if (self) {
		
		// Do we want to let bodies sleep?
		// This will speed up the physics simulation
		bool doSleep = true;
        // prep our contact listener which we'll attach to the world in a min
		contactListener = new ContactListener();
        
		// Construct a world object, which will hold and simulate the rigid bodies.
		world = new b2World(gravity, doSleep);
		world->SetContinuousPhysics(true);        
        world->SetContactListener(contactListener);
    }
    
    return self;
}

-(void) loadLevel:(NSInteger)levelIndex {
    
    entities = [[NSMutableArray alloc] init];
    
    NSString *str = [NSString stringWithFormat:@"level%d", levelIndex];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:str ofType:@"json"];
    NSData *levelData = [NSData dataWithContentsOfFile:filePath];
    
    CCLOG(@"Loading level data from file [%@] for level [%d]", filePath, levelIndex);
    
    NSError *jsonError = nil;
    NSDictionary* jsonObject = [[CJSONDeserializer deserializer] deserialize:levelData error:&jsonError];
    
    // hello title
    title = [NSString stringWithString: [jsonObject objectForKey:@"title"]];
    
    // dimensions first
    width = [[[jsonObject objectForKey:@"dimensions"] objectForKey:@"width"] intValue];
    height = [[[jsonObject objectForKey:@"dimensions"] objectForKey:@"height"] intValue];
    
    CCLOG(@"parsed dimensions [%d, %d]", width, height);
    [self createBoundaries:CGRectMake(0, 0, width, height)];
    
    // then gravity
    gravity.Set(
        [[[jsonObject objectForKey:@"gravity"] objectForKey:@"x"] floatValue],
        [[[jsonObject objectForKey:@"gravity"] objectForKey:@"y"] floatValue]
    );
    
    CCLOG(@"parsed gravity [%.2f, %.2f]", gravity.x, gravity.y);
    world->SetGravity(gravity);
    
    // now start & end positions
    startPos.Set(
        [[[jsonObject objectForKey:@"start"] objectForKey:@"x"] floatValue],
        [[[jsonObject objectForKey:@"start"] objectForKey:@"y"] floatValue]
    );
    
    CCLOG(@"parsed ball start pos [%.2f, %.2f]", startPos.x, startPos.y);
    ball = [[Ball alloc] initWithPosition:startPos forWorld:world];
    
    endPos.Set(
        [[[jsonObject objectForKey:@"end"] objectForKey:@"x"] floatValue],
        [[[jsonObject objectForKey:@"end"] objectForKey:@"y"] floatValue]
    );
    
    float32 goalRadius = DEFAULT_GOAL_RADIUS;
    
    if ([[jsonObject objectForKey:@"end"] objectForKey:@"radius"] != nil) {
        goalRadius = [[[jsonObject objectForKey:@"end"] objectForKey:@"radius"] floatValue];
    }
    
    CCLOG(@"parsed goal position [%.2f, %.2f] with radius [%.2f]", endPos.x, endPos.y, goalRadius);
    goal = [[GoalEntity alloc] initWithPosition:endPos forWorld:world withRadius: goalRadius];
    
    // have we got any poly data?
    NSArray* polyArray = [jsonObject objectForKey:@"polygons"];
    for (NSDictionary* poly in polyArray) {
        b2BodyDef bodyDef;
        bodyDef.position.Set(
            [[[poly objectForKey:@"bodyDef"] objectForKey:@"x"] floatValue] / PTM_RATIO,
            [[[poly objectForKey:@"bodyDef"] objectForKey:@"y"] floatValue] / PTM_RATIO
        );

        NSString* type = [[poly objectForKey:@"bodyDef"] objectForKey:@"type"];
        if ([type isEqualToString:@"static"]) {
            bodyDef.type = b2_staticBody;
        } else if ([type isEqualToString:@"dynamic"]) {
            bodyDef.type = b2_dynamicBody;
        }
        
        b2PolygonShape shapeDef;
        NSArray* vertexArray = [[poly objectForKey:@"shapeDef"] objectForKey:@"vertices"];
        NSInteger vertexCount = [[[poly objectForKey:@"shapeDef"] objectForKey:@"vertexCount"] intValue];
        
        b2Vec2 *_vertices = new b2Vec2[vertexCount];
        int i = 0;
        for (NSDictionary* vertex in vertexArray) {
            float32 x = [[vertex objectForKey:@"x"] floatValue] / PTM_RATIO;
            float32 y = [[vertex objectForKey:@"y"] floatValue] / PTM_RATIO;
            _vertices[i++] = b2Vec2(x, y);
        }

        shapeDef.Set(_vertices, vertexCount);
        
        delete [] _vertices;
        
        // lastly, fixture definition
        b2FixtureDef fixtureDef;
        fixtureDef.density = [[[poly objectForKey:@"fixtureDef"] objectForKey:@"density"] floatValue];
        fixtureDef.friction = [[[poly objectForKey:@"fixtureDef"] objectForKey:@"friction"] floatValue];
        fixtureDef.restitution = [[[poly objectForKey:@"fixtureDef"] objectForKey:@"restitution"] floatValue];
        
        Polygon *polygon = [[Polygon alloc] init];
        
        // these don't work direct, for some reason we have to use their setter methods
        //polygon.bodyDef = bodyDef;
        //polygon.shapeDef = shapeDef;
        //polygon.fixtureDef = fixtureDef;
        
        [polygon setBodyDef: bodyDef];
        [polygon setShapeDef: shapeDef];
        [polygon setFixtureDef: fixtureDef];
        
        [polygon createForWorld: world];
        
        CCLOG(@"adding polygon [%.2f, %.2f]", bodyDef.position.x, bodyDef.position.y);
        [entities addObject:polygon];
        
        [polygon release];
    }
    
    // what about pickups - any joy?
    NSArray* pickupArray = [jsonObject objectForKey:@"pickups"];
    for (NSDictionary* pickupData in pickupArray) {
        b2Vec2 position = b2Vec2(
            [[pickupData objectForKey:@"x"] floatValue],
            [[pickupData objectForKey:@"y"] floatValue]
        );
        
        Pickup *pickup = [[Pickup alloc] init];
        
        [pickup initWithPosition:position forWorld: world];
        
        CCLOG(@"adding pickup [%.2f, %.2f]", position.x, position.y);
        [entities addObject: pickup];
        
        [pickup release];
    }
    
    CCLOG(@"Level [%d] parsed", levelIndex);
}

- (void)createBoundaries:(CGRect)rect {
    // Define the ground body.
    
    // temporary
    bounds = [[Polygon alloc] init];
    
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

-(NSString*) getTitle {
    return title;
}

#pragma mark dealloc
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	delete world;
	world = NULL;
    
    delete contactListener;
    contactListener = NULL;
    
    [ball release];
    ball = nil;    
    [bounds release];
    bounds = nil;
    [goal release];
    goal = nil;    
    
    [entities release];
    entities = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
