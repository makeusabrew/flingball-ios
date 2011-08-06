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
#import "MenuLayer.h"

@implementation HUDLayer

#pragma mark dealloc

- (void) dealloc
{
    CCLOG(@"HUDLayer::dealloc");

    [self removeAllChildrenWithCleanup: YES];
	
	[super dealloc];
}

#pragma mark -

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
        
        // @see https://projects.paynedigital.com/issues/208
        achievementLabel = [CCLabelTTF labelWithString: nil fontName:@"Georgia" fontSize: scale(24.0)];
        [self addChild: achievementLabel];
        [achievementLabel runAction: [CCFadeOut actionWithDuration: 0.0]];
        achievementLabel.position = ccp(screenSize.width / 2, scale(700.0));

        // add retry icon, @see https://projects.paynedigital.com/issues/180
        CCMenuItem* retryItem = [CCMenuItemImage itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName:@"retry.png"] selectedSprite: [CCSprite spriteWithSpriteFrameName:@"retry.png"] block:^(id object) {
            
            // @see https://projects.paynedigital.com/issues/222
            if ([[GameState sharedGameState] getValueAsInt: STATE_FLINGS] == 0 &&
                [[GameState sharedGameState] getAchievementPercentage: ACHIEVEMENT_WIMPED_OUT] == 0.0) {
                // what a wimp!
                CCLOG(@"got wimp achievement!");
                // we can't just show the achievement here because we immediately load a level layer scene :(
                // instead we have to queue it up and then let the LevelLayer handle it
                // @todo actually make this work
                [[GameState sharedGameState] queueNotification: ACHIEVEMENT_WIMPED_OUT];                
                
                // but we CAN obviously report the achievement now
                [[GameState sharedGameState] reportAchievementIdentifier: ACHIEVEMENT_WIMPED_OUT percentComplete:100.0];
                
            }
            
            if ([[GameState sharedGameState] getValueAsBool: @"isDevMode"]) {
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFlipX transitionWithDuration:0.5f scene:[LevelLayer sceneWithKey:[[GameState sharedGameState] getValue: @"apiKey"] andIdentifier:[[GameState sharedGameState] getValueAsInt: @"apiIdentifier"]]]];
            } else {
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionFlipX transitionWithDuration:0.5f scene:[LevelLayer scene: [[GameState sharedGameState] getValueAsInt:@"currentLevel"]]]];
            }            
        }];
        
        retryItem.scale = scale(retryItem.scale);        
        retryItem.position = ccp(screenSize.width - scale(50), scale(50));
        
        // add quit icon, @see https://projects.paynedigital.com/issues/202
        CCMenuItem* quitItem = [CCMenuItemImage itemFromNormalSprite: [CCSprite spriteWithSpriteFrameName:@"quit.png"] selectedSprite: [CCSprite spriteWithSpriteFrameName:@"quit.png"] block:^(id object) {
            [[CCDirector sharedDirector] replaceScene:
            [CCTransitionFade transitionWithDuration:1.0f scene:[MenuLayer scene]]];           
        }];
        
        quitItem.scale = scale(quitItem.scale);        
        quitItem.position = ccp(screenSize.width - scale(150), scale(50));
        
        CCMenu* menu = [CCMenu menuWithItems:retryItem, quitItem, nil];
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

-(void) showAchievementNotification:(NSString *)identifier {
    if ([identifier isEqualToString: ACHIEVEMENT_NO_BOUNCES]) {
        //CCLayer* layer = [[CCLayer alloc] init];
        achievementLabel.string = @"Achievement Unlocked: 'Bounceaphobic'!";
    } else if ([identifier isEqualToString: ACHIEVEMENT_WIMPED_OUT]) {
        achievementLabel.string = @"Achievement Unlocked: 'Wimped Out'!";
    }
    
    CCLOG(@"achievement string: %@", achievementLabel.string);
    
    // fade in, wait, fade out
    [achievementLabel runAction:[CCSequence actions:
                                 [CCFadeIn actionWithDuration: 0.5], 
                                 [CCDelayTime actionWithDuration: 2.0], 
                                 [CCFadeOut actionWithDuration: 0.5],
                                 nil]];
}

@end
