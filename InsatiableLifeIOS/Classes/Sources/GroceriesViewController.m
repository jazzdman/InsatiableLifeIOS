//
//  GroceriesViewController.m
//  FullPlate
//
//  Created by Jason Mazzotta on 4/18/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "GroceriesViewController.h"
#import "MenuViewController.h"
#import "AllRecipesProxy.h"
#import "FullPlateAppDelegate.h"
#import "GroceriesManager.h"
#import "PantryManager.h"


@implementation GroceriesViewController


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
 * Inputs : None
 *
 * Purpose : Initialize member variables and recover 
 *               anything in the database that was saved
 *               in controllerDown.
 *
 * Outputs : None
 *
 *******************************************************/
-(void) controllerUp
{    
    // Set the sizes for spice containers
    sizes = [[[NSArray alloc] initWithObjects:@"Small", @"Medium", @"Large", nil] retain];
    
    // Set the weights for bulk foods
    weights = [[[NSArray alloc] initWithObjects:@"1 oz.", @"2 oz.", @"3 oz.", @"4 oz.", 
                @"5 oz.", @"6 oz.", @"7 oz.", @"8 oz.",
                @"9 oz.", @"10 oz.", @"11 oz.", @"12 oz.",
                @"13 oz.", @"14 oz.", @"15 oz.", @"1 lb",
                @"1 lb 1 oz.", @"1 lb 2 oz.", @"1 lb 3 oz.", @"1 lb 4 oz.",
                @"1 lb 5 oz.", @"1 lb 6 oz.", @"1 lb 7 oz.", @"1 lb 8 oz.",
                @"1 lb 9 oz.", @"1 lb 10 oz.", @"1 lb 11 oz.", @"1 lb 12 oz.",
                @"1 lb 13 oz.", @"1 lb 14 oz.", @"1 lb 15 oz.", @"2 lb",
                @"2 lb 1 oz.", @"2 lb 2 oz.", @"2 lb 3 oz.", @"2 lb 4 oz.",
                @"2 lb 5 oz.", @"2 lb 6 oz.", @"2 lb 7 oz.", @"2 lb 8 oz.",
                @"2 lb 9 oz.", @"2 lb 10 oz.", @"2 lb 11 oz.", @"2 lb 12 oz.",
                @"2 lb 13 oz.", @"2 lb 14 oz.", @"2 lb 15 oz.", @"3 lb",
                @"3 lb 1 oz.", @"3 lb 2 oz.", @"3 lb 3 oz.", @"3 lb 4 oz.",
                @"3 lb 5 oz.", @"3 lb 6 oz.", @"3 lb 7 oz.", @"3 lb 8 oz.",
                @"3 lb 9 oz.", @"3 lb 10 oz.", @"3 lb 11 oz.", @"3 lb 12 oz.",
                @"3 lb 13 oz.", @"3 lb 14 oz.", @"3 lb 15 oz.", @"4 lb",
                @"4 lb 1 oz.", @"4 lb 2 oz.", @"4 lb 3 oz.", @"4 lb 4 oz.",
                @"4 lb 5 oz.", @"4 lb 6 oz.", @"4 lb 7 oz.", @"4 lb 8 oz.",
                @"4 lb 9 oz.", @"4 lb 10 oz.", @"4 lb 11 oz.", @"4 lb 12 oz.",
                @"4 lb 13 oz.", @"4 lb 14 oz.", @"4 lb 15 oz.", @"5 lb", nil] retain];
    
    // Set the volumes for liquids
    volumes = [[[NSArray alloc] initWithObjects:@"1 oz.", @"2 oz.", @"3 oz.", @"4 oz.",
                @"5 oz.", @"6 oz.", @"7 oz.", @"8 oz.",
                @"9 oz.", @"10 oz.", @"11 oz.", @"12 oz.",
                @"13 oz.", @"14 oz.", @"15 oz.", @"1 pt",
                @"1 pt 1 oz.", @"1 pt 2 oz.", @"1 pt 3 oz.", @"1 pt 4 oz.",
                @"1 pt 5 oz.", @"1 pt 6 oz.", @"1 pt 7 oz.", @"1 pt 8 oz.",
                @"1 pt 9 oz.", @"1 pt 10 oz.", @"1 pt 11 oz.", @"1 pt 12 oz.",
                @"1 pt 13 oz.", @"1 pt 14 oz.", @"1 pt 15 oz.", @"2 pt",
                @"2 pt 1 oz.", @"2 pt 2 oz.", @"2 pt 3 oz.", @"2 pt 4 oz.",
                @"2 pt 5 oz.", @"2 pt 6 oz.", @"2 pt 7 oz.", @"2 pt 8 oz.",
                @"2 pt 9 oz.", @"2 pt 10 oz.", @"2 pt 11 oz.", @"2 pt 12 oz.",
                @"2 pt 13 oz.", @"2 pt 14 oz.", @"2 pt 15 oz.", @"3 pt",
                @"3 pt 1 oz.", @"3 pt 2 oz.", @"3 pt 3 oz.", @"3 pt 4 oz.",
                @"3 pt 5 oz.", @"3 pt 6 oz.", @"3 pt 7 oz.", @"3 pt 8 oz.",
                @"3 pt 9 oz.", @"3 pt 10 oz.", @"3 pt 11 oz.", @"3 pt 12 oz.",
                @"3 pt 13 oz.", @"3 pt 14 oz.", @"3 pt 15 oz.", @"4 pt",
                @"4 pt 1 oz.", @"4 pt 2 oz.", @"4 pt 3 oz.", @"4 pt 4 oz.",
                @"4 pt 5 oz.", @"4 pt 6 oz.", @"4 pt 7 oz.", @"4 pt 8 oz.",
                @"4 pt 9 oz.", @"4 pt 10 oz.", @"4 pt 11 oz.", @"4 pt 12 oz.",
                @"4 pt 13 oz.", @"4 pt 14 oz.", @"4 pt 15 oz.", @"5 pt",
                @"5 pt 1 oz.", @"5 pt 2 oz.", @"5 pt 3 oz.", @"5 pt 4 oz.",
                @"5 pt 5 oz.", @"5 pt 6 oz.", @"5 pt 7 oz.", @"5 pt 8 oz.",
                @"5 pt 9 oz.", @"5 pt 10 oz.", @"5 pt 11 oz.", @"5 pt 12 oz.",
                @"5 pt 13 oz.", @"5 pt 14 oz.", @"5 pt 15 oz.", @"6 pt",
                @"6 pt 1 oz.", @"6 pt 2 oz.", @"6 pt 3 oz.", @"6 pt 4 oz.",
                @"6 pt 5 oz.", @"6 pt 6 oz.", @"6 pt 7 oz.", @"6 pt 8 oz.",
                @"6 pt 9 oz.", @"6 pt 10 oz.", @"6 pt 11 oz.", @"6 pt 12 oz.",
                @"6 pt 13 oz.", @"6 pt 14 oz.", @"6 pt 15 oz.", @"7 pt",
                @"7 pt 1 oz.", @"7 pt 2 oz.", @"7 pt 3 oz.", @"7 pt 4 oz.",
                @"7 pt 5 oz.", @"7 pt 6 oz.", @"7 pt 7 oz.", @"7 pt 8 oz.",
                @"7 pt 9 oz.", @"7 pt 10 oz.", @"7 pt 11 oz.", @"7 pt 12 oz.",
                @"7 pt 13 oz.", @"7 pt 14 oz.", @"7 pt 15 oz.", @"1 gal.", nil] retain];
    
    activityIndicator = [[[UIActivityIndicatorView alloc] initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleGray] retain];
    
}

/***************************************************
 *
 * Inputs  : BOOL - will the View appear in an animated fashion?
 *
 * Purpose : This is the point when we decide what the contents
 *           of the Groceries view should be, based on the 
 *           recipes the user selected.
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
    // Add the activity indicator so it can be seend
    [self.tableView addSubview: activityIndicator];
    
    // Set the activity indicator's center
    [activityIndicator setCenter:CGPointMake(self.tableView.frame.size.width/2.0f, 
                                             self.tableView.frame.size.height/2.0f)];
    
    // Start the activity indicator rotating
    [activityIndicator startAnimating];
    
    // Start a thread to create the table.
    [NSThread detachNewThreadSelector:@selector(buildTable) toTarget:self withObject:nil];

}

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : A method that sets the contents of the table.
 *
 * Outputs : None
 *
 ********************/
-(void) buildTable
{
    int count = 0;
    NSMutableArray * ingredients;
    NSAutoreleasePool * pool = [[NSAutoreleasePool alloc] init];
    
    // Get all the ingredients from all the selected
    // recipes, if the recipes have been updated.
    if ([AllRecipesProxy instance].recipesUpdated) 
    {
        
        // Create an array to hold ingredients
        ingredients = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
        
        // Make sure to empty the contents of the GroceriesManager
        [[GroceriesManager instance].groceries removeAllObjects];
        
        // Make sure this trigger is not fired again,
        // unless the recipe view is updated.
        [AllRecipesProxy instance].recipesUpdated = NO;
        
        for (Recipe * recipe in [AllRecipesProxy instance].recipeList) {
            
            for (NSString * ingredient in recipe.recipeIngredients) 
            {
                //NSLog(@"An ingredient %@.", [cell.recipeIngredients objectAtIndex:j]);
                [ingredients addObject:ingredient];
                //[ingredient autorelease];
                
            }
            
        }
        
        // Decide which of those ingredients should actually appear
        // in the Grociers View
        [[AllRecipesProxy instance] parseGroceries:ingredients];
        
    }
    
    // Set the title for this view
    for (Ingredient * tempIngredient in [GroceriesManager instance].groceries) 
    {
        if (![tempIngredient.color isEqual:[UIColor greenColor]]) {
            count++;
        }
    }
    
    // Let the user know how many groceries they need to buy
    if (count == 0) {
        self.title = @"Groceries";
    } else {
        self.title = [NSString stringWithFormat:@"Groceries - %d", count];
    }
    
    // Draw the contents
    [self.tableView reloadData];
    
    // Stop the activity indicator rotating
    [activityIndicator performSelectorOnMainThread:@selector(stopAnimating) withObject:nil waitUntilDone:YES];
    
    // Hide the activity indicator
    activityIndicator.hidden = YES;
    
    // Remove the acitivity indicator
    [activityIndicator removeFromSuperview];
    [pool drain];

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
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
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
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    // Return the number of rows in the section.
    return [[GroceriesManager instance].groceries count];
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
    float fontSize = 15.0f;
    static NSString *CellIdentifier = @"Cell";
    UILabel * mainLabel;
    Ingredient * tempIngredient;
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Get the ingredient associated with a particular row.
    tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:indexPath.row];
    
    // Get the text label of the cell
    mainLabel = cell.textLabel;
    mainLabel.numberOfLines = 2;
    mainLabel.font = [UIFont systemFontOfSize:fontSize];
    
    // The display for a cell depends on whether an ingredient
    // is liquid and not perishable
    if (tempIngredient.isLiquid &&
        !tempIngredient.isPerishable) 
    {
        
        mainLabel.text = [NSString stringWithFormat:@"A bottle of %@, enough for %5.3f %@", tempIngredient.name,
                          tempIngredient.number,
                          tempIngredient.quantity];                    
    }
    // The display for a cell depends on whether an ingredient
    // is liquid and not perishable
    else if (tempIngredient.inContainer) 
    {
        
        mainLabel.text = [NSString stringWithFormat:@"A container of %@, enough for %5.3f %@", tempIngredient.name,
                          tempIngredient.number,
                          tempIngredient.quantity];                    
    }
    // Display an ingredient without a number or quantity.
    else if (tempIngredient.number == 0 &&
               [tempIngredient.quantity isEqualToString:@""])
    {
        mainLabel.text = [NSString stringWithFormat:@"%@", tempIngredient.name]; 
    }     
    // Round number up to 1 for an ingredient without a quantity and a number less than 1.
    else if (tempIngredient.number < 1.0 &&
              [tempIngredient.quantity isEqualToString:@""])
    {
        mainLabel.text = [NSString stringWithFormat:@"1.000 %@", tempIngredient.name]; 
    }
    else
    {
        mainLabel.text = [NSString stringWithFormat:@"%5.3f %@ %@", tempIngredient.number,
                          tempIngredient.quantity,
                          tempIngredient.name];
    }
    
    mainLabel.textColor = tempIngredient.color;
    
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
 *           table.  Specifically, color the row green and move the
 *           row to the end of the table.  If the row contains an ingredient
 *           that is bulk, liquid or in a container, open a UIActionSheet with
 *           a UIPickerView to allow user to define the size of this container.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    UITableViewCell * selectedCell;
    Ingredient * tempIngredient;
    UIActionSheet * actionSheet;
    int count = 0;
    FullPlateAppDelegate * fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
    
    selectedCell = [tableView cellForRowAtIndexPath:indexPath];
    // Unselect the cell
    selectedCell.selected = NO;
   
    // Get the cell that corresponds to this row
    tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:indexPath.row];
    [tempIngredient retain];

    // Only react to cells that haven't been touched before
    if (![tempIngredient.color isEqual:[UIColor greenColor]])
    {
       
        // Pop up a UIPickerView if the ingredient is a liquid
        if (tempIngredient.isLiquid &&
            !tempIngredient.isPerishable) 
        {   
            // Hold onto the row number the user has selected
            selectedRow = (int)indexPath.row;
        
            // Set up a UIActionSheet to isplay the UIPickerView that
            // allows the user to choose the volume of bottle they bought.
            fpAppDelegate.pickerView.showsSelectionIndicator = YES;
            fpAppDelegate.displayItems = volumes;
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"What is the volume of the bottle?" 
                                                 delegate:self
                                                 cancelButtonTitle:@"Done"
                                                 destructiveButtonTitle:nil 
                                                 otherButtonTitles:nil];
        
            // Display this UIPickerView
            [actionSheet addSubview:fpAppDelegate.pickerView]; 
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            [actionSheet setBounds:CGRectMake(0, 0, 320, 440)];
            [fpAppDelegate.pickerView setFrame:CGRectMake(0, 100, 320, 180)];
        
            // Clean up
            [actionSheet release];
        } 
        // Pop up a UIPickerView if the ingredient is bulk
        else if (tempIngredient.isBulk) 
        {   
            // Hold onto the row number the user has selected
            selectedRow = (int)indexPath.row;
        
            // Set up a UIActionSheet to isplay the UIPickerView that
            // allows the user to choose the weight of bulk item they bought
            fpAppDelegate.pickerView.showsSelectionIndicator = YES;
            fpAppDelegate.displayItems = weights;
             
            actionSheet = [[UIActionSheet alloc] initWithTitle:@"What is the weight of the container?" 
                                                 delegate:self
                                                 cancelButtonTitle:@"Done"
                                                 destructiveButtonTitle:nil 
                                                 otherButtonTitles:nil];
        
            // Display this UIPickerView
            [actionSheet addSubview:fpAppDelegate.pickerView];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            [actionSheet setBounds:CGRectMake(0, 0, 320, 440)];
            [fpAppDelegate.pickerView setFrame:CGRectMake(0, 100, 320, 180)];
        
            // Clean up
            [actionSheet release];
        }
        // Pop up a UIPickerView if the ingredient in a container but not perishable
        // should be a spice.
        else if (tempIngredient.inContainer && 
                !tempIngredient.isPerishable) 
        {   
            // Hold onto the row number the user has selected
            selectedRow = (int)indexPath.row;
        
            // Set up a UIActionSheet to isplay the UIPickerView that
            // allows the user to choose the weight of bulk item they bought
            fpAppDelegate.pickerView.showsSelectionIndicator = YES;
            fpAppDelegate.displayItems = sizes;

            actionSheet = [[UIActionSheet alloc] initWithTitle:@"What is the size of the container?" 
                                                 delegate:self
                                                 cancelButtonTitle:@"Done"
                                                 destructiveButtonTitle:nil 
                                                 otherButtonTitles:nil];

            // Display this UIPickerView
            [actionSheet addSubview:fpAppDelegate.pickerView];
            [actionSheet showInView:[UIApplication sharedApplication].keyWindow];
            [actionSheet setBounds:CGRectMake(0, 0, 320, 440)];
            [fpAppDelegate.pickerView setFrame:CGRectMake(0, 100, 320, 180)];
        
            // Cleanup
            [actionSheet release];
    
        }
        // Add an individual ingredient to the pantry 
        else if(tempIngredient.isIndividual) {
            // Change the color of the row to green 
            tempIngredient.color = [UIColor greenColor];
            [[PantryManager instance ] saveIngredient:tempIngredient withProperty:nil];
            // Move the corresponding ingredient to the bottom of the list
            [[GroceriesManager instance].groceries removeObjectAtIndex:indexPath.row];
            [[GroceriesManager instance].groceries addObject:tempIngredient];
            // Redraw the contents of the table
            [self.tableView reloadData];
            
            // Set the title for this view
            for (Ingredient * tempIngredient in [GroceriesManager instance].groceries) 
            {
                if (![tempIngredient.color isEqual:[UIColor greenColor]]) {
                    count++;
                }
            }
            if (count == 0) {
                self.title = @"Groceries";
            } else {
                self.title = [NSString stringWithFormat:@"Groceries - %d", count];
            }
            
                        
        } // This is every other ingredient that doesn't go into the
          // the pantry
        else {
            
            // Change the color of the row to green 
            tempIngredient.color = [UIColor greenColor];
            
            // Move the corresponding ingredient to the bottom of the list
            [[GroceriesManager instance].groceries removeObjectAtIndex:indexPath.row];
            [[GroceriesManager instance].groceries addObject:tempIngredient];
            // Redraw the contents of the table
            [self.tableView reloadData];
            
            // Set the title for this view
            for (Ingredient * tempIngredient in [GroceriesManager instance].groceries) 
            {
                if (![tempIngredient.color isEqual:[UIColor greenColor]]) {
                    count++;
                }
            }
            if (count == 0) {
                self.title = @"Groceries";
            } else {
                self.title = [NSString stringWithFormat:@"Groceries - %d", count];
            }
        }
    } 
    [tempIngredient release];
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
 * Purpose : Don't do anything here.  viewDidUnload is 
 *           called just after this.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)didReceiveMemoryWarning {
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
    [[PantryManager instance] serializePantry];
    [[GroceriesManager instance] serializeGroceries];
    [volumes release];
    [weights release];
    [sizes release]; 
}

/***************************************************
 *
 * Inputs  : UIActionSheet - The action sheet that got
 *                           closed
 *           NSInteger - the index of the button that was pressed
 *                       to close the action sheet
 *
 * Purpose : React to the Done button being pressed
 *           on the UIActionSheet.  Specifically,
 *           save the amount of the ingredient, 
 *           that is in a container, into the pantry.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex
{
    FullPlateAppDelegate * fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
    Ingredient * tempIngredient = [[GroceriesManager instance].groceries objectAtIndex:selectedRow];
    NSString * tempString = [fpAppDelegate.displayItems 
                             objectAtIndex:fpAppDelegate.selectedPick];
    int count = 0;
    
    
    if ([[PantryManager instance] saveIngredient: tempIngredient withProperty: tempString]) {
        
        // Change the color of the row to green 
    	tempIngredient.color = [UIColor greenColor];
    
        // Move the corresponding ingredient to the bottom of the list
        [[GroceriesManager instance].groceries removeObjectAtIndex:selectedRow];
        [[GroceriesManager instance].groceries addObject:tempIngredient];
        // Redraw the contents of the table
        [self.tableView reloadData];
    
        // Display the number of groceries that have not yet been selected.
        for (Ingredient * tempIngredient in [GroceriesManager instance].groceries) 
        {
            if (![tempIngredient.color isEqual:[UIColor greenColor]]) {
                count++;
            }
        }
        if (count == 0) {
            self.title = @"Groceries";
        } else {
            self.title = [NSString stringWithFormat:@"Groceries - %d", count];
        }
    }
}


/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Release all references to the member variables
 *           in this class.
 *
 * Outputs : None
 *
 ***************************************************/
- (void)dealloc 
{
    [super dealloc];
    
    if (volumes) 
        [volumes release];
    
    if (weights)
        [weights release];
    
    if (sizes)
        [sizes release];
    
    if (activityIndicator) {
        [activityIndicator release];
    }
}


@end

