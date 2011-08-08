//
//  MenuLayer.h
//  Flingball
//
//  Created by Nicholas Payne on 21/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "cocos2d.h"

@interface MenuLayer : CCLayer {
    
}

+(CCScene *) scene;

@end

@interface SettingsLayer : CCLayer <NSURLConnectionDelegate> {
    NSMutableData* levelData;
    NSString *apiKey;
}

@end;
