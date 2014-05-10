//
//  PantryManager.m
//  FullPlate
//
//  Created by Jason Mazzotta on 6/11/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import "PantryManager.h"
#import "FullPlateAppDelegate.h"

static PantryManager * singleton = nil;

@implementation PantryManager

// Create the setters and getters for this property
@synthesize pantryContents;

/*****************************************************************
 *
 * Inputs  : None
 *
 * Purpose : This method allows the program to access the same instance
 *           off the PantryManager from anywhere in the program.  
 *           Ultimately, this class is a Singleton because we need
 *           to be able to save the contents of this class when the 
 *           application closes.
 *
 * Outputs : PantryManager - The one only instance of this class that
 *           will be used throughout the application.
 *
 ******************************************************************/
+(PantryManager *) instance
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


/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method is the "constructor" for this class.  It
 *            initializes all member variables.  In particular, it 
 *            initializes the Ingredients from a database if any data
 *            was saved there previously.
 *
 *  Outputs : PantryManager - a pointer to a PantryManager object
 *
 ******************************************************************/
-(PantryManager *) init 
{
    FMResultSet * rs= NO; 
    NSString * finalPath;
    BOOL dbOK = YES, fileProblem = NO;
    Ingredient * tempIngredient;
    id tempObject;
    NSFileManager * fileManager;
    NSError * error;
    NSArray * paths;
    NSString * documentsDirectory, * writableDBPath, * defaultDBPath;
    
    self = [super init];
    
    if (self) 
    {
        fileManager = [NSFileManager defaultManager];
        paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
        documentsDirectory = [paths objectAtIndex:0];
        writableDBPath = [documentsDirectory stringByAppendingPathComponent:@"pantry.db"];
        
        // Copy the pantry.db file into the right place 
        if (![fileManager fileExistsAtPath:writableDBPath]) {
            defaultDBPath = [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"pantry.db"];
            dbOK &= [fileManager copyItemAtPath:defaultDBPath toPath:writableDBPath error:&error];
        }
        
        // We do this so that the allocated memory is 
        // only retained once
        tempObject = [[NSMutableArray alloc] init];
        self.pantryContents = tempObject;
        [tempObject release];
        
        // Create the pantry database
        pantryDB = [[FMDatabase databaseWithPath:writableDBPath] retain];
        pantryDB.traceExecution = NO;
        pantryDB.logsErrors = YES;
        
        // Create the granular dictionary
        finalPath = [[NSBundle mainBundle] pathForResource:@"bulk" ofType:@"plist"];
        bulk = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        fileProblem |= (bulk == nil);
        if (!fileProblem) {
            [bulk retain];
        }
        
        // Create the individual dictionary
        finalPath = [[NSBundle mainBundle] pathForResource:@"individuals" ofType:@"plist"];
        individuals = [NSDictionary dictionaryWithContentsOfFile:finalPath];
        fileProblem |= (individuals == nil);
        if (!fileProblem) {
            [individuals retain];
        }
        
        
        //Open the database and 
        dbOK &= [pantryDB open];
        
        // Get the contents of the database
        rs = [pantryDB executeQuery:@"select * from pantry"];
        
        if (rs!=NO && [rs hasAnotherRow]) {
            dbOK &= [[NSUserDefaults standardUserDefaults] boolForKey:@"serializeResults"];
        }
       
        if (dbOK && rs != NO && !fileProblem) 
        {

            // Create Ingredients from anything stored in the pantry database.
            while ([rs next]) 
            {
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

                
                [self.pantryContents addObject:tempIngredient];
                [tempIngredient release];
                // NSLog(@"I'm recovering something from the pantry databse???");
            }

        } 
        if (!dbOK) 
        {
            
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects:@"Error"
                                                                                                                 , @"Unable to recover Pantry View.  Please exit and start Full Plate.[PantryManager init]",nil]];
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
- (NSUInteger)retainCount {
    return UINT_MAX; //denotes an object that cannot be released
}
- (oneway void)release {
    // never release
}
- (id)autorelease {
    return self;
}
/******************************************************************/

/*******************************************************
 *
 * Inputs  : Ingredient - an ingredient that might already 
 *                       be in the database.
 *
 * Purpose : Find any Ingredient in the pantry that matches
 *           the name of the input.  If found, reduce the number
 *           of the pantry ingredient by the number of input.  If
 *           the number of the input is greater than the pantry ingredient
 *           return YES, we found the ingredient.
 *
 * Outputs : BOOL - whether or not we found the ingredient already in the
 *                  pantry.
 *
 ********************************************************/
-(BOOL) checkIngredient:(Ingredient *)ingredient
{
    BOOL foundIngredient = NO;
    
    // Search through all the Ingredients in the pantry
    for (Ingredient * tempIngredient in self.pantryContents) 
    {
        // If the name of a pantry ingredient matches that of the
        // input.
        if ([tempIngredient.name isEqualToString:ingredient.name]) 
        {
            
            // Reduce the ammount in the pantry by the amount
            // if the input
            if (tempIngredient.number > ingredient.number) 
            {
                tempIngredient.number -= ingredient.number;
                foundIngredient = YES;
                break;
            }
            
            // Remove the ingredient in the pantry altogether
            if (tempIngredient.number == ingredient.number) 
            {
                [pantryContents removeObject:tempIngredient];
                foundIngredient = YES;
                break;
            }
            
            // Remove the ingredient from the pantry and reduce
            // the quantity of the input ingredient by the amount
            // in the pantry.
            if (tempIngredient.number < ingredient.number) 
            {
                ingredient.number -= tempIngredient.number;
                [self.pantryContents removeObject:tempIngredient];
                foundIngredient = NO;
                break;
            }
        }
    }
    
    return foundIngredient;
}

/*********************************************************
 *
 * Inputs  : None
 *
 * Purpose : Store the Ingredients in the pantry into a database.
 *           This method is called when the application quits or 
 *           is put in the background.
 *
 * Outputs : None
 *
 ************************************************************/
-(void) serializePantry
{
    BOOL dbOK = YES;
    Ingredient * ingredient;
    NSNumber * number1, * number2, * number3, * number4, * number5, * number6, * number7; 
    
    NSLog(@"serializePantry has been called.");
    
    // A bit brute force, but faster.  Clear out the
    // contents of the pantry.
    dbOK &= [pantryDB executeUpdate:@"delete from pantry"];
    
    // Store each of the ingredients in the pantry 
    // into the database.
    dbOK &= [pantryDB beginTransaction];
    for(int i = 0; i< [self.pantryContents count];i++)
    {
        ingredient = [self.pantryContents objectAtIndex:i];
        
        number1 = [NSNumber numberWithFloat:ingredient.number];
        number2 = [NSNumber numberWithBool:ingredient.inContainer];
        number3 = [NSNumber numberWithBool:ingredient.isPerishable];
        number4 = [NSNumber numberWithBool:ingredient.isLiquid];
        number5 = [NSNumber numberWithBool:ingredient.isBulk];
        number6 = [NSNumber numberWithBool:ingredient.isIndividual];
        number7 = [NSNumber numberWithBool:ingredient.needsPrep];
        dbOK &= [pantryDB executeUpdate:@"insert into pantry (number, quantity, name, incontainer, isperishable, isliquid, isbulk, isindividual, needsprep) values (?, ?, ?, ?, ?, ?, ?, ?, ?)", 
         number1,
         ingredient.quantity,
         ingredient.name,
         number2,
         number3,
         number4,
         number5,
         number6,
         number7];

    }
    dbOK &= [pantryDB commit];
    
    // Store the success/failure result of the database saving
    [[NSUserDefaults standardUserDefaults] setBool:dbOK forKey:@"serializeResults"];
    
}

/*********************************************************
 *
 * Inputs  : Ingredient - the ingredient to be saved into the pantry
 *           NSString - one of a number of things, the size of the container of the 
 *                      ingredient, the volume of the container of the ingredient
 *                      or the weight of the ingredient.
 *
 * Purpose : To save the ingredient to the pantry depending on the type of the
 *           ingredient, liquid, bulk, individual or general.
 *
 * Outputs : None
 *
 ************************************************************/
-(BOOL) saveIngredient:(Ingredient *)ingredient withProperty:(NSString *)property
{
    BOOL foundIngredient = NO;
    NSRange tempRange;
    float poundPintNumber, tempTotalNumber;
    NSArray * keys;
    NSString * key=nil;
    Ingredient * tempIngredient = [ingredient copy];
    
    // If the ingredient is a liquid, the property is a volume
    // and we need to parse the volume
    if (tempIngredient.isLiquid) 
    {
        if ([[property componentsSeparatedByString:@" "] count] == 2) 
        {
            if ([[[property componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"pt"]) {
                tempTotalNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]*TBSP_PER_PINT/VOLUME_OUNCE_PER_TABLESPOON;
                if (tempTotalNumber <= ingredient.number)
                {
                    [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                              delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning", @"Selected volume is less than required volume.", nil]];
                    [tempIngredient release];
                    return NO;
                }
                tempIngredient.number = tempTotalNumber - ingredient.number;
            } else {
                tempTotalNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]/ 
                VOLUME_OUNCE_PER_TABLESPOON; 
                
                if (tempTotalNumber <= ingredient.number)
                {
                    [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                              delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning"
                                                                                      @"Selected volume is less than required volume.", nil]];
                    [tempIngredient release];
                    return NO;
                }
                tempIngredient.number = tempTotalNumber - ingredient.number;
            }
            
        } else {
            poundPintNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]*TBSP_PER_PINT;
            
            tempTotalNumber = (poundPintNumber + [[[property componentsSeparatedByString:@" "] objectAtIndex:2] intValue])/VOLUME_OUNCE_PER_TABLESPOON;
            
            if (tempTotalNumber <= ingredient.number) 
            {
                [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                          delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                  @"Selected volume is less than required volume.", nil]];
                [tempIngredient release];
                return NO;
            }
            tempIngredient.number = tempTotalNumber - ingredient.number;
        }
        
    }
    // If the ingredient is bulk, the property is a weight and we
    // need to convert the weight to a volume through the ingredient's
    // density.
    else if (tempIngredient.isBulk) {
        
        keys = [bulk allKeys];
        
        for (key in keys) 
        {
            tempRange = [tempIngredient.name rangeOfString:key];
            if (tempRange.location != NSNotFound) 
            {
                foundIngredient = YES;
                break;
            }
            
        }
        
        if (foundIngredient) 
        {
            if ([[property componentsSeparatedByString:@" "] count] == 2) 
            {
                if ([[[property componentsSeparatedByString:@" "] objectAtIndex:1] isEqualToString:@"oz."]) 
                {
                    tempTotalNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]/
                    [[bulk objectForKey:key] floatValue];
                    if (tempTotalNumber <= ingredient.number) 
                    {
                        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                                  delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                          @"Selected volume is less than required volume.", nil]];
                        [tempIngredient release];
                        return NO;
                    }

                    tempIngredient.number = tempTotalNumber - ingredient.number;
                } else {
                    tempTotalNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]*OZ_PER_POUND/
                    [[bulk objectForKey:key] floatValue];
                    
                    if (tempTotalNumber <= ingredient.number) 
                    {
                        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                                  delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects:@"Warning",
                                                                                          @"Selected volume is less than required volume.", nil]];
                        [tempIngredient release];
                        return NO;
                    }

                    tempIngredient.number = tempTotalNumber - ingredient.number;
                }
                
            } else {
                poundPintNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:0] intValue]*OZ_PER_POUND/
                [[bulk objectForKey:key] floatValue];
                
                tempTotalNumber = [[[property componentsSeparatedByString:@" "] objectAtIndex:2] intValue]/
                [[bulk objectForKey:key] floatValue] + poundPintNumber;
                
                if (tempTotalNumber <= ingredient.number) {
                    [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                              delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects: @"Warning",
                                                                                      @"Selected volume is less than required volume.", nil]];
                    [tempIngredient release];
                    return NO;
                }
                
                tempIngredient.number =  tempTotalNumber - ingredient.number;
            }
        } else {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects: @"Error",
                                                                                                                 @"Couldn't find bulk item to add to pantry.", nil]];
            [tempIngredient release];
            return NO;
        }
        
    }
    // If the ingredient is a container of individuals (e.g bay leaves), we
    // need to save the number of that ingredient.
    else if(tempIngredient.isIndividual) {
        
        keys = [individuals allKeys];
        
        for (key in keys) 
        {
            tempRange = [tempIngredient.name rangeOfString:key];
            if (tempRange.location != NSNotFound) 
            {
                foundIngredient = YES;
                break;
            }
        }
        
        if (foundIngredient) 
        {
            tempIngredient.number = [[bulk objectForKey:key] intValue] - ingredient.number;
        } else {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects: @"Error",
                                                                                                                 @"Couldn't find individual item to add to pantry.", nil]];
            [tempIngredient release];
            return NO;
        }

    }
    // Otherwise, we assume the ingredient is a spice, which can have
    // three container/volume sizes.
    else {
    
        tempRange = [property rangeOfString:@"Small"];
        if (tempRange.location != NSNotFound) 
        {
            if (SMALL_CONTAINER_VOLUME <= ingredient.number) {
                [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                          delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                  @"Selected volume is less than required volume.", nil]];
                [tempIngredient release];
                return NO;
            }
            tempIngredient.number = SMALL_CONTAINER_VOLUME - ingredient.number;
        }
        
        tempRange = [property rangeOfString:@"Medium"];
        if (tempRange.location != NSNotFound) 
        {
            if (MEDIUM_CONTAINER_VOLUME <= ingredient.number) {
                [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                          delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                  @"Selected volume is less than required volume.", nil]];
                [tempIngredient release];
                return NO;
            }
            tempIngredient.number = MEDIUM_CONTAINER_VOLUME - ingredient.number;
        }

        tempRange = [property rangeOfString:@"Large"];
        if (tempRange.location != NSNotFound) 
        {
            if (LARGE_CONTAINER_VOLUME <= ingredient.number) {
                [(FullPlateAppDelegate *)[[UIApplication sharedApplication] 
                                          delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                            @"Selected volume is less than required volume.", nil]];
                [tempIngredient release];
                return NO;
            }
            tempIngredient.number = LARGE_CONTAINER_VOLUME - ingredient.number;
        }
        
    } 
      
    [self.pantryContents addObject:tempIngredient];
    [tempIngredient release];
    
    return YES;
}

/*************************************************
 *
 * Inputs  : None
 *
 * Purpose : Release the memory pointed to by the instance
 *           variables of this class.
 *
 * Outputs : None
 *
 *************************************************/
-(void) dealloc
{
    
    if (pantryDB) {
        [pantryDB close];
        [pantryDB release];
    }
    
    if (pantryContents) {
        [pantryContents release];
    }
    
    if (bulk) {
        [bulk release];
    }
    
    if (individuals) {
        [individuals release];
    }
    [super dealloc];
}

@end
