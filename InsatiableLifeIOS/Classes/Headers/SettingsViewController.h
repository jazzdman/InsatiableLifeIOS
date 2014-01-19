//
//  SettingsViewController.h
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "OptionsViewController.h"


@class FullPlateAppDelegate;
/**************************************************************
 *
 * The purpose of this class is to act as the Controller part
 * of the Settings display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Specifically this object collects and saves user preferences
 * aboout max prep time for a recipe, total servings for the meal,
 * calories per serving for the meal and the day of the week the
 * user does his/her shopping.
 *
 *****************************************************************/
@interface SettingsViewController : UITableViewController <UITextFieldDelegate>
{
	// Allows the user to define the max prep time for a meal
    UITextField * prepTimeField;
    
    // Allows the user to define the number of servings for a meal
    UITextField * servingsField;
    
    // Allows the user to define the max number of calories for a meal
    UITextField * caloriesField;
    
    // Allows the user to decide whether they want to see some of the
    // messages displayed by the application.
    UISwitch * guidesSwitch;
    
}

// Method called to setup this controller class
-(void) controllerUp;

// Method called to bring down this controller class
-(void) controllerDown;

// Allows the view to be reconstituted when application
// returns from the background.
-(void) viewDidAppearPartTwo;

// The destructor for this class
-(void) dealloc;

@end
