//
//  GroceriesViewController.h
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "Recipe.h"
#import "Ingredient.h"
#import "ControllerProtocol.h"

/************************************************************
 *
 * The purpose of this class is to act as the Controller part
 * of the Groceries display for the application.  The Presentation-
 * Abstraction-Control pattern is used throughout this application.  
 * Specifically this object handles interactions with the Groceries
 * view.
 *
 *************************************************************/

@interface GroceriesViewController : UITableViewController <UIActionSheetDelegate, ControllerProtocol>
{
    
    // This array describes volumes for fluid containers
    NSArray * volumes;
    
    // This array describes weights for bulk containers
    NSArray * weights;
    
    // This array describes sizes for spice containers
    NSArray * sizes;
    
    // Allows us to carry 
    int selectedRow;
    
    // Let the user know that the Groceries view is being created
    UIActivityIndicatorView * activityIndicator;

}

// Method called to setup this controller class
-(void) controllerUp;

// Method called to bring down this controller class
-(void) controllerDown;

// Allows the view to be reconstituted when application
// returns from the background.
-(void) viewDidAppearPartTwo;

// The method used in a thread to build the UITableView
-(void) buildTable;

// The "destructor" for this class
- (void) dealloc;

@end
