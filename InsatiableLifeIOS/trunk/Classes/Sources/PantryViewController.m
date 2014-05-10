//
//  PantryViewController.m
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "PantryViewController.h"
#import "PantryManager.h"
#import "FullPlateAppDelegate.h"
#import "SettingsManager.h"


@implementation PantryViewController

#pragma mark -
#pragma mark View lifecycle

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : This method is called once the view property of
 *           the UITableViewController is loaded.  This is used
 *           as a replacement for the init method.  Set up
 *           all the instance variables.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)viewDidLoad 
{
    [super viewDidLoad];
    [self controllerUp];
    
}

/*******************************************************
 *
 * Inputs  : None
 *
 * Purpose : Initialize member variables and recover 
 *           anything in the database that was saved
 *           in controllerDown.
 *
 * Outputs : None
 *
 *******************************************************/
-(void) controllerUp
{
    
    // Set the title fo rhtis view
    self.title = @"Pantry";
    
    //self.navigationItem.rightBarButtonItem = self.editButtonItem;
    
    didModifyView = NO;


}
/***************************************************
 *
 * Inputs  : BOOL - will the View appear in an animated fashion?
 *
 * Purpose : Let the user know that there's nothing to do.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)viewDidAppear:(BOOL)animated
{
    [super viewDidAppear:animated];
    [self viewDidAppearPartTwo];
    
}

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : Split the viewDidAppear into two parts, so that this 
 *           part can be called separately.
 *
 * Outputs : None
 *
 ********************/
-(void)viewDidAppearPartTwo
{
    // Let the user know how to use this view
    if ([SettingsManager instance].showGuides) {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Guide",
                                                                                                            @"Hit the edit button once to delete items. Once again to stop deleting.", nil]];
    }
    
    // Display the contents of the view.
    if ([[PantryManager instance].pantryContents count] > 0) {
        [self.tableView reloadData];
    }
    
}

#pragma mark -
#pragma mark Table view data source

/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *
 * Purpose : We only have one section.  It's a single list.
 *
 * Outputs : NSInteger - the number of sections in this table
 *
 ***************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView 
{
    // Return the number of sections.
    return 1;
}


/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the delegate for the editing style of a row at a particular location in a table view."
 *            The value we return here assures that we do see the delete control.
 *
 * Outputs : UITableViewCellEditingStyle - the style of each of the rows when we're in 
 *           the MENU_SET menuState.
 *
 ******************************************************/
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
          editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleDelete;
}

/*********************************************************
 * 
 * Inputs  : UITableViewCellEditingStyle - Determine what editing control is displayed
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the delegate for the editing style of a row at a particular location in a table view."
 *            The value we return here assures that we do see the delete control.
 *
 * Outputs : UITableViewCellEditingStyle - the style of each of the rows when we're in 
 *           the MENU_SET menuState.
 *
 ******************************************************/

- (void)tableView:(UITableView *)tv commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath 
{
    
    // Remove from the pantry the item corresponding to the selected row
    [[PantryManager instance].pantryContents removeObjectAtIndex:indexPath.row];
    
    // Remove the item from the UITableView
    [self.tableView deleteRowsAtIndexPaths:[NSArray arrayWithObject:indexPath] 
                    withRowAnimation:UITableViewRowAnimationFade];
    
    didModifyView = YES;
}

/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSInteger - one of the sections in this table
 *
 * Purpose : We have as many rows as we have cells defined in the
 *           viewWillAppear method.
 *
 * Outputs : NSInteger - the number of rows in this section
 *
 ***************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.
    return [[PantryManager instance].pantryContents count];
}

/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSIndexPath - one of the rows in the table
 *
 * Purpose : Return each of the UITableViewCells we defined in the
 *           viewWillAppear method to populate the UITableView.
 *
 * Outputs : UITableViewCell - the UITableViewCell we should show 
 *           for the row defined by NSIndexPath
 *
 ***************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{
    float fontSize=15.0f;
    Ingredient * ingredient;
    static NSString *CellIdentifier = @"Cell";
    UILabel * mainLabel;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Get the ingredient corresponding to the row corresponding to indexPath.row
    ingredient = [[PantryManager instance].pantryContents objectAtIndex:indexPath.row];
    
    // Get the labels for the cell
    mainLabel = cell.textLabel;     
    mainLabel.numberOfLines = 2;
    mainLabel.font = [UIFont systemFontOfSize:fontSize];
    
    // Set the text of the cell
    mainLabel.text = [NSString stringWithFormat:@"A container of %@, %5.3f %@ left", ingredient.name,
                                                                                     ingredient.number,
                                                                                     ingredient.quantity];                    
    
    return cell;
}

#pragma mark -
#pragma mark Table view delegate

/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSIndexPath - one of the sections in this table
 *
 * Purpose : Define the height of a UITableViewCell.  We only want 
 *           7 rows to appear, so we set the height of a cell to
 *           1/7th the height of the UITableView.
 *
 * Outputs : CGFloat - The height of the UITableViewCell.
 *
 ***************************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return ceilf(self.tableView.frame.size.height/7.0f);
}

#pragma mark -
#pragma mark Memory management

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Don't do anything here.  viewDidUnload is 
 *           called just after this.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    NSLog(@"PantryViewController didReceiveMemoryWarning.");
    
}

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Relinquish ownership of anything that can be 
 *           recreated in viewDidLoad or on demand.  This method
 *           is called only if didReceiveMemoryWarning is called.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)viewDidUnload 
{
    NSLog(@"PantryViewController viewDidUnload.");
    [self controllerDown];
}

/*******************************************************
 *
 * Inputs  : None
 *
 * Purpose : Release member variables and save the state
 *           of the view into a database.
 *
 * Outputs : None
 *
 *******************************************************/
-(void) controllerDown
{
    if (didModifyView) {
        [[PantryManager instance] serializePantry];
    }
    
    
}

@end

