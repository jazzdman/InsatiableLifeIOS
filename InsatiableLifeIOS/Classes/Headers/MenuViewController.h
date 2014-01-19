//
//  MenuViewController.h
//  FullPlate
//
//  Created by Jason Todd Mazzotta on 4/15/10.
//  Copyright Full Plate Productions 2010. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <SystemConfiguration/SystemConfiguration.h>
#import <CoreFoundation/CoreFoundation.h>
#import "SettingsManager.h"
#import "AllRecipesProxy.h"
#import "Recipe.h"


// This enum is used to determine if a network connection is
// available.
typedef enum {
	NotReachable = 0,
	ReachableViaWiFi,
	ReachableViaWWAN
} NetworkStatus;

// The application is attempting to find recipes
#define FINDING_RECIPES 0

// The application has found recipes and the user is 
// selecting a subset for the week
#define SELECT_RECIPES 1

// The user has selected seven recipes and is now either
// rearranging them or moving on to the groceries view
#define MENU_SET 2

@class AllRecipesManager;
@class FullPlateAppDelegate;

/************************************************************
 *
 * The purpose of this class is to act as the Controller part
 * of the Menu display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Specifically this object populates a table of recipes.  
 * This population occurs in three steps.  First, a list of 
 * recipes is created that conforms to the minutes of prep time 
 * and calories per serving defined in the Settings panel.  The 
 * user can view each of these recipes.  So from there, they can
 * winnow the list down to seven for the week.  Once that is done, 
 * they can decide to rearrange the order of the recipes or
 * proceed to the Groceries view.
 *
 *************************************************************/

@interface MenuViewController : UITableViewController <UINavigationControllerDelegate>
{
    // The progress bar that is displayed while recipes
    // are being found.
    UIProgressView * progressBar;
    
    // The thread used to do the search for recipes
    NSThread * populateThread;
    
    // Frame to define the shape of the UIProgressView
    CGRect frameForProgressBar; 
    
     // Frame to define the shape of the UITableView in this view
    UIEdgeInsets insetsForTableView;
    
    // The state of the menu (one of the #defines above)
    // Ultimately the determines when the user can rearrange
    // the table.
    int menuState;
    
    // The current selection during the SELECT_RECIPES state
    int date;
    
    // The row that the user has selected to display its web page
    int pushedViewInt;
    
    // 0 is returned from integerForKey if pushedViewInt doesn't exist.
    // But, 0 is a valid value.  This value is set to true the first 
    // time a web page is selected that the app can know that the 
    // value of pushedViewInt is valid.
    BOOL pushedViewBool;
    
    // Did we pass through the controllerUp method
    // to get to viewDidAppear?
    BOOL controllerUp;
    
}

// The method we call when application becomes active since
// viewDidAppear does not get called when application returns
// from the background
-(void) viewDidAppearPartTwo;

// Method called to setup this controller class
-(void) controllerUp;

// Method called to bring down this controller class
-(void) controllerDown;

// THis method is used to display in all the recipes
// that have been found by the populate thread.
-(void) populateTable;

// The method used to update the progress bar 
// while the populate thread is running
-(void) updateProgressBar:(NSString *)percentage;

// THis is the method invoked when the user presses
// the redo button.
-(void) updateMenu;

// The method invoked when the user presses the done
// button.  This allows the user to proceed to the 
// groceries view.
-(void) enableTabBar;

// The message that is sent when the UILongPressGestureRecognizer is tripped
-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer;

// Can we get a network connection?
- (NetworkStatus) currentReachabilityStatus;

// What bits are set in the SCNetworkReachability flags?
- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags;

// Allows us to set the label for the UITableViewCell
// when we want to.
-(void) setLabel:(UITableViewCell *)cell fromRecipe:(Recipe *)recipe;

// The destructor for this class
-(void) dealloc;

@end
