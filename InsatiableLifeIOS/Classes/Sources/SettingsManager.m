//
//  SettingsManager.m
//  FullPlate
//
//  Created by Jason Mazzotta on 5/2/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "SettingsManager.h"
#import "FullPlateAppDelegate.h"

static SettingsManager * singleton = nil;

@implementation SettingsManager

// Create setters and getters for the properties
@synthesize shoppingDay;
@synthesize showGuides;
@synthesize prepTime;
@synthesize servings;
@synthesize caloriesPerServing;
@synthesize maxPrepTime;
@synthesize minServings;
@synthesize minCaloriesPerServing;

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method allows the program to access the same instance
 *            of the SettingsManager from anywhere in the program.  
 *            Ultimately, this class is a Singleton because we need
 *            to be able to save the contents of this class when the 
 *            application closes.
 *
 *  Outputs : SettingsManager - static pointer to a SettingsManager object
 *
 ******************************************************************/
+(SettingsManager *)instance
{	
    @synchronized(self) 
    {    
        if (singleton == nil) {
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
 *            initializes the member variables from the NSUserDefaults
 *            store.
 *
 *  Outputs : SettingsManager - a pointer to a SettingsManager object
 *
 ******************************************************************/
-(SettingsManager *) init
{
    NSString * finalPath;
    
	self=[super init];
    
	if (self) 
	{
		// Read in the list of settings and their options from a plist
        finalPath = [[NSBundle mainBundle] pathForResource:@"Settings" ofType:@"plist"];
		settingsDict = [[NSDictionary dictionaryWithContentsOfFile:finalPath] retain];
		
		// Get the keys from the settings dictionary, in alphabetic order
		settingsKeysArray = [[self allKeysSortedAlpha:settingsDict] retain];
        
		// Get a pointer to the User Defaults database
		defaults = [[ NSUserDefaults standardUserDefaults ] retain ];
		
		// Get values for the settings from the User Defaults object
        self.caloriesPerServing = [ defaults stringForKey:[settingsKeysArray objectAtIndex: 0 ]];
        self.prepTime = [ defaults stringForKey:[settingsKeysArray objectAtIndex: 1 ]];
		self.servings = [ defaults stringForKey:[settingsKeysArray objectAtIndex: 2 ]];
		self.shoppingDay = [ defaults integerForKey:[settingsKeysArray objectAtIndex: 3 ]];
        self.showGuides = [ defaults boolForKey:[settingsKeysArray objectAtIndex: 4 ]];		
        calendar = [[NSCalendar currentCalendar] retain];
        startTime = [[NSDate date ] timeIntervalSince1970];
        repeat = [defaults integerForKey:@"repeat"];
        
        elements = [NSDictionary dictionaryWithObjects:[NSArray arrayWithObjects:
                                                        [NSNumber numberWithInt:SETTINGS_CALORIES],
                                                        [NSNumber numberWithInt:SETTINGS_SERVINGS],
                                                        [NSNumber numberWithInt:SETTINGS_PREPTIME], nil]
                                               forKeys: [NSArray arrayWithObjects:@"calories", @"servings", @"preptime",nil]];
        [elements retain];
        
        // Pointers to the request objects we will send to allrecipes.com
        NSURL * fullPlateServer = [NSURL URLWithString: @"http://localhost:8084/InsatiableLifeCloudComponent/settings"];
        
        NSURLResponse * response;
        NSError * error;
        NSString * tmpString;
        
        NSMutableURLRequest * tempReq = [NSMutableURLRequest requestWithURL:fullPlateServer
                                                                cachePolicy: NSURLRequestReloadIgnoringCacheData
                                                            timeoutInterval:60.0];
        
        NSData * tempDat = [NSURLConnection sendSynchronousRequest: tempReq
                                                 returningResponse: &response
                                                             error:&error];
        
        // Create an XML parser, which makes a request to the server for recipes
        NSXMLParser * xmlParser = [[[NSXMLParser alloc] initWithData:tempDat] autorelease];
        tmpString = [[NSString alloc] initWithData:tempDat encoding:NSUTF8StringEncoding];
        [tmpString release];
        
        // Set this class as the XML parser delegate
        [xmlParser setDelegate:self];
        
        // Start processing the XML document that is received.
        [xmlParser parse];


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
/**************************************************************/

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : Save all the values in the member variables into 
 *            the NSUserDefaults store.
 *
 *  Outputs : BOOL - whether this method suceeded.
 *
 ******************************************************************/
-(void) serializeSettings
{
    
    // Save each of the member variables 
    [ defaults setObject:self.caloriesPerServing forKey:[settingsKeysArray objectAtIndex: 0 ]];
	[ defaults setObject:self.prepTime forKey:[settingsKeysArray objectAtIndex: 1 ]];
	[ defaults setObject:self.servings forKey:[settingsKeysArray objectAtIndex: 2 ]];
	[ defaults setInteger: self.shoppingDay forKey:[settingsKeysArray objectAtIndex: 3 ]];
    [ defaults setBool: self.showGuides forKey:[settingsKeysArray objectAtIndex: 4 ]];
    
}

/******************************************************************
 *
 *  Inputs : id - an object to save
 *           index - the position in the array of keys.  
 *
 *  Purpose : The key pointed to by index is where in the 
 *                dictionary the object should be saved.  
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) saveSetting:(id)obj atIndex:(int)i
{
    NSArray * days;
    
    switch (i) 
    {
        // Save calories per serving
        case 0:
            self.caloriesPerServing = obj;
            [ defaults setObject:obj forKey:[settingsKeysArray objectAtIndex: i ]];
            break;
        // Save the preparation time.
        case 1:
            self.prepTime = obj;
            [ defaults setObject:obj forKey:[settingsKeysArray objectAtIndex: i ]];
            break;
        // Save number of servings 
        case 2:
            self.servings = obj;
            [ defaults setObject:obj forKey:[settingsKeysArray objectAtIndex: i ]];
            break;
        // Save shopping day
        case 3:
            days = [settingsDict objectForKey:@"Shopping Day"];
            for (int j = 0; j< [days count]; j++) 
            {
                if ([obj isEqualToString: [days objectAtIndex:j]]) 
                {
                    self.shoppingDay = j;
                    [ defaults setInteger:j forKey:[settingsKeysArray objectAtIndex: i ]];
                    break;
                }
            }
            break;
        // Save whether or not to show the guide messages
        case 4:
            self.showGuides = [obj boolValue];
            [ defaults setBool:[obj boolValue] forKey:[settingsKeysArray objectAtIndex: i ]];
            break;
        default:
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Error",
                                                                                                                @"An unexpected error has occurred.  Please exit and restart FullPlate (saveSetting:atIndex:)", nil]];
            break;
    }
}

/******************************************************************
 *
 *  Inputs  :  index - the position in the array of keys.  
 *
 *  Purpose :  The key pointed to by index is where in the 
 *             dictionary the object should be found and
 *             returned.
 *
 *  Outputs : id - the object to be returned to the user
 *
 ******************************************************************/
-(id) getSettingAtIndex:(int)i
{
	id obj = nil;	
	switch (i) 
	{
        case 0:
            obj = self.caloriesPerServing;
			break;
		case 1:
            obj = self.prepTime;
			break;
		case 2:
            obj = self.servings;
			break;
		case 3:
            switch (self.shoppingDay) {
                case 0:
                    obj = @"Sunday";
                    break;
                case 1:
                    obj = @"Monday";
                    break;
                case 2:
                    obj = @"Tuesday";
                    break;
                case 3:
                    obj = @"Wednesday";
                    break;
                case 4:
                    obj = @"Thursday";
                    break;
                case 5:
                    obj = @"Friday";
                    break;
                case 6:
                    obj = @"Saturday";
                    break;
                default:
                    [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                                            [NSArray arrayWithObjects:@"Error",
                                                                                             @"An unexpected error has occurred.  Please exit and restart FullPlate (getSettingAtIndex,shoppingDay)", nil]];
                    break;
            }
            break;
        case 4:
            obj = [NSString stringWithFormat:@"%d", self.showGuides];
            break;
        default:
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                                    [NSArray arrayWithObjects: @"Error",
                                                                                    @"An unexpected error has occurred.  Please exit and restart FullPlate (getSettingAtIndex)", nil]];
			break;
	}
	
	return obj;
													   
}

/*****************************************************
 *
 * Inputs  : None
 *
 * Purpose : Get the settings dictionary
 *
 * Outputs : NSDictionary - the settings dictionary
 *
 *****************************************************/
-(NSDictionary *)getSettingsDict
{
	return settingsDict;
}

/*****************************************************
 *
 * Inputs  : None
 *
 * Purpose : Get the array of keys for the settings dictionary
 *
 * Outputs : NSArray - the array of sorted keys
 *
 *****************************************************/
-(NSArray *)getSettingsKeys
{
	return settingsKeysArray;
}

/*****************************************************
 *
 * Inputs  : None
 *
 * Purpose : Determine if the current day is the shopping day.  Only returns true
 *           the very first time current day == shopping day.
 *
 * Outputs : BOOL - is it time to shop again
 *
 *****************************************************/
-(BOOL) timeToShop
{
    NSDateComponents * components = [calendar components:NSWeekdayCalendarUnit fromDate:[NSDate date]];
    int currentDay = [components weekday] - 1;
    BOOL result;
    float currentTime = [[NSDate date] timeIntervalSince1970];
    
    // Allow for the idea that people may only ever open 
    // this app on their shopping day.
    if (currentTime - startTime > SECONDS_IN_SIX_DAYS) {
        repeat = 0;
        startTime = currentTime;
    }
    if (shoppingDay != currentDay)
    {
        repeat = 0;
    } else {
        repeat++;
    }
    
    result = (shoppingDay == currentDay) && (repeat == 1);
    
    [defaults setInteger:repeat forKey:@"repeat"];
    
    return result;
}

/*****************************************************
 *
 * Inputs  : NSDictionary - the dictionary whose keys we
 *                          want to sort
 *
 * Purpose : Sort the keys for the settings dictionary into
 *           alphabetical order.
 *
 * Outputs : NSArray - the array of sorted keys
 *
 *****************************************************/
-(NSArray *) allKeysSortedAlpha:(NSDictionary *)dict
{
	NSString * firstKey, * secondKey;
    BOOL swapped = YES;
    int j = 0;
	// Create an array for the sorted keys
	NSMutableArray * sortedKeys = [[[NSMutableArray alloc] initWithCapacity: [[ dict allKeys] count]] autorelease];
    // Get the keys from the dictionary
	[sortedKeys addObjectsFromArray: [ dict allKeys]];
    
    // Clean up retainCounts
    for (id key in [dict allKeys]) {
        [key release];
    }
    
	
    // Do a simple bubble sort
    while (swapped) 
    {
        swapped = false;
        j++;
        
        for (int i = 0 ; i< [sortedKeys count]-j; i++) 
        {
            firstKey = [sortedKeys objectAtIndex:i];
            secondKey = [sortedKeys objectAtIndex:i+1];
            
            if ([secondKey compare:firstKey] == NSOrderedAscending) {
                [sortedKeys exchangeObjectAtIndex:i withObjectAtIndex:i+1];
                swapped = true;
            }
        }
    }
    
	return sortedKeys;
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
    
    elementType = [tempNumber intValue];

}

/*************************************************************
 *
 * Inputs  : The name of the element that we are entering.
 *
 * Purpose : Make sure we don't save carriage returns
 *
 * Outputs : None
 *
 *************************************************************/
-(void) parser:(NSXMLParser *) parser
didEndElement:(NSString *)elementName
  namespaceURI:(NSString *)namespaceURI
 qualifiedName:(NSString *)qName
{

    elementType = SETTINGS_END;
    
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

    // The value returned by the "count" element may contain an error from the server.
    switch (elementType) {
        case SETTINGS_END:
            break;
        case SETTINGS_PREPTIME:
            self.maxPrepTime = string;
            break;
        case SETTINGS_SERVINGS:
            self.minServings = string;
            break;
        case SETTINGS_CALORIES:
            self.minCaloriesPerServing = string;
            break;
        default:
            // We're only interested in the elements listed above.  This is some sort of error.
            [fpAppDelegate performSelectorOnMainThread:@selector(showAlertWithTitleandMessage)
                                            withObject:[NSArray arrayWithObjects:@"Error", @"Error parsing settings from server.",nil]
                                         waitUntilDone:NO];
            break;
    }
    
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
-(void)dealloc
{
	   
    if (settingsDict) {
        [settingsDict release];
    }
	
    if (settingsKeysArray) {
        [settingsKeysArray release];
    }
	
    if (defaults) {
        [defaults release];
    }
	
    if (prepTime) {
        [prepTime release];
    }
	
    if (servings) {
        [servings release];
    }
	
    if (caloriesPerServing) {
        [caloriesPerServing release];
    }
    
    if (calendar) {
        [calendar release];
    }
    
    [super dealloc];

    
}

@end
