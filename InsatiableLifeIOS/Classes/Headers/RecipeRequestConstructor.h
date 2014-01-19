//
//  RecipeRequestConstructor.h
//  FullPlate
//
//  Created by Jason Mazzotta on 5/16/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>


/************************************************************
 *
 * This class is responsible for creating a request for Bing
 * to find a recipe on a recipe website.  It makes use of the
 * settings the user defined as well as various lists of ingredients.
 *
 ************************************************************/
@interface RecipeRequestConstructor : NSObject 
{
    // The string that represents a request to be sent to Bing
	NSMutableString * request;
    
    // The array of types of dishes for a recipe
    NSArray * dishes;
    
    // The array of possible main ingredients for a recipe
    NSArray * ingredients;
    
}
// A property that makes it easier to access the request
// created by this class
@property (retain, nonatomic, getter = getRequest) NSMutableString * request;

// The constructor for this class
-(RecipeRequestConstructor *) init;

// The getter is where the request is actually created.
-(NSMutableString *) getRequest;

// The destructor for this class
-(void) dealloc;


@end
