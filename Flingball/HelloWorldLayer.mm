//
//  HelloWorldLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//


// Import the interfaces
#import "HelloWorldLayer.h"
#import "Constants.h"
#import "Level.h"



// enums that will be used as tags
enum {
	kTagTileMap = 1,
	kTagBatchNode = 1,
	kTagAnimation1 = 1,
};


// HelloWorldLayer implementation
@implementation HelloWorldLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	HelloWorldLayer *layer = [HelloWorldLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

// on "init" you need to initialize your instance
-(id) init
{
	// always call "super" init
	// Apple recommends to re-assign "self" with the "super" return value
	if( (self=[super init])) {
		
		// enable touches
		self.isTouchEnabled = YES;
		
		// enable accelerometer
		self.isAccelerometerEnabled = YES;
		
		CGSize screenSize = [CCDirector sharedDirector].winSize;
		CCLOG(@"Screen width %0.2f screen height %0.2f",screenSize.width,screenSize.height);
        
        level = [[Level alloc] init];
        camera = [[Camera alloc] init];
        
        [camera setViewport: CGRectMake(0, 0, screenSize.width, screenSize.height)];
        
        [camera trackEntity:level.ball];
		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		level.world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
//		flags += b2DebugDraw::e_jointBit;
//		flags += b2DebugDraw::e_aabbBit;
//		flags += b2DebugDraw::e_pairBit;
//		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);		
                
		                
        /*
		CCLabelTTF *label = [CCLabelTTF labelWithString:@"Tap screen" fontName:@"Marker Felt" fontSize:32];
		[self addChild:label z:0];
		[label setColor:ccc3(0,0,255)];
		label.position = ccp( screenSize.width/2, screenSize.height-50);
		*/
        
        [self addChild:level.ball.sprite];      
         
		[self schedule: @selector(tick:)];
	}
	return self;
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	level.world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);

}

-(void) tick: (ccTime) dt
{
	//It is recommended that a fixed time step is used with Box2D for stability
	//of the simulation, however, we are using a variable time step here.
	//You need to make an informed choice, the following URL is useful
	//http://gafferongames.com/game-physics/fix-your-timestep/
	
	int32 velocityIterations = 8;
	int32 positionIterations = 1;
	
	// Instruct the world to perform a single step of simulation. It is
	// generally best to keep the time step and iterations fixed.
	level.world->Step(dt, velocityIterations, positionIterations);

	
	//Iterate over the bodies in the physics world
	for (b2Body* b = level.world->GetBodyList(); b; b = b->GetNext())
	{
		if (b->GetUserData() != NULL) {
			Entity *myEntity = (Entity*)b->GetUserData();
            b2Vec2 pos = b2Vec2(b->GetPosition().x * PTM_RATIO, b->GetPosition().y * PTM_RATIO);
            float angle = -1 * CC_RADIANS_TO_DEGREES(b->GetAngle());
            [myEntity setSpritePosition:pos withAngle:angle];
		}
	}
    
    [camera update];
    
    [self.camera setEyeX:[camera getLeftEdge] eyeY:[camera getBottomEdge] eyeZ:[CCCamera getZEye]];
    [self.camera setCenterX:[camera getLeftEdge] centerY:[camera getBottomEdge] centerZ:0];  
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    //Add a new body/atlas sprite at the touched location
	for( UITouch *touch in touches ) {
		startDragLocation = [touch locationInView: [touch view]];
		
		startDragLocation = [[CCDirector sharedDirector] convertToGL: startDragLocation];
	}
}

- (void)ccTouchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
	for( UITouch *touch in touches ) {
		CGPoint location = [touch locationInView: [touch view]];
		
		location = [[CCDirector sharedDirector] convertToGL: location];
        
        float dx = location.x - startDragLocation.x;
        float dy = location.y - startDragLocation.y;
        float dist = sqrt((dx*dx) + (dy*dy));
        float vel = dist / 5.0; // hard coded for now!
        
        b2Vec2 v;
        
        if (dy < 0 && dx == 0) {	// straight up
            v.x = 0;
            v.y = -vel;
        } else if (dy > 0 && dx == 0) {	// straight down
            v.x = 0;
            v.y = vel;
        } else if (dx > 0 && dy == 0) {	// straight left
            v.x = vel;
            v.y = 0;
        } else if (dx < 0 && dy == 0) {	// straight right
            v.x = -vel;
            v.y = 0;
        } else if (dy < 0 && dx < 0) {	// bottom left of ball
            float a = dy / dx;
            a = atan(a);
            v.x = cos(a) * vel;
            v.y = sin(a) * vel;		
        } else if (dy < 0 && dx > 0) {	// bottom right of ball
            float a = atan2(dy, dx);		
            v.x = -(cos(a) * vel);
            v.y = -(sin(a) * vel);
        }
        
        [level.ball fling:v];
	}
}

/*
- (void)accelerometer:(UIAccelerometer*)accelerometer didAccelerate:(UIAcceleration*)acceleration
{	
	static float prevX=0, prevY=0;
	
	//#define kFilterFactor 0.05f
#define kFilterFactor 1.0f	// don't use filter. the code is here just as an example
	
	float accelX = (float) acceleration.x * kFilterFactor + (1- kFilterFactor)*prevX;
	float accelY = (float) acceleration.y * kFilterFactor + (1- kFilterFactor)*prevY;
	
	prevX = accelX;
	prevY = accelY;
	
	// accelerometer values are in "Portrait" mode. Change them to Landscape left
	// multiply the gravity by 10
	b2Vec2 gravity( -accelY * 10, accelX * 10);
	
	world->SetGravity( gravity );
}
*/

// on "dealloc" you need to release all your retained objects
- (void) dealloc
{
	// in case you have something to dealloc, do it in this method
	[level dealloc];
    level = NULL;
    
    [camera dealloc];
    camera = NULL;
	
	delete m_debugDraw;

	// don't forget to call "super dealloc"
	[super dealloc];
}
@end
