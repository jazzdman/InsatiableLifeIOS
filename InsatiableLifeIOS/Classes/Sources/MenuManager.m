//
//  MenuManager.m
//  Full Plate
//
//  Created by Jason Mazzotta on 2/5/12.
//  Copyright (c) 2012 Full Plate Productions. All rights reserved.
//

#import "MenuManager.h"

static MenuManager * singleton = nil;

@implementation MenuManager

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method allows the program to access the same instance
 *            of the AllRecipesManager from anywhere in the program.  
 *            Ultimately, this class is a Singleton because we need
 *            to be able to save the contents of this class when the 
 *            application closes.
 *
 *  Outputs : AllRecipesManager - static pointer to an AllRecipesManager object
 *
 ******************************************************************/
+(MenuManager *) instance
{	
    @synchronized(self) 
    {
        // Allocate and init the static pointer the first time
        // and only the first time.
        if (singleton == nil) 
        {
            singleton = [[super allocWithZone:NULL] init];
        }
	}
    
	return singleton;
}

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method is the "constructor" for this class.  It
 *            initializes all member variables.  In particular, it 
 *            initializes the tableCells from a database if any data
 *            was saved there previously.
 *
 *  Outputs : AllRecipesManager - a pointer to an AllRecipesManager object
 *
 ******************************************************************/
-(MenuManager *) init;
{
    Recipe * recipe;
    FMResultSet * rs = NO;
    BOOL dbOK = YES; 
    FullPlateAppDelegate * fpAppDelegate;
    NSFileManager * fileManager;
    NSError * error;
    NSArray * paths;
    NSString * documentsDirectory, * writableDBPath, * defaultDBPath;
    
    
    // Call the init method for the super class
    self=[super init];
    
    
	if (self) 
	{
        
        fileManager = [NSFileManager defaultManager];
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"menu.db"];
        
        // Copy the menu.db file into the right place 
        if (![fileManager fileExistsAtPath:writableDBPath])
        {
            defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"menu.db"];
            dbOK &= [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        }
        
        menuDB = [[FMDatabase databaseWithPath:writableDBPath] retain];
        menuDB.traceExecution = YES;
        menuDB.logsErrors = YES;
        dbOK &= [menuDB open];
        
        // Recover any Recipes that may have been saved previously. 
        rs = [menuDB executeQuery:@"select * from menu"];
        
        if (rs != NO && [rs hasAnotherRow]) {
            dbOK &= [[NSUserDefaults standardUserDefaults] boolForKey:@"serializeResults"];
        }
        
        
        // Check to make sure the query actually worked
        if (dbOK && rs != NO) 
        {
            // Recreate the Menu View Cells from the database rows
            while ([rs next]) 
            {
                recipe = [[Recipe alloc] init];
                recipe.recipePage = [rs stringForColumn:@"page"];
                recipe.recipeTitle = [rs stringForColumn:@"title"];
                recipe.recipeDateString = [rs stringForColumn:@"datestring"];
                recipe.recipeDateInt = [rs intForColumn:@"dateint"];
                recipe.recipeURL = [NSURL URLWithString:[rs stringForColumn:@"url"]];
                [recipe.recipeIngredients addObjectsFromArray: [[rs stringForColumn:@"ingredients"] componentsSeparatedByString:@";"]];
                [[AllRecipesProxy instance].recipeList addObject:recipe];
                [recipe release];
            }
            
        }
        
        // If the database query didn't work, let the user know.
        if (!dbOK) 
        {
            fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
            
            [fpAppDelegate showAlertWithTitleandMessage: [NSArray arrayWithObjects: @"Error",
                                                          @"Unable to recover Menu View.  Please exit and start Full Plate.[AllRecipesManager init]",
                                                          nil]];
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

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : Save the current collection of MenuViewCells 
 *            to a sqlite database.
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) serializeMenu
{
    // A string to hold the ingredients, since we can't save them as an array
    NSMutableString * tempIngredients = [[NSMutableString alloc] initWithCapacity:1];
    BOOL dbOK = YES;
    
    NSLog(@"serializeMenu has been called.");    
    
    // Clear out the currect contents of the menu database
    [menuDB executeUpdate:@"delete from menu"];
    
    // Begin a transaction to save the contents of the tableCells
    dbOK &= [menuDB beginTransaction];
    
    // For each tableCell
    for(Recipe * recipe in [AllRecipesProxy instance].recipeList)
    {        
        // Construct a string of ingredients
        for (NSString * ingredient in recipe.recipeIngredients) 
        {
            [tempIngredients appendString:ingredient];
            [tempIngredients appendString:@";"];
        }
        
        [tempIngredients deleteCharactersInRange:NSMakeRange([tempIngredients length]-1, 1)];
        
        // Add this cell to the database
        dbOK &= [menuDB executeUpdate:@"insert into menu (page, title, datestring, dateint, url, ingredients) values (?, ?, ?, ?, ?, ?)",
                 recipe.recipePage,
                 recipe.recipeTitle,
                 recipe.recipeDateString,
                 [NSNumber numberWithInt:recipe.recipeDateInt],
                 recipe.recipeURL.absoluteString,
                 tempIngredients];
        
        // Reset the string of ingredients
        [tempIngredients setString:@""];
    }
    
    // Commit this update to the database.
    [tempIngredients release];
    
    dbOK &= [menuDB commit];
    
    // Store the success/failure result of the database saving
    [[NSUserDefaults standardUserDefaults] setBool:dbOK forKey:@"serializeResults"];
    
}

-(void) dealloc
{
    if (menuDB) {
        [menuDB close];
        [menuDB release];
    }
    
    [super dealloc];
}

@end
