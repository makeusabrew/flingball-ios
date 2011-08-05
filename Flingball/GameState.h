//
//  GameState.h
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <GameKit/GameKit.h>

@interface GameState : NSObject {
    
    BOOL gameCenterAuthed;

    NSMutableDictionary* values;
    NSArray *allowedKeys;
}

+ (GameState *) sharedGameState;
-(void) reset;
-(double) getElapsedTime;
-(void) updateKey: (NSString*)key withValue: (id)value;
-(void) updateKey: (NSString*)str withDouble:(double) value;
-(void) updateKey: (NSString*)str withInt:(int) value;
-(void) updateKey: (NSString*)str withBool:(BOOL) value;

-(id) getValue: (NSString*)key;
-(double) getValueAsDouble: (NSString*)key;
-(int) getValueAsInt: (NSString*) key;
-(BOOL) getValueAsBool: (NSString*) key;

-(void) addFling;
-(void) addBounce;

-(void) authenticateLocalUser;
-(void) authenticationChanged;

@end
