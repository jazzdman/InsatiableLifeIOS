//
//  GroceriesManager.h
//  FullPlate
//
//  Created by Jason Mazzotta on 6/4/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ingredient.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"
#import "NSString+HTML.h"

/********************************************
 *
 * The purpose of this class is to act as the Abstraction part
 * of the Groceries display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Spefically this object help to create a list of ingredients compiled
 * from the recipes chosen in th Menu display.  This also involves scaling
 * certain ingredient to "container" size and making sure that an ingredient
 * is not already contained in the Pantry.
 *
 ********************************************/

@interface GroceriesManager : NSObject 
{
    // The database into which the contents of the Grocery display
    // are saved between invocations of the program
    FMDatabase * groceryDB;
    // The list of ingredients we compile from the ingredients
    // in all the recipes
    NSMutableArray * groceries;
}

// A property that allows us to see the groceries created
// by this class outside this class
@property (retain) NSMutableArray * groceries;

// The singleton method for this class
+(GroceriesManager *) instance;

// The constructor/initializer for this class
-(id)init;

// This method saves the contents of the Groceries view to a database for future use
-(void) serializeGroceries;

// Sort the groceries and grocerycells in alphabetical order
-(void) sortGroceries;

// Find out if an ingredient has already been seen and add it if
// it has not.
-(int) compareAndAdd:(Ingredient *)ingredient;

// This method releases all references to the 
-(void) dealloc;

@end
