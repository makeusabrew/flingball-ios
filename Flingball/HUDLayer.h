//
//  HUDLayer.h
//  Flingball
//
//  Created by Nicholas Payne on 24/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "cocos2d.h"

@interface HUDLayer : CCLayer {
    CCLabelTTF* hudStr;
    CCLabelTTF* achievementLabel;
    
    CCSprite *powerMeter;
    float flingPower;
    CGRect powerRect;
}

-(NSString*) getStatus;
-(void) update;
-(void) setFlingPower: (int)power;
-(void) flingFinished;
-(void) showAchievementNotification: (NSString *)identifier;

@end
