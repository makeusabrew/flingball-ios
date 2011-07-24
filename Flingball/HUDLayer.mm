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

@implementation HUDLayer

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        hudStr = [CCLabelTTF labelWithString: [self getStatus] fontName:@"Georgia" fontSize: scale(32.0)];
        [self addChild: hudStr];
        hudStr.position = ccp(screenSize.width / 2, scale(32.0));        
    }
    
    return self;
}

-(void) draw {
    hudStr.string = [self getStatus];
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

@end
