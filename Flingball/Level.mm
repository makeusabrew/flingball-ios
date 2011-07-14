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
    
    polygons = [[NSMutableArray alloc] init];    
    NSString *str = [NSString stringWithFormat:@"level%d", levelIndex];
    NSString *filePath = [[NSBundle mainBundle] pathForResource:str ofType:@"xml"];
    NSData *levelData = [NSData dataWithContentsOfFile:filePath];
    
    NSXMLParser *xmlParser = [[NSXMLParser alloc] initWithData:levelData];
    
    [xmlParser setDelegate:self];
    
    [xmlParser parse];
    
    NSLog(@"Level parsed");
    
    world->SetGravity(gravity);
    
    [self createBoundaries:CGRectMake(0, 0, width, height)];        
    
    ball = [[Ball alloc] initWithPosition:startPos forWorld:world];

    
    // temporary end goal
    goal = [[GoalEntity alloc] initWithPosition:endPos forWorld:world];
    
    [xmlParser release];
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

#pragma mark XML parsing methods

- (void)parser:(NSXMLParser *)parser didStartElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName 
    attributes:(NSDictionary *)attributeDict {
    
    if ([elementName isEqualToString:@"dimensions"] ||
        [elementName isEqualToString:@"gravity"]    ||
        [elementName isEqualToString:@"start"]      ||
        [elementName isEqualToString:@"end"]        ||
        [elementName isEqualToString:@"block"]      ||
        [elementName isEqualToString:@"pickup"]
    ) {        
        currentElem = elementName;
    }
    
    if ([elementName isEqualToString:@"block"]) {
        NSLog(@"starting new poly");
        currentPolygon = [[Polygon alloc] init];
    }
    
    if ([elementName isEqualToString:@"pickup"]) {
        currentPickup = [[Pickup alloc] init];
    }
    
    if ([currentElem isEqualToString:@"block"] &&
        ([elementName isEqualToString:@"bodyDef"] ||
         [elementName isEqualToString:@"shapeDef"] ||
         [elementName isEqualToString:@"fixtureDef"]
        )
    ) {
        blockMode = elementName;
    }
    
    if ([elementName isEqualToString:@"vertex"]) {
        //[currentPolygon addVertex];
        blockSubMode = @"vertex";
    }
}

-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string {
    if (!currentElemValue) {
        currentElemValue = [[NSMutableString alloc] initWithCapacity:50];
    }
    
    string = [string stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    if ([string length] == 0) {
        return;
    }
    
    //NSLog(@"appending string %@", string);
    
    [currentElemValue appendString:string];
}

-(void) parser:(NSXMLParser *)parser didEndElement:(NSString *)elementName namespaceURI:(NSString *)namespaceURI qualifiedName:(NSString *)qName {
    if ([currentElem isEqualToString:@"dimensions"]) {        
        if ([elementName isEqualToString:@"width"]) {            
            width = [currentElemValue integerValue];            
        } else if ([elementName isEqualToString:@"height"]) {
            height = [currentElemValue integerValue];            
        }
    } else if ([currentElem isEqualToString:@"gravity"]) {
        if ([elementName isEqualToString:@"x"]) {
            gravity.x = [currentElemValue floatValue];
        } else if ([elementName isEqualToString:@"y"]) {
            gravity.y = [currentElemValue floatValue];
        }
    } else if ([currentElem isEqualToString:@"start"]) {
        if ([elementName isEqualToString:@"x"]) {
            startPos.x = [currentElemValue floatValue];
        } else if ([elementName isEqualToString:@"y"]) {
            startPos.y = [currentElemValue floatValue];
        }
    } else if ([currentElem isEqualToString:@"end"]) {
        if ([elementName isEqualToString:@"x"]) {
            endPos.x = [currentElemValue floatValue];
        } else if ([elementName isEqualToString:@"y"]) {
            endPos.y = [currentElemValue floatValue];
        }
    } else if ([currentElem isEqualToString:@"pickup"]) {
        if ([elementName isEqualToString:@"pickup"]) {
            [pickups addObject:currentPickup];
            
            [currentPickup release];
            currentPickup = nil;
        }
    } else if ([currentElem isEqualToString:@"block"]) {
        // cool, we're in block creation mode
        if ([elementName isEqualToString:@"block"]) {
            // end of block definition!
            [currentPolygon createShape: world];
            [polygons addObject:currentPolygon];
            [currentPolygon release];
            currentPolygon = nil;
        } else if ([blockMode isEqualToString:@"bodyDef"]) {
            if ([elementName isEqualToString:@"x"]) {
                //currentPolygon.bodyDef.position.x = [currentElemValue floatValue] / PTM_RATIO;
                [currentPolygon setBodyDefX: [currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"y"]) {
                [currentPolygon setBodyDefY: [currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"type"]) {
                //currentPolygon.bodyDef.position.x = [currentElemValue floatValue];
                //currentPolygon.bodyDef.type = b2_staticBody;
            }
        } else if ([blockMode isEqualToString:@"shapeDef"]) {
            if ([elementName isEqualToString:@"x"]) {
                
                [currentPolygon setVertexX:[currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"y"]) {
                
                [currentPolygon setVertexY:[currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"vertex"]) {
                
                [currentPolygon commitCurrentVertex];
            }
        } else if ([blockMode isEqualToString:@"fixtureDef"]) {
            if ([elementName isEqualToString:@"density"]) {
               
                [currentPolygon setShapeDefDensity: [currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"friction"]) {
                
                [currentPolygon setShapeDefFriction: [currentElemValue floatValue]];
            } else if ([elementName isEqualToString:@"restitution"]) {
                
                [currentPolygon setShapeDefRestitution: [currentElemValue floatValue]];
            }
        }
    }
    
    //NSLog(@"emptying current string");
    
    [currentElemValue release];
    currentElemValue = nil;
}

-(void) parser:(NSXMLParser *)parser foundIgnorableWhitespace:(NSString *)whitespaceString {
    // great
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
    [polygons release];
    polygons = nil;
    
	// don't forget to call "super dealloc"
	[super dealloc];
}

@end
