//
//  EndLevelLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 13/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "EndLevelLayer.h"
#import "LevelLayer.h"
#import "Constants.h"

@implementation EndLevelLayer

+(CCScene *) scene: (NSInteger)levelIndex
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	EndLevelLayer *layer = [EndLevelLayer node];
    
    [layer setLevel: levelIndex];
	
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
        		
		// Debug Draw functions
		m_debugDraw = new GLESDebugDraw( PTM_RATIO );
		//level.world->SetDebugDraw(m_debugDraw);
		
		uint32 flags = 0;
		flags += b2DebugDraw::e_shapeBit;
        //		flags += b2DebugDraw::e_jointBit;
        //		flags += b2DebugDraw::e_aabbBit;
        //		flags += b2DebugDraw::e_pairBit;
        //		flags += b2DebugDraw::e_centerOfMassBit;
		m_debugDraw->SetFlags(flags);
	}
	return self;
}

-(void) setLevel:(NSInteger)levelIndex {    
    cLevel = levelIndex;
    CGSize screenSize = [CCDirector sharedDirector].winSize;
    
    NSString* str = [NSString stringWithFormat:@"Level %d Completed!", levelIndex];

    CCLabelTTF *label = [CCLabelTTF labelWithString:str fontName:@"Georgia" fontSize:32];
    [self addChild:label z:0];
    [label setColor:ccc3(0,0,255)];
    label.position = ccp( screenSize.width/2, screenSize.height-50);
}

- (void)ccTouchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    [[CCDirector sharedDirector] replaceScene:
     [CCTransitionCrossFade transitionWithDuration:1.0f scene:[LevelLayer scene:++cLevel]]];
}

-(void) draw
{
	// Default GL states: GL_TEXTURE_2D, GL_VERTEX_ARRAY, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	// Needed states:  GL_VERTEX_ARRAY, 
	// Unneeded states: GL_TEXTURE_2D, GL_COLOR_ARRAY, GL_TEXTURE_COORD_ARRAY
	glDisable(GL_TEXTURE_2D);
	glDisableClientState(GL_COLOR_ARRAY);
	glDisableClientState(GL_TEXTURE_COORD_ARRAY);
	
	//level.world->DrawDebugData();
	
	// restore default GL states
	glEnable(GL_TEXTURE_2D);
	glEnableClientState(GL_COLOR_ARRAY);
	glEnableClientState(GL_TEXTURE_COORD_ARRAY);
    
}

@end
