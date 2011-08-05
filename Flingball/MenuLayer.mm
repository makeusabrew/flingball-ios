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
#import "CJSONDeserializer.h"

@implementation MenuLayer

#pragma mark dealloc

- (void) dealloc
{
    CCLOG(@"MenuLayer::dealloc");
    
    [self removeAllChildrenWithCleanup: YES];
	
	[super dealloc];
}

#pragma mark -

+(CCScene *) scene
{
	// 'scene' is an autorelease object.
	CCScene *scene = [CCScene node];
	
	// 'layer' is an autorelease object.
	//MenuLayer *layer = [MenuLayer node];
	
	// add layer as a child to scene
    CCLayerMultiplex *layer = [CCLayerMultiplex layerWithLayers: [MenuLayer node], [SettingsLayer node], nil];
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
             [CCTransitionFade transitionWithDuration:1.0f scene:[LevelLayer scene:1]]];
        }];
        startMenuItem.scale = scale(startMenuItem.scale);
        
        startMenuItem.position = ccp(screenSize.width/2 - scale(220), (screenSize.height/2) - scale(100));
        
        CCMenuItem *optionsMenuItem = [CCMenuItemImage itemFromNormalImage:@"optionsButton.png" selectedImage:@"optionsButton.png" block:^(id object) {
            //[[CCDirector sharedDirector] replaceScene:
            // [CCTransitionCrossFade transitionWithDuration:0.5f scene:[LevelLayer scene:1]]];
            CCLOG(@"options button pressed");
            /*
            UIView* myView = [[[UIView alloc] initWithFrame:CGRectMake(screenSize.width/2 - 320, screenSize.height/2 - 240, 640, 480)] autorelease];
            UITableView* myTable = [[[UITableView alloc] initWithFrame:CGRectMake(0, 0, 640, 480) style: UITableViewStylePlain] autorelease];
            [myView addSubview: myTable];
            [[[CCDirector sharedDirector] openGLView] addSubview: myView];
             */
            [(CCLayerMultiplex*)parent_ switchTo:1];
            
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

@implementation SettingsLayer

#pragma mark dealloc

- (void) dealloc
{
    CCLOG(@"SettingsLayer::dealloc");
    
    [self removeAllChildrenWithCleanup: YES];
	
	[super dealloc];
}

#pragma mark -

- (id)init
{
    self = [super init];
    if (self) {
        
        CGSize screenSize = [[CCDirector sharedDirector] winSize];
        
        CCLabelTTF* label = [CCLabelTTF labelWithString:@"Your Levels" fontName:@"Georgia" fontSize: scale(32.0)];
        [self addChild: label];
        label.position = ccp(screenSize.width/2, (screenSize.height/2) + scale(300));
        
        levelData = [[NSMutableData alloc] init];
            
        NSURLRequest* request = [[[NSURLRequest alloc] initWithURL: [NSURL URLWithString:@"http://fbtest.paynedigital.com/api/1.0/levels?key=abc123"]] autorelease];            
        [[NSURLConnection alloc] initWithRequest: request delegate: self];        
    }
    
    return self;
}

-(void) connection:(NSURLConnection *)connection didReceiveData:(NSData *)data {
    [levelData appendData: data];
    CCLOG(@"got DATA");
}

-(void) connectionDidFinishLoading:(NSURLConnection *)connection {
    NSString *url = [connection.originalRequest.URL absoluteString];
    CCLOG(@"URL finished loading [%@]", url);
    NSError *jsonError = nil;
    NSDictionary* jsonObject = [[CJSONDeserializer deserializer] deserialize:levelData error:&jsonError];
    BOOL success = [[jsonObject objectForKey:@"success"] boolValue];
    
    [connection release];
    [levelData release];
    
    if (success == NO) {
        NSString *msg = [NSString stringWithString: [jsonObject objectForKey:@"msg"]];
        CCLOG(@"Level retrieval failed, reason: %@", msg);
        return;
    }
    
    // woohoo! Life is good. What URL was it?
    CCMenu* menu = [CCMenu menuWithItems: nil];
    [self addChild: menu];
    //CGSize screenSize = [[CCDirector sharedDirector] winSize];
    
    if ([url isEqualToString: @"http://fbtest.paynedigital.com/api/1.0/levels?key=abc123"]) {
        //
        CCLOG(@"now getting level info");
        NSArray* levelArray = [jsonObject objectForKey:@"levels"];
        for (NSDictionary* level in levelArray) {
            NSString* title = [level objectForKey:@"title"];
            NSInteger identifier = [[level objectForKey: @"identifier"] intValue];
            CCLOG(@"%@", title);
            CCLabelTTF *label = [CCLabelTTF labelWithString: title fontName:@"Georgia" fontSize:scale(24)];
            CCMenuItemLabel* item = [CCMenuItemLabel itemWithLabel: label block:^(id sender) {
            //CCMenuItemFont* item = [CCMenuItemFont itemFromString: title block:^(id sender) {
                CCLOG(@"clicky %@, %d", label.string, identifier);
                [[CCDirector sharedDirector] replaceScene:
                 [CCTransitionCrossFade transitionWithDuration:0.5f scene:[LevelLayer sceneWithKey:@"abc123" andIdentifier:identifier]]];
            }];
            [menu addChild: item];
            
            //item.scale = scale(item.scale);            
            //item.position = ccp(screenSize.width/2, (screenSize.height) - scale(i*100));
        }
    }
    
    // @see https://projects.paynedigital.com/issues/203
    CCLabelTTF *label = [CCLabelTTF labelWithString: @"Go Back" fontName:@"Georgia" fontSize:scale(24)];
    CCMenuItemLabel* item = [CCMenuItemLabel itemWithLabel: label block:^(id sender) {
        [(CCLayerMultiplex*)parent_ switchTo: 0];
    }];
    [menu addChild: item];
    
    [menu alignItemsVerticallyWithPadding: 30.0];    
}

@end
