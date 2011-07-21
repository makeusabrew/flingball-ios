//
//  MenuLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 21/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "MenuLayer.h"
#import "LevelLayer.h"

@implementation MenuLayer

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	MenuLayer *layer = [MenuLayer node];
	
	// add layer as a child to scene
	[scene addChild: layer];
	
	// return the scene
	return scene;
}

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"FlingBall!" fontName:@"Georgia" fontSize:64.0];
        [self addChild: label];
        label.position = ccp(screenSize.width/2, (screenSize.height/2) + 100);
        
        CCMenuItem *startMenuItem = [CCMenuItemImage itemFromNormalImage:@"startButton.png" selectedImage:@"startButtonSelected.png" block:^(id object) {
            [[CCDirector sharedDirector] replaceScene:
             [CCTransitionCrossFade transitionWithDuration:1.0f scene:[LevelLayer scene:1]]];
        }];
        
        startMenuItem.position = ccp(screenSize.width/2, (screenSize.height/2) - 100);
        
        CCMenu* menu = [CCMenu menuWithItems:startMenuItem, nil];
        menu.position = CGPointZero;
        [self addChild: menu];
        
    }
    
    return self;
}

@end
