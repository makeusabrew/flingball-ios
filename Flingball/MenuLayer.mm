//
//  MenuLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 21/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "MenuLayer.h"
#import "LevelLayer.h"
#import "Constants.h"

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
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"FlingBall!" fontName:@"Georgia" fontSize: scale(64.0)];
        [self addChild: label];
        label.position = ccp(screenSize.width/2, (screenSize.height/2) + scale(100));
        
        CCMenuItem *startMenuItem = [CCMenuItemImage itemFromNormalImage:@"startButton.png" selectedImage:@"startButtonSelected.png" block:^(id object) {
            [[CCDirector sharedDirector] replaceScene:
             [CCTransitionCrossFade transitionWithDuration:0.5f scene:[LevelLayer scene:1]]];
        }];
        startMenuItem.scale = scale(startMenuItem.scale);
        
        startMenuItem.position = ccp(screenSize.width/2 - scale(220), (screenSize.height/2) - scale(100));
        
        CCMenuItem *optionsMenuItem = [CCMenuItemImage itemFromNormalImage:@"optionsButton.png" selectedImage:@"optionsButton.png" block:^(id object) {
            //[[CCDirector sharedDirector] replaceScene:
            // [CCTransitionCrossFade transitionWithDuration:0.5f scene:[LevelLayer scene:1]]];
            CCLOG(@"options button pressed");
        }];
        optionsMenuItem.scale = scale(optionsMenuItem.scale);
        
        optionsMenuItem.position = ccp(screenSize.width/2 + scale(220), (screenSize.height/2) - scale(100));
        
        CCMenu* menu = [CCMenu menuWithItems:startMenuItem, optionsMenuItem, nil];
        menu.position = CGPointZero;
        [self addChild: menu];
        
    }
    
    return self;
}

@end
