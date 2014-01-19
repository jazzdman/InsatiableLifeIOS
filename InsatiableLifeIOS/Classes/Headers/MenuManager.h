//
//  MenuManager.h
//  Full Plate
//
//  Created by Jason Mazzotta on 2/5/12.
//  Copyright (c) 2012 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "FullPlateAppDelegate.h"
#import "AllRecipesProxy.h"
#import "Recipe.h"
#import "FMDatabase.h"
#import "FMDatabaseAdditions.h"
#import "FMResultSet.h"

@interface MenuManager : NSObject
{
    // A pointer to the sqlite databased used to serialize the 
    // Recipes that are ultimately created by this class.
    FMDatabase * menuDB;
}

// The singleton method for this class
+(MenuManager *) instance;

// The "constructor"/init method
// This assigns values to the instance variables
-(MenuManager *) init;

// The method that saves the contents of the tableCells into a sqlite database
-(void) serializeMenu;

// The "destructor", release the memory retained in instance variables
// and do any other clean up so there are no memory leaks when an object
// of this class is released.
-(void) dealloc;

@end

