//
//  Entity.mm
//  Flingball
//
//  Created by Nicholas Payne on 08/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import "Entity.h"

@implementation Entity

@synthesize sprite;

- (id)init
{
    self = [super init];
    if (self) {
        // Initialization code here.
        position.x = 0;
        position.y = 0;
    }
    
    return self;
}

@end
