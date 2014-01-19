//
//  OptionsViewController.h
//  FullPlate
//
//  Created by Jason Mazzotta on 4/25/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//


#import <UIKit/UIKit.h>
#import "SettingsManager.h"


/*******************************************************
 *
 * This is a subclass of UITableViewController that allows
 * the user to select a value for a particular setting.
 *
 *******************************************************/


@interface OptionsViewController : UITableViewController 
{
    // Since we can't have a static pointer,
    // a pointer to the previously selected item.
    NSIndexPath * previousPath;
    
    // The array of options that the user can choose
    // from for a particular application setting.
    NSArray * optionsArray;
    
    // The index at which the particular set of options
    // resides in the dictionary of options
    int index;
    
    // The setting that has been selected at some time in the past
    NSString * previousSelection;
    
}


// The init method/constructor for this class
-(OptionsViewController *) initWithData:(NSArray *)data 
                                                   title:(NSString *)title
                                                   andIndex:(int)i;


// The destructor for this class
- (void) dealloc;

@end
