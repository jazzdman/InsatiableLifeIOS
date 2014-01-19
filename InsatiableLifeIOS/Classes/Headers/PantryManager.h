//
//  PantryManager.h
//  FullPlate
//
//  Created by Jason Mazzotta on 6/11/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "Ingredient.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@class FullPlateAppDelegate;

#define SMALL_CONTAINER_VOLUME 4.394f
#define MEDIUM_CONTAINER_VOLUME 6.767f
#define LARGE_CONTAINER_VOLUME 15.548f

/********************************************
 *
 * The purpose of this class is to act as the Abstraction part
 * of the Groceries display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Spefically this object help to create a list of ingredients compiled
 * from the recipes chosen in th Menu display.  This also involves scaling
 * certain ingredient to "container" size and making sure that an ingredient
 * is not already contained in Pantry.
 *
 ********************************************/

@interface PantryManager : NSObject 
{
    // A pointer to the database into which we will store the
    // contents of the pantry when the application is turned off
    FMDatabase * pantryDB;
    
    // The array of Ingredients we have in the pantry
    NSMutableArray * pantryContents;
    
    // A dictionary of bulk ingredients and their densities
    NSDictionary * bulk;
    
    // A dictionary of ingredients stored in a bottle but used individually (e.g. bay leaves)
    // and the number of such items one can expect to find 
    NSDictionary * individuals;
    
}

// This allows us to access the pantryContents instance variable
// with dot notation outside the class.
@property (retain) NSMutableArray * pantryContents;

// The singleton method for this class
+(PantryManager *) instance;

// The constructor for this class
-(id) init;

// Is an ingredient in the pantry?
-(BOOL) checkIngredient:(Ingredient *)ingredient;

// Save the contents of the pantry to the database
-(void) serializePantry;

// Save an ingredient to the pantry
-(BOOL) saveIngredient:(Ingredient *)ingredient withProperty:(NSString *)property;

// The destructor 
-(void) dealloc;

@end
