//
//  AppDelegate.h
//  Flingball
//
//  Created by Nicholas Payne on 06/07/2011.
//  Copyright Payne Digital Ltd 2011. All rights reserved.
//

#import <UIKit/UIKit.h>

@class RootViewController;

@interface AppDelegate : NSObject <UIApplicationDelegate> {
	UIWindow			*window;
	RootViewController	*viewController;
}

@property (nonatomic, retain) UIWindow *window;

@end
