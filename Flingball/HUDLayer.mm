//
//  HUDLayer.mm
//  Flingball
//
//  Created by Nicholas Payne on 24/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "HUDLayer.h"
#import "Constants.h"
#import "GameState.h"
#import "LevelLayer.h"

@implementation HUDLayer

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        hudStr = [CCLabelTTF labelWithString: [self getStatus] fontName:@"Georgia" fontSize: scale(24.0)];
        [self addChild: hudStr];
        hudStr.position = ccp(screenSize.width/2 - scale(100), scale(24.0));
        
        // refactor power meter, @see https://projects.paynedigital.com/issues/195
        powerMeter = [CCSprite spriteWithSpriteFrameName:@"power.png"];
        [self addChild: powerMeter];
        powerMeter.position = ccp(screenSize.width - scale(50.0), scale(100.0));
        powerRect = [powerMeter textureRect];
        
        [self setFlingPower: 0];

        // add retry icon, @see https://projects.paynedigital.com/issues/180
        CCMenuItem* menuItem = [CCMenuItemImage itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName:@"retry.png"] selectedSprite: [CCSprite spriteWithSpriteFrameName:@"retry.png"] block:^(id object) {
            if ([[GameState sharedGameState] getValueAsBool: @"isDevMode"]) {
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFlipX transitionWithDuration:0.5f scene:[LevelLayer sceneWithKey:[[GameState sharedGameState] getValue: @"apiKey"] andIdentifier:[[GameState sharedGameState] getValueAsInt: @"apiIdentifier"]]]];
            } else {
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFlipX transitionWithDuration:0.5f scene:[LevelLayer scene: [[GameState sharedGameState] getValueAsInt:@"currentLevel"]]]];
            }            
        }];
        
        menuItem.scale = scale(menuItem.scale);
        
        menuItem.position = ccp(screenSize.width - scale(50), scale(50));
        
        CCMenu* menu = [CCMenu menuWithItems:menuItem, nil];
        menu.position = CGPointZero;        
        [self addChild: menu];
        
        [self schedule: @selector(update) interval:0.1];
    }
    
    return self;
}

-(NSString*) getStatus {
    double elapsedTime = 0.0;
    
    if ([[GameState sharedGameState] getValueAsBool: @"levelStarted"] == YES) {
        elapsedTime = [[GameState sharedGameState] getElapsedTime];
    }
    
    return [NSString stringWithFormat:@"%@, Flings: %d, Bounces: %d, Level Time %.2f",
                [[GameState sharedGameState] getValue: @"levelTitle"],
                [[GameState sharedGameState] getValueAsInt: @"ballFlings"],
                [[GameState sharedGameState] getValueAsInt: @"ballBounces"],
                elapsedTime];
}

-(void) update {
    hudStr.string = [self getStatus];
}

-(void) setFlingPower:(int)power {
    flingPower = power;
    int scaled = round((float)power * (powerRect.size.height / 100.f));
    [powerMeter setTextureRect:CGRectMake(powerRect.origin.x, (powerRect.origin.y + powerRect.size.height) - scaled, powerRect.size.width, scaled)];
    powerMeter.position = ccp(powerMeter.position.x, scale(100) + (scaled / 2));
}

-(void) flingFinished {
    // @todo reduce the power shown in a nice smooth motion rather than instant
    [self setFlingPower: 0];
}

@end
