//
//  Recipe.h
//  FullPlate
//
//  Created by Jason Mazzotta on 3/12/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import <UIKit/UIKit.h>

/*******************************************************************************
 *
 * This class holds information that the rest of the application needs to know
 * about recipes that are collected by the AllRecipesManager.
 *
 *******************************************************************************/

@interface Recipe : NSObject 
{
    // The HTML for the recipe, scaled to the servings specified by the
    // user
    NSString * recipePage;
    
    // The title of the recipe
    NSString * recipeTitle;
    
    // The day of the week that this recipe should be displayed in
    // as a string
    NSString * recipeDateString;
    
    // The day of the week that this recipe should be displayed in 
    // as an int
    int recipeDateInt;
    
    // The URL that corresponds to this recipe
    NSURL * recipeURL;
    
    // The ingredients for this recipe
    NSMutableArray * recipeIngredients;
}

// The Objective-C properties that correspond to the instance variables
// so that we can reference them with dot notation outside the class.
@property (copy) NSString * recipePage;
@property (copy) NSString * recipeTitle;
@property (copy) NSString * recipeDateString;
@property int recipeDateInt;
@property (copy) NSURL * recipeURL;
@property (copy) NSMutableArray * recipeIngredients;

// The constructor
-(Recipe *) init;

// The destructor for this class
-(void) dealloc;

@end
