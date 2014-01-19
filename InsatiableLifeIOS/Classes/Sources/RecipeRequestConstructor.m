//
//  RecipeRequestConstructor.m
//  FullPlate
//
//  Created by Jason Mazzotta on 5/16/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "RecipeRequestConstructor.h"
#import "FullPlateAppDelegate.h"

@implementation RecipeRequestConstructor

// Create the setters and getters for this property.
@synthesize request;

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method is the "constructor" for this class.  It
 *                initializes all member variables.
 *
 *  Outputs : RecipeRequestConstructor - 
 *            a pointer to a RecipeRequestConstructor object
 *
 ******************************************************************/
-(RecipeRequestConstructor *) init
{
    id tempObject;
    BOOL fileProblem = NO;
	NSError * error;
    NSString * tempString, * finalPath;
    FullPlateAppDelegate  * fpAppDelegate;
    
    self = [ super init];
    
	if (self) 
	{
        // Initialize the request 
        // Do this set of steps to the retain count on the memory
        // remains 1
        tempObject = [[NSMutableString alloc] initWithCapacity:1];
        self.request = tempObject;
        [tempObject release];
        
        // Open up the list of dishes
        finalPath = [[NSBundle mainBundle] pathForResource:@"Dishes" ofType:@"txt"];
        tempString = [NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
        fileProblem |= (tempString == nil);
        if (!fileProblem) {
            dishes = [[ tempString componentsSeparatedByString:@"\n"] retain];
        }
        
        
        [dishes retain];
        
        // Open up the list of ingredients
        finalPath = [[NSBundle mainBundle] pathForResource:@"Ingredients" ofType:@"txt"];
        tempString = [NSString stringWithContentsOfFile:finalPath encoding:NSASCIIStringEncoding error:&error];
        fileProblem |= ( tempString == nil);
        
        if (!fileProblem) 
        {
            ingredients = [[tempString componentsSeparatedByString:@"\n"] retain];
        }
        
        // Set up the UIAlertView
        if (fileProblem) 
        {
            fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
            [ fpAppDelegate showAlertWithTitleandMessage: [NSArray arrayWithObjects:@"Error", @"Unable to start Full Plate.  Please exit and restart FullPlate (RecipeRequestConstructor init)",nil]];
        }
        
	}
	
	return self;
}

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : Take the basic search string and fill in a dish
 *            and an ingredient.
 *
 *  Outputs : NSString * - the request to send to bing as a string in
 *                         the form of a URL.
 *
 ******************************************************************/
-(NSString *) getRequest
{

    NSMutableString * ingredientString = [[NSMutableString alloc] initWithCapacity:1];
    NSRange tempRange;
    NSString * searchString = @"http://www.bing.com/search?q=%i+site%3Aallrecipes.com";
       
    // Make sure the request is empty to begin with
    [request setString:@""];
    
    // Add in the basic search string
	[request appendString:searchString];
    
    srandom(time(NULL));
	
    // Create a set of search values from the array of ingredients and dishes
	[ingredientString appendString: [ingredients objectAtIndex:random()%[ingredients count]]];
    [ingredientString appendString: @"+"];
    [ingredientString appendString: [dishes objectAtIndex:random()%[dishes count]]];    
	
    //NSLog(@"This is the ingredient string %@.", ingredientString);
    
    // Put those search values into the search string
	tempRange = NSMakeRange(0, [request length]);
	[request replaceOccurrencesOfString:@"%i" 
             withString: ingredientString 
             options: NSCaseInsensitiveSearch 
             range: tempRange];
    
 	
    [ingredientString release];
    
    NSLog(@"This is the request, %@.",request);
    
    return request;

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
	[super dealloc];
    
	
    if (request) {
        [request release];
    }
    
    if (ingredients) {
        [ingredients release];
    }
    
    if (dishes) {
        [dishes release];
    }
    
}


@end
