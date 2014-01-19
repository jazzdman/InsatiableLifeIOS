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
@synthesize recipePage;
@synthesize recipeTitle;
@synthesize recipeDateString;
@synthesize recipeDateInt;
@synthesize recipeURL;
@synthesize recipeIngredients;

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
        self.recipePage = tempItem;
        self.recipeTitle = tempItem;
        self.recipeDateString = tempItem;
        [tempItem release];
        self.recipeDateInt = -1;
        tempItem = [[NSURL alloc] init];
        self.recipeURL= tempItem;
        [tempItem release];
        tempItem = [[NSMutableArray alloc] initWithCapacity:1];
        self.recipeIngredients = tempItem;
        [tempItem release];
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
    
    [recipePage release];
    
    [recipeTitle release];
   
    if([recipeDateString retainCount] != UINT_MAX)
    {
        [recipeDateString release];
    }
   
    [recipeURL release];
   
    [recipeIngredients release];
    
    [super dealloc];
    
}

@end
