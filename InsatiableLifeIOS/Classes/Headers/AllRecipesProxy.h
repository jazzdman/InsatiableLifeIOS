//
//  AllRecipesProxy
//  FullPlate
//
//  Created by Jason Mazzotta on 5/16/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"
#import "Ingredient.h"
#import "GroceriesManager.h"
#import "Recipe.h"


#define RECIPE_TITLE 0
#define RECIPE_URL 1
#define RECIPE_INGREDIENT 2
#define RECIPE_PAGE 3
#define RECIPE_COUNT 4
#define SERVER_INIT_ERROR -1
#define SERVER_GENERAL_ERROR -4
#define SERVER_COLLECT_ERROR -5
#define INVALID_PARAMETERS_ERROR -3
#define EMPTY -10

/********************************************
 *
 * The purpose of this class is to act as the Abstraction part
 * of the Groceries display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Spefically this object helps to create a list of ingredients compiled
 * from the recipes chosen in the Menu display.   
 *
 ********************************************/

@class MenuViewController;
@class FullPlateAppDelegate;

@interface AllRecipesProxy : NSObject <NSXMLParserDelegate>
{
    
    // The Recipes that are created as a result of the recipe search.
    NSMutableArray * recipeList;
    
    // This allows the Groceries View to decide whether to update itself
    BOOL recipesUpdated;
    
    // Lets this class know if it should wait to add a recipe to its recipe
    // list
    BOOL threadWait;
    
    // The current day that the thread is search for recipes for.
    int generateStep;
    
    // If an ingredient contains one of these "quantities", it needs
    // preparation
    NSArray * quantities; 
    // A list of word that describe an ingredient that
    // will need prepration (e.g. chopped, diced, sliced)
    NSArray * preparations;
    // A list of items that would be perishable and thus not
    // end up 
    NSArray * perishables;
    // A list of liquids that would be in a container
    NSArray * liquids;
    // A dictionary of bulk items (e.g. flour) and their densities
    NSDictionary * bulk;
    // A dictionary of items in a container that can be seen as whole individuals 
    // (e.g. cinnamon sticks) and a number you're likely to find in a container
    NSDictionary * individuals; 
    // Helps to determine if an ingredient needs preparation
    BOOL hasParens;
    // Do any of the recipes need prep?
    BOOL needsPrep;
    
    int totalRecipes;
    
    int currentRecipe;
    
    float progress;
    
    int count;
    
    BOOL foundRepeat;
    
    BOOL firstTime;
    
    MenuViewController * menuViewController;
    
    NSDictionary * elements;
    
    int elementType;
    
    BOOL serverError;
    
    FullPlateAppDelegate * fpAppDelegate;

    NSMutableArray * _recipes;
    
}

// A property that wraps around the tableCells instance 
// variable so we can more easily access it from other classes
@property (retain) NSMutableArray * recipeList;
@property BOOL recipesUpdated;
@property BOOL threadWait;
@property int generateStep;

// The singleton method for this class
+(AllRecipesProxy *) instance;

// The "constructor"/init method
// This assigns values to the instance variables
-(AllRecipesProxy *) init;

// The method called from another class to start the search for
// recipes and ultimately create the tableCells array
-(void) generateRecipes;

// The method that takes the string returned by a request to the
// server and breaks it into recipes
-(void) parseRecipes:(NSURL *)request;

// Decide if a recipe string should be passed onto buildIngredient
-(void) parseGroceries:(NSMutableArray *)allIngredients;

// The method that finds the number in an ingredient (e.g. the 1 in 1 cup flour)
-(int) findNumber:(NSArray *)components fromIndex:(int)start inIngredient:(Ingredient *)ingredient;

// The method that finds the quantity in an ingredient (e.g. the cup in 1 cup flour)
-(int) findQuantity:(NSArray *)components fromIndex:(int)start inIngredient:(Ingredient *)ingredient;

// The method that find the name in an ingredient (e.g. the flour in 1 cup flour)
-(void) findName:(NSArray *)components fromIndex:(int)start inIngredient:(Ingredient *)ingredient;

// Scale quantities of cups and tablespoons down to teaspoons and determine if 
// an ingredient needs preparation, is in a container, is perishable and/or is a liquid
-(void) scaleQuantity:(Ingredient *)ingredient;

// Decide whether an ingredient falls outside the general
// form of number quantity name (e.g. 1/2 c flour)
-(BOOL) isSpecialCase:(NSString *) ingredientString;

// The method that changes breaks an ingredient into a discreet number,
// quantity and name.
-(int) buildIngredient:(NSString *) ingredientString;

// The "destructor", release the memory retained in instance variables
// and do any other clean up so there are no memory leaks when an object
// of this class is released.
-(void) dealloc;


@end
