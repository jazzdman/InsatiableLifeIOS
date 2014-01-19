//
//  GroceriesManager.m
//  FullPlate
//
//  Created by Jason Mazzotta on 6/4/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import "FullPlateAppDelegate.h"
#import "PantryManager.h"
#import "SettingsManager.h"
#import "GroceriesManager.h"

static GroceriesManager * singleton = nil;

@implementation GroceriesManager

// Create the getter and setter methods for the properties
@synthesize groceries;

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method allows the program to access the same instance
 *            of the GroceriesManager from anywhere in the program.  
 *            Ultimately, this class is a Singleton because we need
 *            to be able to save the contents of this class when the 
 *            application closes.
 *
 *  Outputs : GroceriesManager - static pointer to a GroceriesManager object
 *
 ******************************************************************/
+(GroceriesManager *) instance
{
	@synchronized(self) 
    {
        if (singleton == nil) 
        {
            singleton = [[super allocWithZone:NULL] init];
        }
    }
	return singleton;
}

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Set initial values for the member variables
 *           of an object of this class.
 *
 * Outputs : An initialized object of type GrocerieManager
 *
 ***************************************************/
-(id) init
{
    id tempObject;
    NSError * error;
    BOOL dbOK = YES, fileProblem = NO;
    int red, green, blue;
    Ingredient * tempIngredient;
    FMResultSet *rs = NO;
    NSFileManager * fileManager;
    NSArray * paths;
    NSString * documentsDirectory, * writableDBPath, * defaultDBPath;
    
    self = [super init];
    
    if (self) 
    {
        
        // Initialize the array of groceries
        tempObject = [[NSMutableArray alloc] initWithCapacity:1];
        self.groceries = tempObject;
        [tempObject release];
        
        fileManager = [NSFileManager defaultManager];
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"groceries.db"];
        
        // Copy the groceries.db file into the right place 
        if (![fileManager fileExistsAtPath:writableDBPath]) {
            defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"groceries.db"];
            dbOK &= [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        }
        groceryDB = [[FMDatabase databaseWithPath:writableDBPath] retain];
        groceryDB.traceExecution = NO;
        groceryDB.logsErrors = YES;
        dbOK &= [groceryDB open];
        
        // Get all rows of the grocries table
        rs = [groceryDB executeQuery:@"select * from groceries"];
        
        if (rs != NO && [rs hasAnotherRow]) {
            dbOK &= [[NSUserDefaults standardUserDefaults] boolForKey:@"serializeResults"];
        }
        
        if (dbOK && rs != NO && ![[SettingsManager instance] timeToShop])
        {
            // Read through each row
            while ([rs next]) 
            {
                // Create an ingredient from a row
                tempIngredient = [[Ingredient alloc] init];
                tempIngredient.number = [rs doubleForColumn:@"number"];
                tempIngredient.quantity = [rs stringForColumn:@"quantity"];
                tempIngredient.name = [rs stringForColumn:@"name"];
                tempIngredient.inContainer = [rs boolForColumn:@"incontainer"]; 
                tempIngredient.isPerishable = [rs boolForColumn:@"isperishable"];
                tempIngredient.isLiquid = [rs boolForColumn:@"isliquid"];
                tempIngredient.isBulk = [rs boolForColumn:@"isbulk"];
                tempIngredient.isIndividual = [rs boolForColumn:@"isindividual"];
                tempIngredient.needsPrep = [rs boolForColumn:@"needsprep"];
                red = [rs intForColumn:@"red"]; 
                green = [rs intForColumn:@"green"];
                blue = [rs intForColumn:@"blue"];
                tempIngredient.color = [UIColor colorWithRed:(float)red/255.0 
                                     green:(float)green/255.0 
                                     blue:(float)blue/255.0 
                                     alpha:1.0];
                                
                // Hold onto the ingredient that has been created
                [self.groceries addObject:tempIngredient];
                [tempIngredient release];

            }
        }
        
        if (!dbOK || rs == NO || fileProblem) 
        {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                                [NSArray arrayWithObjects: @"Error",
                                                                                 @"Unable to recover Groceries View.  Please exit and restart FullPlate (GroceriesManager init)", nil]];
        }
        
    }
    
    return self;
}

/***************************************************************
 *
 * The following methods help to define a singleton in Objective-C
 *
 ***************************************************************/
+(id) allocWithZone:(NSZone *)zone
{
    return [[self instance] retain];
}

- (id)copyWithZone:(NSZone *)zone 
{
    return self;
}
- (id)retain {
    return self;
}
- (unsigned)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
/******************************************************************/


/***************************************************
 *
 * Inputs  : An ingredient to add to the list of groceries.
 *
 * Purpose : Check to see if the input ingredient has a name 
 *           that matches an ingredient that has already been
 *           added.  If so, add the number of the ingredient to
 *           the already known ingredient.  If the ingredient is
 *           new, add it to the list of groceries.
 *
 * Outputs : None.
 *
 ***************************************************/
-(int) compareAndAdd:(Ingredient *)ingredient
{
    BOOL foundIngredient = NO;
    NSRange tempRange;
    int insertIndex=-1;
    Ingredient * tempIngredient;
    
    ingredient.name = [ingredient.name stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
    
    // Iterate through all the groceries we've collected
    // so far.
    for (int i=0;i<[self.groceries count];i++) 
    {
        insertIndex = i;
        tempIngredient = [self.groceries objectAtIndex:i];
        // We've seen this ingredient before, so we 
        // only need to add the number of this ingredient
        // to the saved one.
        if ([tempIngredient.name isEqualToString:ingredient.name] &&
            [tempIngredient.quantity isEqualToString:ingredient.quantity]) 
        {
            tempIngredient.number += ingredient.number;
            foundIngredient = YES;
            NSLog(@"Found an ingredient in common.");
            break;
        }

    }

    tempRange = [ingredient.name rangeOfString:@"water"];
    // Add ingredients we haven't seen before.
    // Don't add water
    if (!foundIngredient &&
        !ingredient.isLiquid &&
        tempRange.location == NSNotFound) 
    {
        [self.groceries addObject:ingredient];
    }
 
    return insertIndex;
}

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Save the contents of all the Ingredients
 *           that display groceries into a database so they
 *           can be retrieved when the program is run in 
 *           the future.
 *
 * Outputs : None.
 *
 ***************************************************/
-(void) serializeGroceries
{
    Ingredient * ingredient;
    const CGFloat * color_components;
    BOOL dbOK = YES;
    
     NSLog(@"serializeGroceries has been called.");
    
    // Delete everything that is currently in the groceries
    // database
    dbOK &= [groceryDB executeUpdate:@"delete from groceries"];
    
    // Start the transaction to save the groceryCells to 
    // the database.
    dbOK &= [groceryDB beginTransaction];
    
    // Run through all the groceryCells
    if (dbOK) 
    {
    
        for(int i = 0; i < [self.groceries count]; i++)
        {
            // Get a reference to a cell
            ingredient = [self.groceries objectAtIndex:i];
            
            // Get the color components of the text of the cell
            color_components = CGColorGetComponents(ingredient.color.CGColor);
            
            // Save this information into the database
            dbOK &= [groceryDB executeUpdate:@"insert into groceries (number, quantity, name, incontainer, isperishable, isliquid, isbulk, isindividual, needsprep, red, green, blue) values (?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?, ?)", 
             [NSNumber numberWithFloat:ingredient.number],
             ingredient.quantity,
             ingredient.name,
             [NSNumber numberWithBool:ingredient.inContainer],
             [NSNumber numberWithBool:ingredient.isPerishable],
             [NSNumber numberWithBool:ingredient.isLiquid],
             [NSNumber numberWithBool:ingredient.isBulk],
             [NSNumber numberWithBool:ingredient.isIndividual],
             [NSNumber numberWithBool:ingredient.needsPrep],
             [NSNumber numberWithInt:(int)(color_components[0]*255.0)],
             [NSNumber numberWithInt:(int)(color_components[1]*255.0)],
             [NSNumber numberWithInt:(int)(color_components[2]*255.0)]];
        }

    }
        
    // Commit this database update 
    dbOK &= [groceryDB commit];
    
    // Store the success/failure result of the database saving
    [[NSUserDefaults standardUserDefaults] setBool:dbOK forKey:@"serializeResults"];

}

/*****************************************************
 *
 * Inputs  : None
 *
 * Purpose : Sort the groceries and grocerycells in alphabetical order.
 *
 * Outputs : None
 *
 *****************************************************/
-(void) sortGroceries
{
    
	Ingredient * firstIngredient, * secondIngredient;
    BOOL swapped = YES;
    int j = 0;
    
    // Do a simple bubble sort on ingredient names
    while (swapped) 
    {
        swapped = false;
        j++;
        
        for (int i = 0 ; i< [[GroceriesManager instance].groceries count]-j; i++) 
        {
            firstIngredient = [[GroceriesManager instance].groceries objectAtIndex:i];
            secondIngredient = [[GroceriesManager instance].groceries objectAtIndex:i+1];
            
            if ([secondIngredient.name compare:firstIngredient.name] == NSOrderedAscending) {
                [[GroceriesManager instance].groceries exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                swapped = true;
            }
        }
    }    
}


/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Release all references to the member variables
 *           in this class.
 *
 * Outputs : None
 *
 ***************************************************/
-(void) dealloc
{
    if (groceries) {
        [groceries release];
    }
    
    if (groceryDB) {
        [groceryDB close];
        [groceryDB release];
    }
    
    [super dealloc];
    
}

@end
