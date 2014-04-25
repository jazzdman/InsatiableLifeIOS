//
//  PantryViewController.h
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Ingredient.h"
#import "ControllerProtocol.h"

@class FullPlateAppDelegate;
@class PantryManager;
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
 * they can decide to rearrange the order of the recipes. 
 *
 *************************************************************/
@interface PantryViewController : UITableViewController <ControllerProtocol>
{
    BOOL didModifyView;
}

// Method called to setup this controller class
-(void) controllerUp;

// Method called to bring down this controller class
-(void) controllerDown;

// Allows the view to be reconstituted when application
// returns from the background.
-(void) viewDidAppearPartTwo;

@end
