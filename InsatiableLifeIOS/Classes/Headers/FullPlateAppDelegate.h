//
//  FullPlateAppDelegate.h
//  FullPlate
//
//  Created by Jason Todd Mazzotta on 4/15/10.
//  Copyright Full Plate Productions 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "SettingsManager.h"
#import "AllRecipesProxy.h"
#import "GroceriesManager.h"
#import "PantryManager.h"

@interface FullPlateAppDelegate : NSObject <UIApplicationDelegate, 
                                            UITabBarControllerDelegate,
                                            UIPickerViewDelegate,
                                            UIPickerViewDataSource>
{
    // The main window for the application
    UIWindow * window;
    
    // The controller for the UITabBar in this application
    UITabBarController * tabBarController;
    
    // We can only show one UIAlertView at a time.  This allows
    // us to control that UIAlertView if the application resignsActive
    UIAlertView * alert;
    
    // We can only show one UIPickerView at a time.  This allows us
    // to control that UIPickerView if the application resignsActive
    UIPickerView * pickerView;
    
    // We need this point as a reference to those items displayed in the 
    // UIPickerView
    NSArray * displayItems;
    
    // What is the index in the displayItems array that the user selected
    int selectedPick;
    
    // What is the tab that was visible when the application entered the background
    int selectedTabIndex;
    
    // Lets the application distinguish between when it first starts up and 
    // when it is being brought back from the background
    BOOL didEnterBackground;
    
    // This is used to make sure the right background task is killed
    // when the background task has run out of time.
    UIBackgroundTaskIdentifier bgTask;

    // Did the alertView get hidden?
    BOOL alertViewHidden;

    // Did the pickerView get hidden?
    BOOL pickerViewHidden;
    
    
    // Images to display when selecting a spice bottle size
    UIImage * smallJar;
    UIImage * mediumJar;
    UIImage * largeJar;
}

// Properties for member variables.
@property (nonatomic, retain) IBOutlet UIWindow *window;
@property (nonatomic, retain) IBOutlet UITabBarController *tabBarController;
@property (nonatomic, retain) IBOutlet UIPickerView *pickerView;
@property (assign) NSArray * displayItems;
@property (assign) int selectedPick;

// The constructor for this class
-(id) init;

// Allows various parts of the application to pop up a UIAlertView 
// when necessary.
-(void) showAlertWithTitleandMessage:(NSArray *)strings;


@end
