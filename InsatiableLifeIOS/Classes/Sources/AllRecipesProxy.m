//
//  AllRecipesManager.m
//  FullPlate
//
//  Created by Jason Mazzotta on 5/16/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "AllRecipesProxy.h"
#import "FullPlateAppDelegate.h"
#import "MenuViewController.h"
#import "GZIP.h"

static AllRecipesProxy * singleton = nil;

@implementation AllRecipesProxy

// Create the getter and setter methods for the properties
@synthesize recipeList = _recipes;
@synthesize recipesUpdated;
@synthesize threadWait;
@synthesize generateStep;

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
+(AllRecipesProxy *) instance
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
-(AllRecipesProxy *) init;
{
    FMResultSet * rs = NO;
    BOOL dbOK = YES, fileProblem = NO; 
    NSError * error;
    NSString * finalPath, * tempString;
    UINavigationController * nc;

    
    // Call the init method for the super class
    self=[super init];
    
    
	if (self) 
	{
        self.generateStep = [[NSUserDefaults standardUserDefaults] integerForKey:@"generateStep"];
        
        elements = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                       [NSNumber numberWithInt:RECIPE_TITLE],
                                                       [NSNumber numberWithInt:RECIPE_URL],
                                                       [NSNumber numberWithInt:RECIPE_INGREDIENT],
                                                       [NSNumber numberWithInt:RECIPE_PAGE],
                                                       [NSNumber numberWithInt:RECIPE_COUNT], nil]
                                 forKeys: [NSArray arrayWithObjects:@"title", @"url", @"ingredient", @"page", @"count",nil]];
        [elements retain];
        
              
        // Initialize and retain an array to hold the 
        // Recipes this class creates.
         _recipes = [[NSMutableArray alloc] initWithCapacity:1];
        [_recipes retain];
        
        // Check to make sure the query actually worked
        if (dbOK && rs != NO) 
        {
            // Create the array of quantities
            finalPath = [[NSBundle mainBundle] pathForResource:@"quantities" ofType:@"txt"];
            tempString = [NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
            fileProblem = (tempString == nil);
            if (!fileProblem) 
            {
                quantities = [[tempString componentsSeparatedByString:@"\n"] retain];
            }
            
            // Create the array of preparations
            finalPath = [[NSBundle mainBundle] pathForResource:@"preparations" ofType:@"txt"];
            tempString = [NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
            fileProblem = (tempString == nil);
            if (!fileProblem) 
            {
                preparations = [[tempString componentsSeparatedByString:@"\n"] retain];
            }
            
            // Create the array of perishables
            finalPath = [[NSBundle mainBundle] pathForResource:@"perishables" ofType:@"txt"];
            tempString = [NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
            fileProblem = (tempString == nil);
            if (!fileProblem) {
                perishables = [[tempString componentsSeparatedByString:@"\n"] retain];
            }
            
            
            // Create the array of liquids
            finalPath = [[NSBundle mainBundle] pathForResource:@"liquids" ofType:@"txt"];
            tempString =[NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
            fileProblem = (tempString == nil);
            if (!fileProblem) 
            {
                liquids = [[tempString componentsSeparatedByString:@"\n"] retain];
            }
            
            
            // Create the dictionary of individual items
            finalPath = [[NSBundle mainBundle] pathForResource:@"individuals" ofType:@"plist"];
            individuals = [NSDictionary dictionaryWithContentsOfFile:finalPath];
            fileProblem |= (individuals == nil);
            if (!fileProblem) {
                [individuals retain];
            }
            
            // Create the dictionary of bulk items
            finalPath = [[NSBundle mainBundle] pathForResource:@"bulk" ofType:@"plist"];
            bulk = [NSDictionary dictionaryWithContentsOfFile:finalPath];
            fileProblem |= (bulk == nil);
            if (!fileProblem) {
                [bulk retain];
            }

        }
        
        self.threadWait = NO;
        
        // Hold onto the menuViewController to be used in other parts of this class
        fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
        [fpAppDelegate retain];
        nc = [fpAppDelegate.tabBarController.viewControllers objectAtIndex:0];
        menuViewController = (MenuViewController *)nc.topViewController;
        [menuViewController retain];
        
        // If the database query didn't work, let the user know.
        if (!dbOK) 
        {
            
            [fpAppDelegate showAlertWithTitleandMessage: [NSArray arrayWithObjects:
                                                          @"Unable to recover Menu View.  Please exit and start Full Plate.[AllRecipesManager init]",@"Error", nil]];
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
 *  Inputs  : MenuViewController - This contains the progress bar that 
 *            indicates the progress of this search.  Ultimately, this 
 *            object uses the Recipes created here to populate its table.
 *
 *  Purpose : Create Recipes. A RecipeRequestConstructor creates a request for Bing.
 *            The AllRecipesProxy parses out the recipe URLs from that request.
 *            This method collects the contents of that recipe scaled to
 *            the number of servings that the user specified in the Settings
 *            View.  These Recipes are then used to populate the 
 *            UITableView in the MenuViewController.
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) generateRecipes
{
      // This method is called in a thread.  This is the NSAutoReleasePool
    // for that thread.
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    progress = 0.0f;
    firstTime = YES;
    
    // Pointers to the request objects we will send to allrecipes.com
    NSString * tempString = @"http://localhost:8084/InsatiableLifeCloudComponent/menu?";
    tempString = [tempString stringByAppendingString:@"maxCal="];
    tempString = [tempString stringByAppendingString:[SettingsManager instance].caloriesPerServing];
    tempString = [tempString stringByAppendingString:@"&maxPrepTime="];
    tempString = [tempString stringByAppendingString:[SettingsManager instance].prepTime];
    tempString = [tempString stringByAppendingString:@"&servings="];
    tempString = [tempString stringByAppendingString:[SettingsManager instance].servings];
    NSURL * fullPlateServer = [NSURL URLWithString: tempString];
    
    
    //NSLog(@"I'm in populateTable");
    
    // For seven days of the week
    for (int i = self.generateStep; i< 7; i++) 
    {
        
        self.generateStep = i;
        
        // Make a request to the server for recipes and
        // parse the results.
        [self parseRecipes:fullPlateServer];
     
        if (serverError) {
            break;
        }
        

        // Update the tableView with the recipes we've found so far
        [menuViewController.tableView performSelectorOnMainThread:@selector(reloadData)
                                             withObject:nil
                                          waitUntilDone:NO];
        
    }
    
    
    // At this point, we are done with the search for recipes.  This will
    // hide the progress bar.
    [menuViewController performSelectorOnMainThread:@selector(updateProgressBar:)
                                         withObject:@"done"
                                      waitUntilDone:NO];
    
    
    // This will actually fill the table with the recipes that we've found.
    [menuViewController performSelectorOnMainThread:@selector(populateTable)
                                         withObject:nil
                                      waitUntilDone:NO];
    
    
   

    self.generateStep = 0;
    // Drain the NSAutoReleasePool
    [pool drain];

}

/******************************************************************
 *
 *  Inputs  : NSURL - The URL of a recipe we wish to collect from allrecipes.com
 *            NSString - The Bing URL that ultimately lead us to the recipe URL.
 *
 *  Purpose : Collect the HTML contents of the recipe.  Use the parseRecipePage
 *            method to collect the form in the page and submit that form to
 *            scale the recipe.  Use Regular Expressions to parse out the ingredients
 *            and the title of the recipe.  Save the contents of the scaled recipe, the
 *            URL for the recipe, the title and the ingredients into an NSDictionary.
 *
 *  Outputs : NSDictionary - A dictionary that contains information about 
 *                           the recipe that has been retrieved.
 *
 ******************************************************************/
-(void) parseRecipes:(NSURL *)server
{
    NSURLResponse * response;
    NSError * error;
    NSString * tmpString;
    
    NSMutableURLRequest * tempReq = [NSMutableURLRequest requestWithURL:server
                                                            cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                        timeoutInterval:60.0];
    
    NSData * tempDat = [NSURLConnection sendSynchronousRequest: tempReq
                                             returningResponse: &response
                                                         error:&error];

    
    // The total number of recipes the AllRecipesProxy finds for
    // a particular request
    totalRecipes=0.0f;
    // The current recipe being retrieved.  This value is no
    // greater than total_recipes
    currentRecipe=0;
    count = 0;
    progress = 0;
    
    // Did we find a recipe we've collected already?
    foundRepeat=NO;
    firstTime = YES;
    
    // Create an XML parser, which makes a request to the server for recipes
    NSXMLParser * xmlParser = [[[NSXMLParser alloc] initWithData:tempDat] autorelease];
    tmpString = [[NSString alloc] initWithData:tempDat encoding:NSUTF8StringEncoding];
    [tmpString release];
    
    // Set this class as the XML parser delegate
    [xmlParser setDelegate:self];
    
    // Start processing the XML document that is received.
    [xmlParser parse];

   
}


/*******************************************************
 *
 * Inputs  : An array of ingredients collected from the
 *           recipes in the Menu view.
 *
 * Purpose : Get a reference to an ingredient string, set it
 *           to all lower case, strip out any hyphenated expressions
 *           or comma-separated expressions, find the number, quantity
 *           and name values for the ingredient, scale the ingredient
 *           and then decide if the ingredient should be added to the grocery
 *           display.
 *
 * Outputs : None.          
 *
 *******************************************************/
-(void) parseGroceries:(NSMutableArray *)allIngredients
{
    needsPrep = NO;
    
    // Iterate through all the ingredients from recipes 
    // selected in the Menu View
    for (NSString * tempString in allIngredients) 
    {
        serverError = NO;
        
        hasParens = NO;
        
        NSLog(@"The orignal ingredient %@.",tempString);
        
        // Remove items that are all in caps
        if ([[tempString uppercaseString] isEqualToString:tempString]) {
            continue;
        }
        
        // Make the string lowercase
        tempString = [tempString lowercaseString];
        
        // Remove hyphenated expressions
        tempString = [[tempString componentsSeparatedByString:@" - "] objectAtIndex:0];
        
        // Remove optional
        if ([tempString rangeOfString:@" (optional)"].location != NSNotFound) {
            tempString = [tempString stringByReplacingOccurrencesOfString:@" (optional)" withString:@""];
        }
        
        
        // Remove any extra white space
        tempString = [tempString stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceAndNewlineCharacterSet]];
        
        // Look for a few different forms of ingredients that
        // don't fit into the normal form (e.g. 1 c butter)
        if ([self isSpecialCase:tempString]) {
            continue;
        }
        
        // Convert HTML entities
        tempString = [tempString stringByDecodingHTMLEntities];
        
        //NSLog(@"This is an ingredient %@", tempString);
        
        [self buildIngredient:tempString];      
        
    }
    
    // If any ingredient needs prep, let the user know.
    if (needsPrep && [SettingsManager instance].showGuides) {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                              [NSArray arrayWithObjects:@"Guide",
                                                                              @"Items shown in red require preparation.  Touch items in the list as you buy them.",nil]];
    } else if ([SettingsManager instance].showGuides) {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects:@"Guide",
                                                                                      @"Touch items in the list as you buy them.", nil]];
    }
    
    // Sort the groceries so that groceries are in alphabetic order and
    // that all similar groceries are grouped together.
    [[GroceriesManager instance] sortGroceries];
    
}

/*****************************************************
 *
 * Inputs  : NSString - The string from a recipe that contains an ingredient
 *  
 * Purpose : Take a string of the form:
 *
 *                         1 cup butter 
 *
 *           and figure out the number (1), quantity (cup) and name (butter)
 *           of the ingredient.  This method also handles the case of compound
 *           quantities (e.g. 2 cups and 2 tablespoons butter)
 *
 * Outputs : None
 *
 *****************************************************/
-(int) buildIngredient:(NSString *)ingredientString
{
    Ingredient * ingredient, * tempIngredient1 = nil, * tempIngredient2 = nil;
    NSRange tempRange;
    NSArray * components;
    int index = 0, i=1, insertIndex=0;
    
    ingredient = [[Ingredient alloc] init];
    
    // Check to see if the ingredient contains an individual item
    for (NSString * key in [individuals allKeys ]) 
    {
        tempRange = [ingredientString rangeOfString:key];
        if (tempRange.location!=NSNotFound) {
            ingredient.isIndividual = YES;
            ingredient.inContainer = YES;
            break;
        }
    }
    
    // Break the string up by spaces
    components = [ingredientString componentsSeparatedByString:@" "];
    
    // Check for compound quantity (e.g. 1 cup and 1/2 tsp grated cheese)
    if ([components count] >= 3 &&
        [[components objectAtIndex:2] isEqualToString:@"and"]) 
    {
        tempIngredient1 = [[Ingredient alloc] init];
        while ([[components objectAtIndex:3*i-1] isEqualToString:@"and"]) {
            tempIngredient2 = [[Ingredient alloc] init];
            //Find the number associated with the quantity
            index = [self findNumber:components fromIndex:index inIngredient:tempIngredient2];
            
            // Find the quantity of the ingredient
            index = [self findQuantity:components fromIndex:index inIngredient:tempIngredient2];
            
            [self scaleQuantity:tempIngredient2];
            
            tempIngredient1.number += tempIngredient2.number;
            [tempIngredient2 release];
            
            index++;
            i++;
            
        }
    } 
    
    // Find the number of the ingredient
    index = [self findNumber:components fromIndex:index inIngredient:ingredient];
    
    // Find the quantity of the ingredient
    index = [self findQuantity:components fromIndex:index inIngredient:ingredient];
    
    // Find the name of the ingredient
    [self findName:components fromIndex:index inIngredient:ingredient];
    
    // Scale the quantity, if necessary
    [self scaleQuantity:ingredient];
    
    if (tempIngredient1 != nil) {
        ingredient.number += tempIngredient1.number;
        [tempIngredient1 release];
    }
    
    // Check to see if an ingredient has already been seen
    insertIndex = [[GroceriesManager instance] compareAndAdd:ingredient];
    
    
    NSLog(@"This is the ingredient number : %5.3f", ingredient.number);
    NSLog(@"This is the ingredient quantity : %@", ingredient.quantity);
    NSLog(@"This is the ingredient name : %@?", ingredient.name);
    NSLog(@"This is the ingredient isBulk : %@", ingredient.isBulk?@"YES":@"NO");
    NSLog(@"This is the ingredient inContainer : %@", ingredient.inContainer?@"YES":@"NO");
    NSLog(@"This is the ingredient isPerishable : %@", ingredient.isPerishable?@"YES":@"NO");
    NSLog(@"This is the ingredient needsPrep : %@", ingredient.needsPrep?@"YES":@"NO");
    NSLog(@"This is the ingredient isLiquid : %@", ingredient.isLiquid?@"YES":@"NO");
    
    
    // Check to see if any ingredient needs preparation
    needsPrep |= ingredient.needsPrep;
    [ingredient release];
    
    return insertIndex;
}

/********************************************************
 *
 * Inputs  : NSString - The string from a recipe that needs to be
 *                      examined
 *
 * Purpose : Look for a few different forms of ingredients that
 *           don't fit into the normal form (e.g. 1 c butter)
 *           These would include:
 *                  strings with commas in them
 *                  blank spaces 
 *                  strings with colons in them 
 *                  "a pinch/dash of ..."
 *                  "(or) to taste" 
 *              
 * Outputs : BOOL - Whether the ingredientString represents
 *                  a special case
 *
 *********************************************************/
-(BOOL) isSpecialCase:(NSString *) ingredientString
{
    BOOL isSpecialCase = NO;
    BOOL prepFound = NO;
    NSArray * components, * components1;
    Ingredient * tempIngredient = nil;
    int andIndex = 0, insertIndex = 0, groceriesSize=0;
    NSMutableString * combinedString;
    
    // Check for comma separated expressions
    components = [ingredientString componentsSeparatedByString:@","];
    if ([components count] == 2 &&
        [[components objectAtIndex:1] rangeOfString:@"or to taste"].location != NSNotFound) 
    {
        NSLog(@"Found or to taste.");
        [self buildIngredient:[components objectAtIndex:0]];
        isSpecialCase = YES;
    }
    else if ([components count] == 2) 
    {
        components1 = [[[components objectAtIndex:1]
                        stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]]
                       componentsSeparatedByString:@" "];
        
        for (NSString * preparation in preparations) 
        {
            if ([[components1 objectAtIndex:[components1 count] -1] rangeOfString:preparation].location != NSNotFound ||
                [[components1 objectAtIndex:0] rangeOfString:preparation].location != NSNotFound) 
            {
                prepFound = YES;
                break;
            }
        }
        
        if (prepFound) {
            NSLog(@"Groceries count %d.",[[GroceriesManager instance ].groceries count]);
            groceriesSize = [[GroceriesManager instance ].groceries count];
            insertIndex = [self buildIngredient:[components objectAtIndex:0]];
            NSLog(@"insertIndex %d.",insertIndex);
            if (insertIndex == -1) {
                tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:0];
            } else if (insertIndex < groceriesSize) {
                tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:insertIndex];
            } else if (insertIndex == groceriesSize ) {
                tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:groceriesSize];
            }
            
            tempIngredient.inContainer = NO;
            isSpecialCase = YES;
        }
        
    }
    // For some reason blank spaces appear.  Remove them.
    else if ([ingredientString rangeOfString:@"nbsp"].location != NSNotFound) 
    {
        NSLog(@"Found nbsp.");
        isSpecialCase = YES;
    }
    // The recipes sometimes use colons to separate parts of
    // a recipe
    else if ([ingredientString rangeOfString:@":"].location != NSNotFound) {
        NSLog(@"Found colon.");
        isSpecialCase = YES;
    }
    // Handle "a pinch/dash of..."
    else if ([ingredientString rangeOfString:@"dash"].location != NSNotFound ||
             [ingredientString rangeOfString:@"pinch"].location != NSNotFound) {
        NSLog(@"Found pinch or dash %@.", ingredientString);
        combinedString = [[NSMutableString alloc] initWithCapacity:1];
        
        if ([ingredientString rangeOfString:@"dash"].location != NSNotFound) {
            [combinedString appendString:[ingredientString substringFromIndex:[ingredientString rangeOfString:@"dash"].location+5]];
        } else {
            [combinedString appendString:[ingredientString substringFromIndex:[ingredientString rangeOfString:@"pinch"].location+6]];
        }
        
        [combinedString insertString:@"tablespoons " atIndex:0];
        [combinedString insertString:@"1/10 " atIndex:0];
        [self buildIngredient:combinedString];
        
        [combinedString release];
        isSpecialCase = YES;
    }
    // Handle "to taste"
    else if ([ingredientString rangeOfString:@"to taste"].location != NSNotFound) {
        NSLog(@"Found to taste %@.", ingredientString);
        
        components = [ingredientString componentsSeparatedByString:@" "];
        for (int i = 0; i<[components count] - 2; i++) {
            if ([[components objectAtIndex:i] isEqualToString:@"and"]) {
                andIndex = i;
                break;
            }
        }
        
        if (andIndex != 0) {
            combinedString = [[NSMutableString alloc] initWithCapacity:1];
            for (int i = 0; i<andIndex; i++) 
            {
                [combinedString appendString:[components objectAtIndex:i]];
                if (i != andIndex - 1 ) {
                    [combinedString appendString:@" "];
                }
            }
            
            [combinedString insertString:@"tablespoons " atIndex:0];
            [combinedString insertString:@"1/10 " atIndex:0];
            [self buildIngredient:combinedString];
            
            [combinedString release];
            combinedString = [[NSMutableString alloc] initWithCapacity:1];
            for (int i = andIndex+1; i<[components count] - 2; i++) {
                [combinedString appendString:[components objectAtIndex:i]];
                if (i != [components count] -3) {
                    [combinedString appendString:@" "];
                }
            }
            
            [combinedString insertString:@"tablespoons " atIndex:0];
            [combinedString insertString:@"1/10 " atIndex:0];
            [self buildIngredient:combinedString];
            [combinedString release];
            
        } else {
            combinedString = [[NSMutableString alloc] initWithCapacity:1];
            for (int i = 0; i<[components count] - 2; i++) 
            {
                [combinedString appendString:[components objectAtIndex:i]];
                if (i != [components count] -3) {
                    [combinedString appendString:@" "];
                }
            }
            
            [combinedString insertString:@"tablespoons " atIndex:0];
            [combinedString insertString:@"1/10 " atIndex:0];
            [self buildIngredient:combinedString];
            [combinedString release];
        }
        isSpecialCase = YES;
    }
    
    return isSpecialCase;
}

/***************************************************
 *
 * Inputs  : The array of string components of an ingredient,
 *           the index within that array to start the search from,
 *           the ingredient to add the number to.
 *
 * Purpose : Find the number in an ingredient.  This number may be
 *           a whole number, it may be fraction, it may be a whole number
 *           and a fraction.  The end result is set to a floating point
 *           number 
 *
 * Outputs : int - the index in the components array beyond the number
 *
 ***************************************************/
-(int) findNumber:(NSArray *)components fromIndex:(int)start inIngredient:(Ingredient *)ingredient
{
    float num = 0.0f;
    int whole, numerator = 0, denominator = 0;
    int index = start;
    NSRange tempRange1, tempRange2;
    NSString * fraction;
    
    // Check for a hyphen in the first component
    tempRange1 = [[components objectAtIndex:index] rangeOfString:@"-"];
    
    // Check to see if the first component is a fraction
    tempRange2 = [[components objectAtIndex:index] rangeOfString:@"/"];
    
    // We found a value of the form 1-1/2
    if (tempRange1.location == 1) 
    {
        whole = [[[[components objectAtIndex:index] componentsSeparatedByString:@"-"] objectAtIndex:0] intValue];
        fraction = [[[components objectAtIndex:index] componentsSeparatedByString:@"-"] objectAtIndex:1];
        numerator = [[[fraction componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
        denominator = [[[fraction componentsSeparatedByString:@"/"] objectAtIndex:1] intValue];
        num = (float)whole + (float)numerator/(float)denominator;
        index++;
        
        
    } else {
        
        // The first component is a fraction
        if(tempRange2.location != NSNotFound) 
        {
            numerator = [[[[components objectAtIndex:index] componentsSeparatedByString:@"/"] objectAtIndex:0] intValue];
            denominator = [[[[components objectAtIndex:index] componentsSeparatedByString:@"/"] objectAtIndex:1] intValue];
            num = (float)numerator/(float)denominator;
            index++;
            
        } else {
            // Check for a whole number
            num = (float)[[components objectAtIndex:index] intValue];
            
            // This means the first component is not a number
            if (num == 0.0f)
            {
                // So don't icrement the index
            } else {
                index++;
            }
            
        }
        
    }
    
    // Set the number of the ingredient
    ingredient.number = num;        
    
    // Return the position within the components array
    // that we've gotten to at this point
    return index;
}

/***************************************************
 *
 * Inputs  : The array of string components of an ingredient,
 *           the index within that array to start the search from,
 *           the ingredient to add the quantity to.
 *
 * Purpose : Check to see if the component at components[start]
 *           has a ( in it.  If so, the quantity is all strings between
 *           ( and ) plus the string following ).  If components[start]
 *           does not have a ( in it, check to see if components[start]
 *           is one of the values listed in the quantities array.
 *
 * Outputs : None.
 *
 ***************************************************/
-(int) findQuantity:(NSArray *)components 
          fromIndex:(int)start
       inIngredient:(Ingredient *)ingredient
{
    BOOL foundQuantity = NO;
    int index = start;
    NSRange tempRange;
    NSMutableString * tempQuantity = [[NSMutableString alloc] initWithCapacity:1];
    
    // Check to see if quantity contains parentheses
    tempRange = [[components objectAtIndex:index] rangeOfString:@"("];
    
    // If we have a parenthetical quantity
    if (tempRange.location != NSNotFound) {
        
        // Save that part of the ingredient string
        [tempQuantity appendString:[components objectAtIndex:index++]];
        [tempQuantity appendString:@" "];
        tempRange = [[components objectAtIndex:index] rangeOfString:@")"];
        
        // we have parentheses in the quantity
        hasParens = YES;
        
        // Save all the other parts of the quantity between ( and )
        while (tempRange.location != NSNotFound) 
        {
            [tempQuantity appendString:[components objectAtIndex:index++]];
            [tempQuantity appendString:@" "];
            tempRange = [[components objectAtIndex:index] rangeOfString:@")"];
        }
        
        // Check to see if the next substring in components is a quantity
        // If so, add it to the quantity for this ingredient.
        for (NSString * quantity in quantities) {
            if ([[components objectAtIndex:index] isEqualToString:quantity]) {
                [tempQuantity appendString:@" "];
                [tempQuantity appendString:[components objectAtIndex:index]];
                index++;
                break;
            }
        }
    }
    // Otherwise find if the ingredient has a quantity that we've identified
    else {
        
        for (NSString * quantity in quantities) 
        {
            tempRange = [[components objectAtIndex:index] rangeOfString:quantity];
            if (tempRange.location != NSNotFound) {
                [tempQuantity appendString:[components objectAtIndex:index]];
                foundQuantity = YES;
                break;
            }
        }
        if (foundQuantity) 
        {
            index++;
        }
        
    }
    
    // Set the quantity for the ingredient
    ingredient.quantity = tempQuantity;
    
    // Release tempQuantity
    [tempQuantity release];
    
    // Return the position within the components array
    // that we've gotten to at this point
    return index;
    
}

/***************************************************
 *
 * Inputs  : The array of string components of an ingredient,
 *           the index within that array to start the search from,
 *           the ingredient to add the name to.
 *
 * Purpose : The name of the ingredient will be all the remaining
 *           items in the component array starting from "start".
 *           
 * Outputs : None
 *
 ***************************************************/
-(void) findName: (NSArray *) components 
       fromIndex: (int) start
    inIngredient: (Ingredient *) ingredient
{
    NSRange tempRange;
    // Set the start position to do the search
    int index = start;
    
    // Create a mutable string to hold the name 
    NSMutableString * tempName = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
    
    // Add up all the rest of the components to form the name of the ingredient
    for (int i = index; i<[components count]; i++) 
    {
        [tempName appendString:[components objectAtIndex:i]];
        [tempName appendString:@" "];
    }
    
    // Remove sifted
    tempRange = [tempName rangeOfString:@"sifted"];
    if (tempRange.location != NSNotFound) {
        [tempName deleteCharactersInRange:tempRange];
    }
    
    // Remove packed
    tempRange = [tempName rangeOfString:@"packed"];
    if (tempRange.location != NSNotFound) {
        [tempName deleteCharactersInRange:tempRange];
    }
    
    // Remove for dusting
    tempRange = [tempName rangeOfString:@"for .*?ing" options:NSRegularExpressionSearch];
    if (tempRange.location != NSNotFound) {
        [tempName deleteCharactersInRange:tempRange];
    }
    
    // Assign the name of ingredient
    ingredient.name = tempName;
    
}

/****************************************************************
 *
 * Inputs  : An ingredient from the Menu view.
 *
 * Purpose : Scale the quantity of an ingredient from cups and 
 *           teaspoons to tablespoons.  
 *
 *           If an ingredient has such a quantity, then it might 
 *           need preparation and the user needs to be made aware.  
 *
 *           If an ingredient has such a quantity and doesn't need 
 *           preparation, then it is in a container and the user 
 *           should be queried about the size of the container.
 *
 *           If an ingredient has such a quantity and is perishable,
 *           it will not be stored in the pantry.
 *
 *           If an ingredient has such a quantity, need to check if
 *           it is a liquid.  The container query to the user is 
 *           dependent upon this.
 *
 * Outputs : None
 *
 ****************************************************************/
-(void) scaleQuantity: (Ingredient *) ingredient
{
    BOOL found_quantity = NO, found_prep = NO;
    NSRange tempRange;
    
    // We don't need to scale ingredients that are individuals
    if (ingredient.isIndividual) {
        return;
    }
    
    // Scale gallon down to tablespoons
    tempRange = [ingredient.quantity rangeOfString:@"gallon"];
    if (tempRange.location != NSNotFound) 
    {
        ingredient.number *= TBSP_PER_GALLON;
        found_quantity = YES;
    }
    
    // Scale quart down to tablespoons
    tempRange = [ingredient.quantity rangeOfString:@"quart"];
    if (tempRange.location != NSNotFound) 
    {
        ingredient.number *= TBSP_PER_QUART;
        found_quantity = YES;
    }
    
    // Scale pint down to tablespoons
    tempRange = [ingredient.quantity rangeOfString:@"pint"];
    if (tempRange.location != NSNotFound) 
    {
        ingredient.number *= TBSP_PER_PINT;
        found_quantity = YES;
    }
    
    // Scale cups down to tablespoons
    tempRange = [ingredient.quantity rangeOfString:@"cup"];
    if (tempRange.location != NSNotFound) 
    {
        ingredient.number *= TBSP_PER_CUP;
        found_quantity = YES;
    }
    
    // Scale teaspoons up to tablespoons          
    tempRange = [ingredient.quantity rangeOfString:@"teaspoon"];
    if(!found_quantity && tempRange.location != NSNotFound)             
    {
        ingredient.number *= TBSP_PER_TSP;
        found_quantity = YES;
    }
    
    // If an ingredient has a cup or *spoon quantity, it might
    // be in a bottle;
    tempRange = [ingredient.quantity rangeOfString:@"tablespoon"];
    if(found_quantity  || tempRange.location != NSNotFound)       
    {
        ingredient.quantity = @"tablespoons";
        // If it has chop, slice etc. in it, it isn't sold in a bottle
        for (NSString * preparation in preparations) 
        {
            //NSLog(@"A prep: %@", preparation);
            tempRange = [ingredient.name rangeOfString:preparation];
            if (tempRange.location != NSNotFound) 
            {
                // If the ingredient doesn't have parentheses somewhere
                // then it does need preparation
                if (!hasParens) 
                {
                    //NSLog(@"We need prep for %@.", ingredient.name);
                    ingredient.needsPrep = YES;
                    ingredient.color = [UIColor redColor];
                }
                found_prep = YES;
                break;
            }
        }
        
        // Check for crushed red pepper
        tempRange = [ingredient.name rangeOfString:@"crushed red pepper"];
        if (tempRange.location != NSNotFound) {
            ingredient.inContainer = YES;
        }
        // If the ingredient doesn't need preparation
        // 
        else if (!found_prep) 
        {
            // Then it must be in a container
            ingredient.inContainer = YES;
            
            for (NSString * key in [bulk allKeys]) 
            {
                tempRange = [ingredient.name rangeOfString:key];
                if (tempRange.location != NSNotFound) 
                {
                    ingredient.isBulk = YES;
                    break;
                }
            }
            
            if (!ingredient.isBulk) 
            {
                // Items that aren't bulk and are more than 1/4 c
                // should not be in a container.
                if (ingredient.number >= 4.0) {
                    ingredient.inContainer = NO;
                }
                
                // Check to see if item is liquid
                for (NSString * liquid in liquids) 
                {
                    tempRange = [ingredient.name rangeOfString:liquid];
                    if (tempRange.location != NSNotFound) 
                    {
                        ingredient.isLiquid = YES;
                        break;
                    }
                }
                
                // Check to see if item is a liquid
                if (!ingredient.isLiquid) 
                {
                    
                    for (NSString * perishable in perishables) 
                    {
                        tempRange = [ingredient.name rangeOfString:perishable];
                        if (tempRange.location != NSNotFound) 
                        {
                            ingredient.isPerishable = YES;
                            break;
                        }
                    }
                    
                    // Mustard seed and dry mustard
                    tempRange = [ingredient.name rangeOfString:@"mustard seed"];
                    if (tempRange.location != NSNotFound) 
                    {
                        ingredient.isPerishable = NO;
                    }
                    tempRange = [ingredient.name rangeOfString:@"dry mustard"];
                    if (tempRange.location != NSNotFound) 
                    {
                        ingredient.isPerishable = NO;
                    }                    
                }
            }
        }
    }
}

/*********
 *
 * XML Parsing functions
 *
 *********/


/*************************************************************
 *
 * Inputs  : The name of the element that we are entering.
 *
 * Purpose : Figure out what the name of the element is.
 *           If this element is named recipe, we need to create a recipe object.
 *
 * Outputs : None
 *
 *************************************************************/
-(void) parser:(NSXMLParser *) parser
        didStartElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName
        attributes:(NSDictionary *)attributeDict
{

    NSNumber * tempNumber = [elements objectForKey:elementName];
    Recipe * tempRecipe;
    
    elementType = [tempNumber intValue];
    
    if([elementName isEqualToString:@"recipe"])
    {
        tempRecipe  = [[Recipe alloc] init];
        [self.recipeList addObject: tempRecipe];
        [tempRecipe release];
    }
    
}

/*************************************************************
 *
 * Inputs  : The name of the element that we are leaving.
 *
 * Purpose : If the element name is not recipe, we don't have 
 *           anything to do.  Otherwise we decide whether or 
 *           not to add the recipe we've just created.
 *
 * Outputs : None
 *
 *************************************************************/
-(void) parser:(NSXMLParser *) parser
        didEndElement:(NSString *)elementName
        namespaceURI:(NSString *)namespaceURI
        qualifiedName:(NSString *)qName
{
    Recipe * rcp, * tempRecipe;
    float tmpCurrent, tmpTotal;
    
    if ([elementName isEqualToString:@"count"]) {
        elementType = EMPTY;
    }
    
    if (![elementName isEqualToString:@"recipe"]) {
        return;
    }
    
    NSLog(@"recipes size %d", [self.recipeList count]);
    rcp = (Recipe *)[self.recipeList lastObject];

    
    if ([[NSThread currentThread] isCancelled])
    {
        [NSThread exit];
    }

    // Search to see if the recipe is a repeat.
    for (int i = 0; i < [self.recipeList count]-1; i++)
    {
        tempRecipe = [self.recipeList objectAtIndex:i];
        
        if ([tempRecipe.recipeTitle isEqualToString:rcp.recipeTitle])
        {
            //NSLog(@"Found Repeat recipe, %@", [tempDict1 objectForKey:@"title"]);
            foundRepeat = YES;
            break;
        }
    }
    
    // If we did find a repeat recipe, increment the current
    // recipe counter and reset the foundRepeat indicator and
    // continue with the search.
    if (foundRepeat) {
        currentRecipe++;
        foundRepeat = NO;
    } else {
     
        // Make sure we don't add recipes while another part
        // of the application is using the recipeList
        while (self.threadWait) {
            [NSThread sleepForTimeInterval:.1f];
        }
        
        // Remove any recipe whose title is blank.
        if ([rcp.recipeTitle isEqualToString:@""])
        {
            [self.recipeList removeLastObject];
            
        }
        
        ++currentRecipe;
        tmpCurrent = (float)currentRecipe;
        tmpTotal = (float)totalRecipes;
        
        progress = tmpCurrent/tmpTotal*.14286+self.generateStep*.14286;
        // Update the progress bar to indicate how far along we are in the
        // search.
        [menuViewController performSelectorOnMainThread:@selector(updateProgressBar:)
                                             withObject:[NSString stringWithFormat:@"%f",progress]
                                          waitUntilDone:NO];
        
        // Show those tableCells that have been collected
        // so far.  Do this only once for a value of floatPercentage
        // such that count*.1 >= progress <= (count+1)*.1
        if (progress > .1*count &&
            progress < .1*(count+1) &&
            firstTime)
        {
            if (!menuViewController.tableView.hidden)
            {
                [menuViewController.tableView performSelectorOnMainThread:@selector(reloadData)
                                                               withObject:nil
                                                            waitUntilDone:YES];
            }
            firstTime = NO;
        }
        
        // Check for when progress rises above (count+1)*.1
        // from the above check
        if (progress > .1*(count+1)) {
            firstTime = YES;
            count++;
        }

    }
    
    elementType = -1;

}

/*************************************************************
 *
 * At the moment, it's not clear what to do with this method.
 *
 *************************************************************/
-(void) parser:(NSXMLParser *) parser
        parseErrorOccurred:(NSError *)parseError
{
    NSLog(@"Encountered a parser error: %@", parseError);
}

/*************************************************************
 *
 * Inputs  : The data from a CDATA section.
 *
 * Purpose : Most of the contents of a recipe are wrapped in CDATA
 *           sections.  Properly parse those contents.
 *
 * Outputs : None
 *
 *************************************************************/
-(void) parser:(NSXMLParser *) parser
        foundCDATA:(NSData *)CDATABlock
{

    NSString * encodedString, * decodedString, * tempString;
    NSData * decodedData, * decodedData1;
    NSLog(@"recipes size %d", [self.recipeList count]);
    Recipe * rcp = [self.recipeList lastObject];
    
    switch (elementType)
    {
        case RECIPE_TITLE:
            tempString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
            rcp.recipeTitle = tempString;
            [tempString release];
            break;
        case RECIPE_URL:
            tempString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
            rcp.recipeURL = [ NSURL URLWithString:tempString ];
            [tempString release];
            break;
        case RECIPE_INGREDIENT:
            tempString = [[NSString alloc] initWithData:CDATABlock encoding:NSUTF8StringEncoding];
            [rcp.recipeIngredients addObject: tempString];
            [tempString release];
            break;
        //  In this case, we have data that is both gzip'ed and base64 encoded.
        case RECIPE_PAGE:
            // Decode for base64 encoding
            encodedString = [[NSString alloc] initWithData: CDATABlock encoding:NSASCIIStringEncoding];
            decodedData = [[NSData alloc] initWithBase64EncodedString:encodedString options:NSDataBase64DecodingIgnoreUnknownCharacters];
            [encodedString release];
            
            // Gunzip the string.
            decodedData1 = [decodedData gunzippedData];
            [decodedData release];
            decodedString = [[NSString alloc] initWithData:decodedData1 encoding:NSASCIIStringEncoding];
            rcp.recipePage = decodedString;
            [decodedString release];
            break;
        default:
            // We're only interested in the elements listed above.  This is some sort of error.
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                            withObject:[NSArray arrayWithObjects:@"Error", @"Error parsing XML CDATA section.",nil]
                                         waitUntilDone:NO];

            break;
    }
    
}

/*************************************************************
 *
 * Inputs  : The character data (value) of an XML element.
 *
 * Purpose : The only value we are interested in is that of the
 *           count element.
 *
 * Outputs : None
 *
 *************************************************************/
-(void) parser:(NSXMLParser *)parser foundCharacters:(NSString *)string
{
    
    if (elementType == RECIPE_COUNT)
    {
        totalRecipes = [string intValue];
    }
    
    // The value returned by the "count" element may contain an error from the server.
    switch (totalRecipes) {
        case SERVER_GENERAL_ERROR:
            
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                                 withObject:[NSArray arrayWithObjects:@"Error", @"Recipe server returned a general error.",nil]
                                              waitUntilDone:NO];
            serverError = YES;
            break;
        case SERVER_COLLECT_ERROR:
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                            withObject:[NSArray arrayWithObjects:@"Error",
                                                        @"Recipe server experienced an error finding recipes.",nil]
                                         waitUntilDone:NO];
            serverError = YES;
            break;

        case SERVER_INIT_ERROR:
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                            withObject:[NSArray arrayWithObjects:@"Error", @"Recipe server failed to initialize.",nil]
                                         waitUntilDone:NO];
            serverError = YES;
            break;
        case INVALID_PARAMETERS_ERROR:
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                            withObject:[NSArray arrayWithObjects:@"Error", @"Invalid settings.",nil]
                                         waitUntilDone:NO];
            serverError = YES;
            break;
        //  We got a number of recipes 
        default:
            serverError = NO;
            break;
    }
    
}


/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : If we've done everything correctly, this should
 *            set the retain count for the instance variables to
 *            0 so the runtime environment can reclaim memory.
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) dealloc
{    
    
    [[NSUserDefaults standardUserDefaults] setInteger:self.generateStep forKey:@"generateStep"];
    
    if (quantities) {
        [quantities release];
    }
    
    if (preparations) {
        [preparations release];
    }
    
    if (perishables) {
        [perishables release];
    }
    
    if (liquids) {
        [liquids release];
    }

    if (recipeList) {
        [recipeList release];
    }
    
    if (elements)
    {
        [elements release];
    }
    
    if (menuViewController) {
        [menuViewController release];
    }
    
    [super dealloc];
}

@end
