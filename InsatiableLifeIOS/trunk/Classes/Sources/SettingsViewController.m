//
//  SettingsViewController.m
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "SettingsViewController.h"
#import "FullPlateAppDelegate.h"
#import "SettingsManager.h"

@implementation SettingsViewController

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
    CGRect textFrame = CGRectMake(240.0f,
                       14.0f,
                       70.0f,
                       25.0f);
    
    CGRect switchFrame = CGRectMake(232.0f,
                                  14.0f,
                                  40.0f,
                                  25.0f);
    
    
    // Create the calories UITextField
    caloriesField = [[UITextField alloc] initWithFrame:textFrame];
    caloriesField.keyboardType = UIKeyboardTypeDefault;
    caloriesField.returnKeyType = UIReturnKeyDone;
    caloriesField.backgroundColor = [UIColor whiteColor];
    caloriesField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    caloriesField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    caloriesField.textAlignment = UITextAlignmentLeft;
    caloriesField.tag = 0;
    caloriesField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    caloriesField.enabled = YES;
    caloriesField.borderStyle = UITextBorderStyleRoundedRect;
    caloriesField.delegate = self;
    
    // Create the prepTime UITextField
    prepTimeField = [[UITextField alloc] initWithFrame:textFrame];
    prepTimeField.keyboardType = UIKeyboardTypeDefault;
    prepTimeField.returnKeyType = UIReturnKeyDone;
    prepTimeField.backgroundColor = [UIColor whiteColor];
    prepTimeField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    prepTimeField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    prepTimeField.textAlignment = UITextAlignmentLeft;
    prepTimeField.tag = 0;
    prepTimeField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    prepTimeField.enabled = YES;
    prepTimeField.borderStyle = UITextBorderStyleRoundedRect;
    prepTimeField.delegate = self;
    
    // Create the servings text field
    servingsField = [[UITextField alloc] initWithFrame:textFrame];
    servingsField.keyboardType = UIKeyboardTypeDefault;
    servingsField.returnKeyType = UIReturnKeyDone;
    servingsField.backgroundColor = [UIColor whiteColor];
    servingsField.autocorrectionType = UITextAutocorrectionTypeNo; // no auto correction support
    servingsField.autocapitalizationType = UITextAutocapitalizationTypeNone; // no auto capitalization support
    servingsField.textAlignment = UITextAlignmentLeft;
    servingsField.tag = 0;
    servingsField.clearButtonMode = UITextFieldViewModeNever; // no clear 'x' button to the right
    servingsField.enabled = YES;
    servingsField.borderStyle = UITextBorderStyleRoundedRect;
    servingsField.delegate = self;
    
    // Create the guides switch
    guidesSwitch = [[UISwitch alloc] initWithFrame:switchFrame];
    guidesSwitch.on = YES;
    
    // Set the title of this view
	self.title = @"Settings";

}

/***************************************************
 *
 * Inputs  : BOOL - did the View appear in an animated fashion?
 *
 * Purpose : Make sure the contents of the UITableView are loaded.
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
-(void) viewDidAppearPartTwo
{
    UITabBarItem * tempItem;
       
    // If prepTime, servings and caloriesPerServing are nil,
    // tell the user they must be set.
    if ([SettingsManager instance].prepTime == nil ||
        [SettingsManager instance].servings == nil ||
        [SettingsManager instance].caloriesPerServing == nil) 
    {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                                                                                                            @"Max. Prep+Cook Time, Max Calories Per Serving and Servings Per Meal must be filled in to proceed.", nil]];
        
        for (int i = 0; i<3; i++) 
        {
            tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
            tempItem.enabled = NO;
        }
        
    } 
    // Otherwise enable the Menu View tab and the settings view tab
    else {
        
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:0];
        tempItem.enabled = YES;
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:1];
        tempItem.enabled = NO;
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:2];
        tempItem.enabled = NO;
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:3];
        tempItem.enabled = YES;
    }
   
    // Display the contents of this view.
    [self.tableView reloadData];
}

/***************************************************
 *
 * Inputs  : BOOL - did the View disappear in an animated fashion?
 *
 * Purpose : Make sure the settings are saved when this view disappears.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)viewWillDisappear:(BOOL)animated 
{
    [super viewWillDisappear:animated];
    
    // Save the settings set in this view.
    [SettingsManager instance].showGuides = guidesSwitch.on;
    [[SettingsManager instance] serializeSettings];
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
    int size = (int)[[[SettingsManager instance] getSettingsKeys] count];
    // Return the number of rows in the section.
    return  size + 1;
}


/***********************************************************
 *
 * Inputs  : UITableView - The view controlled by this class
 *           NSIndexPath - one of the rows in the table
 *
 * Purpose : Set up each of the cells in this table with one of 
 *           the UIViews defined viewWillAppear method to 
 *           populate the UITableView.
 *
 * Outputs : UITableViewCell - the UITableViewCell we should show 
 *           for the row defined by NSIndexPath
 *
 ***********************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    float fontSize = 15.0f;
    NSString * CellIdentifier = @"Cell";
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    NSMutableString * dateString = nil;
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }
   
    //NSLog(@"This is indexPath %d.",[indexPath row]);
    
    // Configure the cell...
    switch ([indexPath row]) {
           
        //  Setup up the cell to point to the instructions 
        case 0:
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = @"Instructions";
            cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
            break;
        // Setup the cell to display the max calories text field
        case 1:
            if ([caloriesField superview] == nil) 
            {
                cell.textLabel.text =@"Max. Calories Per Serving";
                cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
                [cell addSubview: caloriesField];
            }
            if([SettingsManager instance].caloriesPerServing  == nil)
            {
                caloriesField.placeholder = @"500";
            } else 
            {
                caloriesField.text = [SettingsManager instance].caloriesPerServing;
            }
			break;    
        // Setup the cell to display the max prep time text field
		case 2:
            if ([prepTimeField superview] == nil) 
            {
                cell.textLabel.numberOfLines = 2;
                cell.textLabel.text = @"Max. Prep. + Cook Time\nin Minutes ( 0 - 60 )";
                cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
                [cell addSubview: prepTimeField];
            }
            if([SettingsManager instance].prepTime  == nil)
            {
                prepTimeField.placeholder = @"50";
            } else {
                prepTimeField.text = [SettingsManager instance].prepTime;
            }
            break;
        // Set up the cell to display the servings text field 
		case 3:
            if ([servingsField superview] == nil) 
            {
                cell.textLabel.text =@"Servings Per Meal";
                cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
                [cell addSubview: servingsField];

            }
            if([SettingsManager instance].servings  == nil)
            {
                servingsField.placeholder = @"2";
            } else {
                servingsField.text = [SettingsManager instance].servings;
            }
            break;
        // Set up the cell to display the shopping day
		case 4:
            dateString = [[NSMutableString alloc] initWithCapacity:1];
            [dateString appendString: @"Shopping Day"];
            [dateString appendString:@"  -  "];
            [dateString appendString:[[SettingsManager instance] getSettingAtIndex:(int)indexPath.row -1]];
            cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
            cell.textLabel.text = dateString;
            cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
            [dateString release];
            break;
        // Set up the cell to show the user guides switch.
        case 5:
            if ([guidesSwitch superview] == nil) 
            {
                cell.textLabel.text =@"Show Guides";
                cell.textLabel.font = [UIFont systemFontOfSize:fontSize];
                [cell addSubview: guidesSwitch];
            }
            break;
		default:
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                                    [NSArray arrayWithObjects: @"Error",
                                                                                     @"An unexpected error has occurred.  Please exit and restart FullPlate (SettingsViewController)", nil]];
            break;
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
 * Purpose : Decide what to do when the user selects a row in the 
 *           table.  This UITableView only reacts to selection of two
 *           rows.  One for the display of instructions, the other 
 *           to allow the user to define which day of the week they do
 *           grocery shopping.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
	
	
	UITableViewCell * cell = [tableView cellForRowAtIndexPath:indexPath];
	
    // Display the Instructions.
    if (indexPath.row == 0) {
        // Create a controller for the Instructions View
        UIViewController * vc = [[[UIViewController alloc] initWithNibName:@"InstructionsViewController" bundle:[NSBundle mainBundle]] autorelease];
        
        
        // Push the controller into view
        [self.navigationController pushViewController:vc animated:YES];

    }
    // Display the list of days of the week.
    else if (indexPath.row == 4) 
    {

        // And the array of keys for the settings dictionary
        NSArray * settingsKeysArray = [[SettingsManager instance] getSettingsKeys];
        // Get the key that corresponds to the selected row
        NSString * settingsKey = [ settingsKeysArray objectAtIndex:[indexPath row]-1];
        	        
        // Add a view with the contents of the dictionary
        OptionsViewController  * optionsController = [[[ OptionsViewController alloc] 
                                                      initWithData: [[[SettingsManager instance] getSettingsDict] objectForKey:settingsKey]
                                                      title: settingsKey
                                                      andIndex: (int)[indexPath row]-1] autorelease];
        
        [self.navigationController pushViewController:optionsController animated:YES];

    } else {
        cell.selected = NO;
    }
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
    int size = (int)[[[SettingsManager instance] getSettingsKeys] count];
    return ceilf(self.tableView.frame.size.height/(float)(size+1));
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
- (void)didReceiveMemoryWarning 
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
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
    // Save the settings from this view
    [SettingsManager instance].showGuides = guidesSwitch.on;
    [[SettingsManager instance] serializeSettings];
    
    // Release memory.
    [prepTimeField release];
    [servingsField release];
    [caloriesField release];
    [guidesSwitch release];
}

/******************************************************
 *
 * Inputs  : UITextField - the text field the user has just entered text into
 *
 * Purpose : Save the values that the user enters into the various text fields
 *
 * Outputs : BOOL - the text field should implement its default behavior for the
 *                  return button.
 *
 ******************************************************/
- (BOOL)textFieldShouldReturn:(UITextField *)textField
{
    UITabBarItem * tempItem;
    float test1, test2;
    NSRange tempRange;
    float minCalories = [[SettingsManager instance].minCaloriesPerServing floatValue];
    float maxPrepTime = [[SettingsManager instance].maxPrepTime floatValue];
    float minServings = [[SettingsManager instance].minServings floatValue];
   
    
    // Get the values from the caloriesField, make sure it's a positive
    // whole number.
    if (caloriesField.text != nil) {
        test1 = (float)[caloriesField.text intValue];
        test2 = [caloriesField.text floatValue];
        tempRange = [caloriesField.text rangeOfString:@"-"];
        if (test1 != test2 ||
            tempRange.location != NSNotFound ||
            test2 < minCalories)
        {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:
                                                                                    [NSArray arrayWithObjects: @"Error",
                                [NSString stringWithFormat: @"Please enter a positive number greater than %f into the Calories Per Serving field.", minCalories], nil]];
        } else {
            [SettingsManager instance].caloriesPerServing = caloriesField.text;
        }
        
    }
    
    // Get the values from the prepTimeField, make sure it's a positive
    // whole number between 0 and 60
    if (prepTimeField.text != nil) {
        test1 = (float)[prepTimeField.text intValue];
        test2 = [prepTimeField.text floatValue];
        tempRange = [prepTimeField.text rangeOfString:@"-"];
        if (test1 != test2 ||
            tempRange.location != NSNotFound ||
            test2 == 0.0f || test2 > maxPrepTime)
        {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate]
                                                     showAlertWithTitleandMessage:[NSArray arrayWithObjects:@"Error",
                                                    [NSString stringWithFormat:@"Please enter a positive number between 0 and %@ into the Max. Prep + Cook Time field.",[SettingsManager instance].maxPrepTime], nil]];
        } else {
            [SettingsManager instance].prepTime = prepTimeField.text;
        }
        
    }
    
    // Get the values from the servingsField, make sure it's a positive
    // whole number.
    if (servingsField.text != nil) {
        test1 = (float)[servingsField.text intValue];
        test2 = [servingsField.text floatValue];
        tempRange = [servingsField.text rangeOfString:@"-"];
        if (test1 != test2 ||
            tempRange.location != NSNotFound ||
            test2 == 0.0f || test2 < minServings)
        {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate]
                                                     showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Error",
                            [NSString stringWithFormat:@"Please enter a positive number greater than %@ into the Servings Per Meal field.", [SettingsManager instance].minServings],nil]];
        } else {
            [SettingsManager instance].servings = servingsField.text;
        }
        
    }
    
    // If all three text values are filled in, allow the user
    // to proceed to the Menu View.
    if ([SettingsManager instance].prepTime != nil &&
        [SettingsManager instance].servings != nil &&
        [SettingsManager instance].caloriesPerServing != nil) 
    {
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:0];
        tempItem.enabled = YES;
    }

    // Allow the rest of the interface to react to 
    // user interactions.
    [textField resignFirstResponder];
    
    return YES;
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
-(void) dealloc
{
    [super dealloc];
    
    if (prepTimeField) 
        [prepTimeField release];
    
    if (servingsField) 
        [servingsField release];
    
    if (caloriesField) 
        [caloriesField release];
    
    if (guidesSwitch) 
        [guidesSwitch release];
    
}

@end

