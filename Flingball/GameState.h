//
//  GameState.h
//  Flingball
//
//  Created by Nicholas Payne on 15/07/2011.
//  Copyright 2011 Payne Digital Ltd. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GameState : NSObject {
    /*
    NSInteger ballFlings;
    NSInteger ballBounces;
    
    NSTimeInterval startTime;
    NSTimeInterval endTime;
    
    BOOL levelStarted;
    
    NSString* levelTitle;
     */
    NSMutableDictionary* values;
    NSArray *allowedKeys;
}

/*
@property NSInteger ballFlings;
@property NSInteger ballBounces;
@property NSTimeInterval startTime;
@property NSTimeInterval endTime;
@property BOOL levelStarted;
@property (nonatomic, copy) NSString* levelTitle;
*/
//@property (nonatomic, retain) NSMutableDictionary* values;

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

@end
