//
//  SettingsManager.h
//  FullPlate
//
//  Created by Jason Mazzotta on 5/2/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>

@class FullPlateAppDelegate;

#define SECONDS_IN_SIX_DAYS 518400.0f

#define SETTINGS_END -1
#define SETTINGS_PREPTIME 0
#define SETTINGS_SERVINGS 1
#define SETTINGS_CALORIES 2
#define SETTINGS_SERVER_ERROR -5


/**********************************************************
 *
 * A singleton class to hold user settings and allow the rest
 * of the application to access those settings.
 *
 **********************************************************/
@interface SettingsManager : NSObject <NSXMLParserDelegate>
{
	// The dictionary of values that hold user settings.
	NSDictionary * settingsDict;
	// The names of the actual user settings.
	NSArray * settingsKeysArray;
	// User default storage object provided by Cocoa.
	NSUserDefaults * defaults;
    // Which day the user goes shopping
	int shoppingDay;
	// How much time each recipe should take to prepare
	NSString * prepTime;
    //
	NSString * maxPrepTime;
	// The number of servings that each meal should provide.
	NSString * servings;
    //
	NSString * minServings;
    // The number of calories per serving
    NSString * caloriesPerServing;
    //
    NSString * maxCaloriesPerServing;
    // Whether to show the guiding messages
    BOOL showGuides;
    // The calender used to determine timeToShop
    NSCalendar * calendar;
    // The time the settingsManager was initiated
    // Used to determine when a week has passed for
    // timeToShop calculation
    float startTime;
    // A counter to enable timeToShop to return true only
    // once on shoppingDay
    int repeat;
    
    int elementType;
    
    NSDictionary * elements;
    
    FullPlateAppDelegate * fpAppDelegate;
}

// These properties allow us to more easily access
// the member variables outside this class.
@property int shoppingDay;
@property BOOL showGuides;
@property (retain) NSString * prepTime;
@property (retain) NSString * servings;
@property (retain) NSString * caloriesPerServing;
@property (retain) NSString * maxPrepTime;
@property (retain) NSString * minServings;
@property (retain) NSString * minCaloriesPerServing;


// The singleton factory method
+(SettingsManager *)instance;

// The specific init method for this class
-(id)init;

// The method used to serialize user settings
-(void) serializeSettings;

// The method used to save a particular setting
-(void) saveSetting:(id)obj atIndex:(int)i;

// The method used to save a particular setting
-(id) getSettingAtIndex:(int)i;

// Return the dictionary of pre-defined user settings
-(NSDictionary *) getSettingsDict;

// The keys for the dictionary
-(NSArray *) getSettingsKeys;

// Tells the application if the menu should be recreated
-(BOOL) timeToShop;

// Sort the keys in the settings dict in alphabetical order
-(NSArray *) allKeysSortedAlpha:(NSDictionary *)dict;

// Clear up memory
-(void)dealloc;


@end
