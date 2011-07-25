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
}

-(NSString*) getStatus;
-(void) update;

@end
