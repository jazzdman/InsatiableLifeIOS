//
//  OptionsViewController.m
//  FullPlate
//
//  Created by Jason Mazzotta on 4/25/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//


#import "OptionsViewController.h"



@implementation OptionsViewController


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
-(OptionsViewController *) initWithData:(NSArray *)data 
                           title:(NSString *)title
                           andIndex:(int)i
{
    self = [super init];
    
    if (self) 
    {
        // set the title of the viw
        self.title = title;
        previousSelection = nil;
                
        // This is the array of possible values for particular setting
        optionsArray = data;
        [optionsArray retain ];
        previousPath = nil;
        index = i;
        previousSelection = [[SettingsManager instance ] getSettingAtIndex:index]; 
        [previousSelection retain ];

    }

    return self;
}

#pragma mark -
#pragma mark View lifecycle

/***************************************************
 *
 * Inputs  : BOOL - did the View appear in an animated fashion?
 *
 * Purpose : Don't allow the user to navigate away from this view
 *           via the tab bar.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)viewDidAppear:(BOOL)animated 
{
    [super viewDidAppear:animated];
    
    for (UITabBarItem * item in self.tabBarController.tabBar.items) 
    {
        item.enabled = NO;
    }
    self.tableView.scrollEnabled = NO;
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

/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSInteger - one of the sections in this table
 *
 * Purpose : We have one more row than the number of settings
 *           in the settings dictionary.
 *
 * Outputs : NSInteger - the number of rows in this section
 *
 ***************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    // Return the number of rows in the section.

    return [ optionsArray count];
}

/***********************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSIndexPath - one of the rows in the table
 *
 * Purpose : Set up each of the cells in this table with one of 
 *           names in the optionsArray.  Place a checkmark in
 *           a cell that has been selected in the past.
 *
 * Outputs : UITableViewCell - the UITableViewCell we should show 
 *           for the row defined by NSIndexPath
 *
 ***********************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    float fontSize = 15.0f;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];

    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
    // Get the text from the array of options
    NSString * rowString = [optionsArray objectAtIndex: [indexPath row]];
    cell.textLabel.text = rowString;
    cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
        
    // Place a checkmark at this row if this option corresponds to a selection that was made in the 
    // past.
    if (previousSelection && [ previousSelection isEqualToString:rowString]) 
    {
        cell.accessoryType = UITableViewCellAccessoryCheckmark;
        // Hold onto this path, so we can clear it when we make a new
        // selection.
        
        previousPath = [indexPath retain];
    }

    return cell;
}

#pragma mark -
#pragma mark Table view delegate


/***************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSIndexPath - one of the rows in the table
 *
 * Purpose : Save the option that the user selected with
 *           the settings manager and update the checkmarks
 *           on the cells.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    NSString * data = nil;
    UITableViewCell * selectedCell = nil, * previousCell = nil;

    // First, save the selected setting
    // Save the user settings based on their position in the 
    // dictionary.
    selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    data = selectedCell.textLabel.text;
    [[SettingsManager instance] saveSetting:data atIndex:index];       
        
    // Clear the previously selected cell
    if (previousPath) 
    {
        previousCell = [tableView cellForRowAtIndexPath:previousPath];
        previousCell.accessoryType = UITableViewCellAccessoryNone;
                
        // Release the memory from the previous path
        [ previousPath release];
        
    } 
        
    // Add a checkmark to selected table cell
    selectedCell.accessoryType = UITableViewCellAccessoryCheckmark;

    // Unselect the cell
    selectedCell.selected = NO;
    
    // Retain the new indexPath
    previousPath = [ indexPath retain];

}

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
 * Purpose : Don't do anything in this method.  viewDidUnload
 *           is called immediately afterward.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    // Relinquish ownership any cached data, images, etc that aren't in use.
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
    // Relinquish ownership of anything that can be recreated in viewDidLoad or on demand.
    // For example: self.myOutlet = nil;
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
- (void)dealloc 
{
    [ super dealloc ];
    
    if (optionsArray) {
        [ optionsArray release ];
    }
    
    if (previousPath) {
        [ previousPath release ];
    }
     
    if (previousSelection) {
        [ previousSelection release ];
    }
    
}
@end
