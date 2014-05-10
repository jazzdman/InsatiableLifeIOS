//
//  MenuViewCell.m
//  FullPlate
//
//  Created by Jason Mazzotta on 3/12/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import "Recipe.h"


@implementation Recipe

// Create the setters and getters for the properties
@synthesize recipePage = _recipePage;
@synthesize recipeTitle = _recipeTitle;
@synthesize recipeDateString = _recipeDateString;
@synthesize recipeDateInt = _recipeDateInt;
@synthesize recipeURL = _recipeURL;
@synthesize recipeIngredients = _recipeIngredients;

/*************************************************************
 *
 * Inputs :     None
 *
 * Purpose :    The constructor - initialize an object of the class
 *
 * Outputs:     MenuViewCell - A cell that has a style that provides a view with 
 *              two labels and a disclosure indicator in its accessory 
 *              view.  May return nil.
 * 
 *************************************************************/
- (Recipe *)init
{
    id tempItem;
    self = [super init];
   
    if (self) 
    {
        tempItem = [[NSString alloc] initWithString:@""];
        _recipePage = tempItem;
        [_recipePage retain];
        _recipeTitle = tempItem;
        [_recipeTitle retain];
        _recipeDateString = tempItem;
        [_recipeDateString retain];
        _recipeDateInt = -1;
        tempItem = [NSURL URLWithString:@"http://localhost"];
        _recipeURL= tempItem;
        [_recipeURL retain];
        tempItem = [[NSMutableArray alloc] initWithCapacity:1];
        _recipeIngredients = tempItem;
        [_recipeIngredients retain];
    }
    
    return self;
}

/****************************************************
 *
 * Inputs  : NSZone - the memory zone in which we make the copy
 *
 * Purpose : Create a copy of an object
 *
 * Outputs : A copy of the object
 *
 ****************************************************/
- (id)copyWithZone:(NSZone *)zone 
{
    Recipe * other = [[Recipe allocWithZone:zone] init];
    other.recipePage = self.recipePage;
    other.recipeTitle = self.recipeTitle;
    other.recipeDateString = self.recipeDateString;
    other.recipeDateInt = self.recipeDateInt;
    other.recipeURL = self.recipeURL;
    other.recipeIngredients = self.recipeIngredients;
    
    return other;
}


/*************************************************************
 *
 * Inputs  : None
 *
 * Purpose : The deconstructor. (Hopefully) reduce the 
 *           retain count for the instance variables to 0
 *           so the memory is recouped by the OS.
 *
 * Outputs : Nothing
 * 
 *************************************************************/
- (void)dealloc
{
    
    [_recipePage release];
    
    [_recipeTitle release];
   
    if([_recipeDateString retainCount] != UINT_MAX)
    {
        [_recipeDateString release];
    }
   
    [_recipeURL release];
   
    [_recipeIngredients release];
    
    [super dealloc];
    
}

@end
