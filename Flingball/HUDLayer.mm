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
    double elapsedTime;
    if ([[GameState sharedGameState] levelStarted] == YES) {
        //elapsedTime = ;
        elapsedTime = [[GameState sharedGameState] getElapsedTime];
    } else {
        elapsedTime = 0.0;
    }
    
    return [NSString stringWithFormat:@"%@, Flings: %d, Bounces: %d, Level Time %.2f",
                [[GameState sharedGameState] levelTitle],
                [[GameState sharedGameState] ballFlings],
                [[GameState sharedGameState] ballBounces],
                elapsedTime];
}

@end
