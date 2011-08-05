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

    // local values we want to manipulate
    NSMutableDictionary* values;
    // game center achievements we need to be less gung-ho about
    NSMutableDictionary* achievements;
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

-(double) getAchievementPercentage: (NSString*) identifier;

-(void) authenticateLocalUser;
-(void) authenticationChanged;
-(void) reportAchievementIdentifier: (NSString*) identifier percentComplete: (float) percent;
@end
