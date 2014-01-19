//
//  MenuViewController.m
//  FullPlate
//
//  Created by Jason Todd Mazzotta on 4/15/10.
//  Copyright Full Plate Productions 2010. All rights reserved.
//

#import "MenuViewController.h"
#import "AllRecipesProxy.h"
#import "MenuManager.h"
#import "FullPlateAppDelegate.h"

@implementation MenuViewController

#pragma mark -
#pragma mark View lifecycle

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : "Called after the controller’s view is loaded into memory."  In particular
 *            this method:
 *           1)  Defines the frame for the UIProgressView
 *           2)  Defines the frame for the UITableView
 *           3(  Creates the "Done" and "Restart" buttons on the
 *               UINavigationController
 *           4)  Sets up the state of the menu view
 *           5)  Sets up a UIGestureRecognizer to the user can select recipes
 *               for the week
 *
 * Outputs : None
 *
 ********************/
 - (void)viewDidLoad 
{    
    UIScreen * screen = [UIScreen mainScreen];
    UIApplication * app = [UIApplication sharedApplication]; 
    float screen_height;
    float statusbar_height;
    float tabbar_height;
    float navigationbar_height;
    float table_height;

    [super viewDidLoad];
    
    // Create the frame for the UITableView.  This makes the UITableView smaller
    // to set allow the UIProgressView to appear.
    screen_height = screen.bounds.size.height;
    statusbar_height = app.statusBarFrame.size.height;
    tabbar_height = self.tabBarController.tabBar.frame.size.height;
    navigationbar_height = self.navigationController.navigationBar.frame.size.height;
    table_height = screen_height - statusbar_height - tabbar_height - navigationbar_height; 
    
    [[NSUserDefaults standardUserDefaults] setFloat:table_height+statusbar_height+navigationbar_height forKey:@"pbFrameY"];

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
    UIApplication * app = [UIApplication sharedApplication]; 
    float pbFrameY = 0.0f;
    NSLog(@"In controllerUp.");
    
    // Create the UIProgressView
    progressBar = [[[UIProgressView alloc] initWithProgressViewStyle:UIProgressViewStyleBar] retain];
    progressBar.hidden = YES;
    progressBar.progress = [[NSUserDefaults standardUserDefaults ] floatForKey:@"progress"];
    
    // Set the frame at this point, so that the table upon which its 
    // based has been instantiated.
    
    //Set up the UIProgressView
    pbFrameY = [[NSUserDefaults standardUserDefaults] floatForKey:@"pbFrameY"];
    frameForProgressBar = CGRectMake(0.0f, 
                                     pbFrameY - progressBar.frame.size.height, 
                                     self.view.frame.size.width, 
                                     progressBar.frame.size.height);
    
    progressBar.frame = frameForProgressBar;
    [app.keyWindow addSubview:progressBar];
    
    // Set up the UIGestureRecognizer that allows the user to select the recipes
    // they want for the week.
    UILongPressGestureRecognizer * longPressGestureRecognizer = 
    [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(handleLongPress:)];
    longPressGestureRecognizer.minimumPressDuration = 1.0;
    [self.tableView addGestureRecognizer:longPressGestureRecognizer];
    [longPressGestureRecognizer release];

    
    // Set up the done button when allows the user to proceed to the Groceries view
    self.navigationItem.leftBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@"Done"
                                                                      style:UIBarButtonItemStylePlain
                                                                      target: self
                                                                      action:@selector(enableTabBar)] autorelease];
    
    // Find the state of this view if it has been saved in the past
    menuState = [[NSUserDefaults standardUserDefaults] integerForKey:@"menuState"];
    NSLog(@"This is menuState, %d.", menuState);
    [AllRecipesProxy instance].recipesUpdated = [[NSUserDefaults standardUserDefaults] boolForKey:@"recipesUpdated"];
    
    
    // Create the thread that finds recipes and adds them to the 
    // menu view table
    populateThread = [[[NSThread alloc] initWithTarget:[AllRecipesProxy instance]
                                        selector:@selector(generateRecipes)
                                        object:nil] retain];
    
    // Create the right bar button item.  We don't know what it's label should
    // be at this point.
    self.navigationItem.rightBarButtonItem = [[[UIBarButtonItem alloc] initWithTitle:@""
                                                                       style:UIBarButtonItemStylePlain
                                                                       target: self
                                                                       action:@selector(updateMenu)] autorelease];
    
    // Set the title of this view
    if (menuState == SELECT_RECIPES) 
    {
        self.title = [NSString stringWithFormat:@"Menu - %d", [[AllRecipesProxy instance].recipeList count]];
    } else {
        self.title = @"Menu";
    }

    // Set up the Re/start button which allows the user to start the set of steps
    // in tihs view from the beginning.  Do this here.  viewDidAppear seems to
    // take a while.
    if (menuState == FINDING_RECIPES) {
        self.navigationItem.rightBarButtonItem.title = @"Start";
    } else {
        self.navigationItem.rightBarButtonItem.title = @"Restart";
    }
    
    // Get thenumber of day selections the user has made for the SELECT_RECIPES
    // state
    date = [[NSUserDefaults standardUserDefaults ] integerForKey:@"date"];
    
    // Has the user actually displayed a web page?
    pushedViewBool = [[NSUserDefaults standardUserDefaults ] boolForKey:@"pushedViewBool"];
    
    // If so, get the row the user selected
    if (pushedViewBool) {
        pushedViewInt = [[NSUserDefaults standardUserDefaults ] integerForKey:@"pushedViewInt"];
    }
    // pushedViewInt indicates that a row hasn't been selected
    else {
        pushedViewInt = -1;
    }

    // controllerUp has been called
    controllerUp = YES;
}

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : "Notifies the view controller that its view is about to be become visible."
 *            Create a thread to search for recipes when the menu state is 
 *            FIND_RECIPES
 *
 * Outputs : None
 *
 ********************/
- (void)viewDidAppear:(BOOL)animated 
{
    NSLog(@"In viewDidAppear.");
    NSLog(@"menuState: %d.", menuState);
    NSLog(@"PushedViewInt: %d.", pushedViewInt);
    NSLog(@"controllerUp : %d", controllerUp);
    
    [super viewDidAppear:animated];
    [self viewDidAppearPartTwo];
}

/*************************************************************
 * 
 * Inputs  : None
 *
 * Purpose : The method we call when application becomes active since
 *           viewDidAppear does not get called when application returns
 *           from the background
 *
 * Outputs : None
 *
 *************************************************************/
-(void)viewDidAppearPartTwo
{    
    UITabBarItem * tempItem; 
    Recipe * recipe;
    UIViewController * vc;
    UIWebView * tempView;
    
    insetsForTableView = UIEdgeInsetsMake(0.0, 0.0, progressBar.frame.size.height, 0.0);
            
    // Check to see if there is a network connection 
    // with which to do a menu search.
    if ([self currentReachabilityStatus] == NotReachable) {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage: [NSArray arrayWithObjects:@"Warning",
                                                                                                             @"A network connection is not available.  Please switch to iOS Settings to enable one.",nil]];
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        NSLog(@"No net connection.");
    }
    // Start searching for recipes if it's time to shop.
    else if ([[SettingsManager instance] timeToShop]) 
    {
        controllerUp = NO;
        NSLog(@"Time to shop.");
        // empty the table
        [[AllRecipesProxy instance].recipeList removeAllObjects];
        
        // Load those cells into the display    
        [self.tableView reloadData];
        
        // Add the Progress bar to the Window
        //[self.view.superview addSubview:progressBar];
        progressBar.hidden = NO;
        
        // Start the thread
        [populateThread start];
        
        // Tell the user how to proceed
        if ([SettingsManager instance].showGuides) 
        {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Guide",
                                                                                                                @"Tap a recipe to view it.  Press and hold to (un)select it for the week or hit the Restart button.", nil]];
            
        }
        
        // While the thread is running, don't allow the user
        // to move to the Groceries View
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
               
            
        // The populate thread is starting again, so we are in the
        // midst of updating the recipes.
        [AllRecipesProxy instance].recipesUpdated = NO;
        
        // Make room for the progress view
        self.tableView.contentInset = insetsForTableView;
        
        // Make sure the table view is scrollable
        self.tableView.scrollEnabled = YES;
        
        menuState = FINDING_RECIPES;
        
        // Make sure users can't move from this view  
        for (int i = 1; i< 4; i++) {
            tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
            tempItem.enabled = NO;
        }
        
    } 
    // We get to this point if the application is returning
    // from the background while the user was
    // looking at a recipe in a UIWebView
    else if (menuState == FINDING_RECIPES &&
             pushedViewInt >= 0 &&
             controllerUp) 
    {
        NSLog(@"Returning to push webview back into view.");
        controllerUp = NO;
        progressBar.hidden = YES;
        
        [populateThread start];
        
        // Get the Recipe that corresponds to the selected index
        recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:pushedViewInt];
        
        // Create a controller for the web view that will display the story.
        vc = [[[UIViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]] autorelease];
        
        // Push the controller into view
        [self.navigationController pushViewController:vc animated:YES];
        
        // Tell the users where the recipe comes from
        vc.title = @"allrecipes.com";
        
        // Load the request into the web view
        tempView = (UIWebView *)vc.view;
        tempView.scalesPageToFit = YES;
        [tempView loadHTMLString:recipe.recipePage baseURL:recipe.recipeURL];
        
        // Make sure users can't move from this view  
        for (int i = 1; i< 4; i++) {
            tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
            tempItem.enabled = NO;
        }
        
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
    }  
    // The controller is being brought back from the background,
    // still trying to find recipes, but a web page is not in view.
    else if(menuState == FINDING_RECIPES &&
            controllerUp &&
            progressBar.progress != 0.0f)
    {
        controllerUp = NO;
        NSLog(@"Finding recipes.");
        self.navigationItem.rightBarButtonItem.enabled = NO;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        
        pushedViewInt = -1;
        pushedViewBool = NO;
        
        progressBar.hidden = NO;
        [populateThread start];
        
        // Make sure users can't move from this view  
        for (int i = 1; i< 4; i++) {
            tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
            tempItem.enabled = NO;
        }
        
        self.tableView.scrollEnabled = YES;

    }
    // We get here during normal execution of the
    // app when a UIWebView is popped off the 
    // UINavigationController
    else if(menuState == FINDING_RECIPES &&
            pushedViewInt >= 0)
    {
        if ([populateThread isFinished]) {
            [self populateTable];
            [populateThread release];
            populateThread = nil;
        } else {
            progressBar.hidden = NO;
        }
        
        pushedViewInt = -1;
        pushedViewBool = NO;
    }
    // This happens if we enter this view on a day that isn't
    // shopping day.
    else if (menuState == FINDING_RECIPES)
    {
        controllerUp = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.tableView.scrollEnabled = YES;
    } else if (menuState == SELECT_RECIPES) {
        controllerUp = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = NO;
        self.tableView.scrollEnabled = YES;
    } else if (menuState == MENU_SET) {
        controllerUp = NO;
        self.navigationItem.rightBarButtonItem.enabled = YES;
        self.navigationItem.leftBarButtonItem.enabled = YES;
        self.tableView.scrollEnabled = NO;
    }
    
    //NSLog(@"The number of recipes %d",[[AllRecipesProxy instance].recipeList count]);
}

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : This method is called when the user presses the
 *           Restart button on the UINavigationController
 *
 * Outputs : None
 *
 ********************/
-(void) updateMenu
{
    UITabBarItem * tempItem;
    FullPlateAppDelegate * fpAppDelegate;
    
    // Set the frame of the UITableView to allow the UIProgressView to appear
    self.tableView.contentInset = insetsForTableView;
    
    
    // Reset the title of the view
    self.title = @"Menu";
    
    // Make the progress bar visible
    progressBar.hidden = NO;
    
    // Set the progress to 0
    progressBar.progress = 0.0f;
    
    // Clear out the currently displayed UITableViewCells
    [[AllRecipesProxy instance].recipeList removeAllObjects];
    
    // Reload those cells into the UITableView
    [self.tableView reloadData];
    
    // Release the previous thread that populates the Menu View
    // UITableView
    [populateThread release];
    
    // Crate a new thread and start it
    populateThread = [[[NSThread alloc] initWithTarget:[AllRecipesProxy instance]
                                             selector:@selector(generateRecipes)
                                             object:nil] retain];
    [populateThread start];
    
    // Don't allow the user to press the buttons on the UINavigationController
    self.navigationItem.rightBarButtonItem.enabled = NO;
    self.navigationItem.leftBarButtonItem.enabled = NO;
    
    // Make sure the user can 
    self.tableView.scrollEnabled = YES;
    
    // Disable the other tab bar items
    for (int i = 1; i< 4; i++) {
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
        tempItem.enabled = NO;
    }
    
    // We are now attempting to find recipes
    menuState = FINDING_RECIPES;
    
    // Reset the counter for when the user selects recipes for the week.
    date = 0;
    
    // Tell the user how to proceed
    if ([SettingsManager instance].showGuides) 
    {
        fpAppDelegate = (FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate];
        [fpAppDelegate showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Guide",
                                                                                @"Tap a recipe to view it.  Press and hold to (un)select it for the week or hit the Restart button.", nil]];
        
    }    
}

/*******************
 * 
 * Inputs  : None
 *
 * Purpose : This method is called when the user presses the
 *           Done button on the UINavigationController
 *
 * Outputs : None
 *
 ********************/
-(void) enableTabBar
{
    // Enable the Groceries View button on the tab bar
    UITabBarItem * tempItem;
    for (int i = 1; i< 4; i++) {
        tempItem = [self.tabBarController.tabBar.items objectAtIndex:i];
        tempItem.enabled = YES;
    }
    
    // Turn off the reorder controls on the Recipes
    [self.tableView setEditing:NO];
    
}

#pragma mark -
#pragma mark Table view data source

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 * 
 * Purpose : "Asks the data source to return the number of sections in the table view."
 *           There is only one section in this UITableView
 *
 * Outputs : NSInteger - the number of sections in this UITableView
 *
 ******************************************************/
- (NSInteger)numberOfSectionsInTableView:(UITableView *)tableView {
    // Return the number of sections.
    return 1;
}


/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSInteger - The current section
 * 
 * Purpose : "Asks the data source to return the number of sections in the table view."
 *               There is only one section in this UITableView
 *
 * Outputs : NSInteger - the number of rows in "section" in this UITableView
 *
 ******************************************************/
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section 
{
    return ([[AllRecipesProxy instance].recipeList count] == 0 ? 7:[[AllRecipesProxy instance].recipeList count]);
}


/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the data source for a cell to insert in a particular location of the table view."
 *            Returns the Recipes created by the AllRecipesProxy
 *
 * Outputs : UITableViewCell - The UITableViewCell that corresponds to indexPath
 *
 ******************************************************/
- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath 
{   
    Recipe * recipe;
    static NSString *CellIdentifier = @"Cell";
    UITableViewCell *cell = [self.tableView dequeueReusableCellWithIdentifier:CellIdentifier];
    
    if (cell == nil) 
    {
        cell = [[[UITableViewCell alloc] initWithStyle:UITableViewCellStyleDefault reuseIdentifier:CellIdentifier] autorelease];
    }

    // Set the contents of a cell if there are recipes to display
    if ([[AllRecipesProxy instance].recipeList count] != 0) 
    {
        recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:[indexPath row]];
        cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
        
        [self setLabel:cell fromRecipe:recipe];
    }
    
    // Remove all subviews from a cell when we re-enter the
    // FINDING_RECIPES menuState
    if ([[AllRecipesProxy instance].recipeList count] == 0 &&
        [cell.subviews count] > 0)
    {
        for (UIView * view in cell.contentView.subviews) 
        {
            [view removeFromSuperview];
        }
        cell.accessoryType = UITableViewCellAccessoryNone;
    }
    
    return cell;
}

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the delegate for the height to use for a row in a specified location."
 *            Returns the height we want for the UITableViewCells.  We always want to display 7.
 *
 * Outputs : CGFloat - The height of the UITableViewCell that corresponds to indexPath
 *
 *****************************************************/
- (CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    BOOL hidden = progressBar.hidden;
    float height = 0.0f;
    
    // Take the height of the UIProgressBar into account when
    // calculating the height of a table row.
    if (hidden) {
        
        height = ceilf(self.tableView.frame.size.height/7.0f);
        
    } else {
        
        height = ceilf((self.tableView.frame.size.height-progressBar.frame.size.height)/7.0);
    }
    
    return height;
}

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the delegate for the editing style of a row at a particular location in a table view."
 *            This is called when we are in the MENU_SET menuState.  The value we return here assures that
 *            the deletion control does not appear.
 *
 * Outputs : UITableViewCellEditingStyle - the style of each of the rows when we're in 
 *           the MENU_SET menuState.
 *
 ******************************************************/
-(UITableViewCellEditingStyle)tableView:(UITableView *)tableView 
                              editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return UITableViewCellEditingStyleNone;
}

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the delegate whether the background of the specified row should be indented 
 *            while the table view is in editing mode."  Even though the method above ensure 
 *            that the deletion conrol is not displayed, this method must return no so that
 *            the text in each cell is fully left-justified.
 *
 * Outputs : BOOL - A value that lets the application know that the text in each cell should not be indented
 *
 ******************************************************/
- (BOOL)tableView:(UITableView *)tableView shouldIndentWhileEditingRowAtIndexPath:(NSIndexPath *)indexPath
{
    return NO;
}

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Tells the data source to move a row at a specific location in the table view to another location."
 *           For the Menu View, we're interested in making sure that when the user rearranges a recipe that the
 *           days of the week stay in ascending order.
 *
 * Outputs : BOOL - A value that lets the application know that the text in each cell should not be indented
 *
 ******************************************************/
 - (void)tableView:(UITableView *)tableView moveRowAtIndexPath:(NSIndexPath *)fromIndexPath toIndexPath:(NSIndexPath *)toIndexPath 
{
    Recipe * firstRecipe, * secondRecipe, * tempRecipe;
    int direction = fromIndexPath.row - toIndexPath.row, i, tempInt;
    NSString * tempString;

    // Handle the case where the user in moving adjacent cells
    if (abs(direction) == 1) 
    {
        // Swap the recipeDate strings around
        firstRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        secondRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:toIndexPath.row];
        tempString = [secondRecipe.recipeDateString copy];
        tempInt = secondRecipe.recipeDateInt;
        secondRecipe.recipeDateString = firstRecipe.recipeDateString;
        firstRecipe.recipeDateString = tempString;
        firstRecipe.recipeDateInt = tempInt;
        
        
        // Swaps the actal cells themselves within the list
        tempRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        [tempRecipe retain];
        [[AllRecipesProxy instance].recipeList removeObjectAtIndex:fromIndexPath.row];
        [[AllRecipesProxy instance].recipeList insertObject:tempRecipe atIndex:toIndexPath.row];
        [tempRecipe release];
        [tempString release];
        
    } 
    // Handle the case where the user is moving a cell up the list
    else if (direction > 0 ) 
    {
        
        // Get the date of the cell the user is moving
        firstRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        tempString = [firstRecipe.recipeDateString copy];
        tempInt = firstRecipe.recipeDateInt;
        
        // Remove the cell being moved from its current position in the list
        tempRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        [tempRecipe retain];
        [[AllRecipesProxy instance].recipeList removeObjectAtIndex:fromIndexPath.row];
        
        // Move it to where we want to be
        [[AllRecipesProxy instance].recipeList insertObject:tempRecipe atIndex:toIndexPath.row];
        [tempRecipe release];
        
        // Move all the intermediate dates down one in the list
        for (i=toIndexPath.row; i<fromIndexPath.row; i++) 
        {
            firstRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:i];
            secondRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:i+1];
            firstRecipe.recipeDateString = secondRecipe.recipeDateString;
            firstRecipe.recipeDateInt = secondRecipe.recipeDateInt;
        }
        
        // Set the date of the cell that was moved back to the place in the list
        // from which it came.
        tempRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        tempRecipe.recipeDateString = tempString;
        tempRecipe.recipeDateInt = tempInt;
        [tempString release];
        
    }
    // Handle the case where the user is moving a cell donw the list
    else if (direction < 0) 
    {
        // Get the date of the cell the user is moving
        firstRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        tempString = [firstRecipe.recipeDateString copy];
        tempInt = firstRecipe.recipeDateInt;
        
        // Remove the cell being moved from its current position in the list
        tempRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        [tempRecipe retain];
        [[AllRecipesProxy instance].recipeList removeObjectAtIndex:fromIndexPath.row];
        
        // Move it to where we want to be
        [[AllRecipesProxy instance].recipeList insertObject:tempRecipe atIndex:toIndexPath.row];
        [tempRecipe release];
        
        // Move all the intermediate dates up one in the list
        for (i=toIndexPath.row; i>fromIndexPath.row; i--) 
        {
            firstRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:i];
            secondRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:i-1];
            firstRecipe.recipeDateString = secondRecipe.recipeDateString;
            firstRecipe.recipeDateInt = secondRecipe.recipeDateInt;
        }
        
        // Set the date of the cell that was moved back to the place in the list
        // from which it came.
        tempRecipe = [[AllRecipesProxy instance].recipeList objectAtIndex:fromIndexPath.row];
        tempRecipe.recipeDateString = tempString;
        tempRecipe.recipeDateInt = tempInt;
        [tempString release];

    }

    // Redraw the recipes
    [self.tableView reloadData];
}
 
/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Asks the data source whether a given row can be moved to another location in the 
 *            table view."  For this view, we are only interested in allowing the user to move cells about
 *            when the application is in the MENU_SET menuState.
 *
 * Outputs : BOOL - A value that lets the application know that Recipes can be moved around in the table
 *
 ******************************************************/
 - (BOOL)tableView:(UITableView *)tableView canMoveRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Return NO if you do not want the item to be re-orderable.
    return menuState == MENU_SET;
    
}



#pragma mark -
#pragma mark Table view delegate

/*********************************************************
 * 
 * Inputs  : UITableView - The UITableView for the Menu View
 *           NSIndexPath - A data structure that contains a row number
 * 
 * Purpose : "Tells the delegate that the specified row is now selected."
 *            This method is used when the menuState is not FINDING_RECIPES.  In those
 *            states, the user can see the contents of the recipe.  This is done by 
 *            pushing a UIWebView onto the UINavigationController. The UIWebView 
 *            displays the recipePage, which is the HTML for the recipe scaled to the
 *            number of servings they requested in the Settings View.
 *
 * Outputs : BOOL - A value that lets the application know that UITableViewCells can be moved around in the table
 *
 ******************************************************/
- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath 
{
    // Allow this if the application is not in the FINDING_RECIPES menuStatate
    
    Recipe * recipe = nil;
    UIWebView * tempView = nil;
        
    // Get the Recipe that corresponds to the selected index
    recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:[indexPath row]];
        
    // Create a controller for the web view that will display the story.
    UIViewController * vc = [[[UIViewController alloc] initWithNibName:@"WebViewController" bundle:[NSBundle mainBundle]] autorelease];
        
    pushedViewInt = indexPath.row;
    pushedViewBool = YES;
    controllerUp = NO;
        
    // Push the controller into view
    [self.navigationController pushViewController:vc animated:YES];
    
    // Tell the users where the recipe comes from
    vc.title = @"allrecipes.com";
        
    // Load the request into the web view
    tempView = (UIWebView *)vc.view;
    tempView.scalesPageToFit = YES;
    [tempView loadHTMLString:recipe.recipePage baseURL:recipe.recipeURL];
    progressBar.hidden = YES;

}

/*********************************************************
 * 
 * Inputs  : UILongPressGestureRecognizer - the UIGestureRecognizer that triggered this method call
 *          
 * Purpose : Allow the user to define which of the recipes found in the FINDING_RECIPES state
 *           should be used to create a grocery list.
 *
 * Outputs : None
 *
 ******************************************************/
-(void)handleLongPress:(UILongPressGestureRecognizer *)longPressGestureRecognizer
{
    int i, j;
    NSIndexPath * newPath;
    Recipe * recipe;
    static int count = 0;
    NSString * tempString;
    
    NSLog(@"In handleLongPress.");
    
    // This guards against the press that is held for more than a second
    if ( count > 0 || menuState != SELECT_RECIPES) 
    {
        count = 0;
        return;
    }
    count++;

    // Get the NSIndexPath for the point that was touched
    newPath = [self.tableView indexPathForRowAtPoint:[longPressGestureRecognizer locationInView:self.tableView]];
    
    // Get the cell the user selected
    recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:newPath.row];
 
    // If the user has already selected this cell, remove the dateString
    if (![recipe.recipeDateString isEqualToString:@""]) 
    {
        tempString = [[NSString alloc] initWithString:@""];
        recipe.recipeDateString = tempString;
        [tempString release];
        recipe.recipeDateInt = -1;
        date--;
    } else {
        
        // Set the recipeDate for the cell depending on how many presses
        // they've made
        switch (([SettingsManager instance].shoppingDay + date)%7) 
        {
            case 0:
                tempString = [[NSString alloc] initWithString:@"Sunday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 0;
                break;
            case 1:
                tempString = [[NSString alloc] initWithString:@"Monday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 1;
                break;
            case 2:
                tempString = [[NSString alloc] initWithString:@"Tuesday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 2;
                break;
            case 3:
                tempString = [[NSString alloc] initWithString:@"Wednesday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 3;
                break;
            case 4:
                tempString = [[NSString alloc] initWithString:@"Thursday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 4;
                break;
            case 5:
                tempString = [[NSString alloc] initWithString:@"Friday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 5;
                break;
            case 6:
                tempString = [[NSString alloc] initWithString:@"Saturday - "];
                recipe.recipeDateString= tempString;
                [tempString release];
                recipe.recipeDateInt = 6;
                break;
            default:
                [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Error",
                                                                                                                    @"An unexpected error has occurred.  Please exit and restart FullPlate (handleLongPress)", nil]];
                break;

        }
        // Increment the press counter
        date++;

    }

    // Do this when the user has selected 7 recipes
    if (date == 7) 
    {
        // Make sure to stop the populateThread
        if ([populateThread isExecuting]) {
            [populateThread cancel];
            progressBar.hidden = YES;
        }        
        while ([populateThread isExecuting]) {
            [NSThread sleepForTimeInterval:.1];
        }
        [populateThread release];
        populateThread = nil;
        
        // Go through all the cells in the list
        for (i = [[AllRecipesProxy instance].recipeList count]-1; i >=0 ; i--) 
        {
            recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:i];
            // Delete the cells that were not selected
            if ([recipe.recipeDateString isEqualToString:@""]) {
                [[AllRecipesProxy instance].recipeList removeObjectAtIndex:i];
            }
        }
        
        // Tell the user they may rearrange cells if they wish
        if ([SettingsManager instance].showGuides) {
            [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Guide",
                           @"Rearrange the recipes if you wish.  Hit the Restart button or Done to proceed.",nil]];

        }
        
        
        // We're at the point where we'd want to update the 
        // the Groceries View.
        [AllRecipesProxy instance].recipesUpdated = YES;

        
        // Make sure selected recipes are in order
        for (i=0; i<[[AllRecipesProxy instance].recipeList count]; i++) 
        {
            for (j=0; j<[[AllRecipesProxy instance].recipeList count]; j++) 
            {
                recipe = [[AllRecipesProxy instance].recipeList objectAtIndex:j];
                                
                if (recipe.recipeDateInt == ([SettingsManager instance].shoppingDay + i)%7) 
                { 
                    [[AllRecipesProxy instance].recipeList exchangeObjectAtIndex:i withObjectAtIndex:j];
                    break;
                }
            }
        }
        
        // Allow the user to press the "Done" button to proceed to the
        // Groceries View
        self.navigationItem.leftBarButtonItem.enabled = YES;
        
        // We are now in the MENU_SET menuState
        menuState = MENU_SET;
        
        // Don't allow the user to scroll the UITableView
        self.tableView.scrollEnabled = NO;
        
        // Display the re-order controls
        [self.tableView setEditing:YES animated:YES];
        
        // NSLog(@"We have %d Recipes.", [[AllRecipesProxy instance].recipeList count]);
        
        self.title = @"Menu";
                
    }
    
    // Redraw the whole visible table.  For some reason
    // redrawing a single, leaves that single cell looking
    // selected.  Setting the selected property for a cell 
    // in cellForRowAtIndexPath also doesn't work.
    [AllRecipesProxy instance].threadWait = YES;
    [self.tableView reloadData];
    [AllRecipesProxy instance].threadWait = NO;

 
    // Roll the press counter over to zero, if necessary
    date %= 7;
    
    
}

#pragma mark -
#pragma mark Memory management

/*********************************************************
 * 
 * Inputs  : None
 *          
 * Purpose : Don't do anything here.  viewDidUnload is 
 *           called just after this.
 *
 * Outputs : None
 *
 ***********************************************************/
- (void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Relinquish ownership any cached data, images, etc that aren't in use.
}

/*********************************************************
 * 
 * Inputs  : None
 *          
 * Purpose : "Called when the controller’s view is released from memory."
 *            Stop the populdate thread if it's running, save the Recipes
 *            to disk if not.  Release all instance variables.
 *
 * Outputs : None
 *
 ***********************************************************/
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

    // If the populateThread is running
    // save the progress of the thread and then
    // cancel the thread, wait for it to end
    // and then release the thread.
    if (populateThread && [populateThread isExecuting]) {
        
        [[NSUserDefaults standardUserDefaults ] setFloat:progressBar.progress forKey:@"progress"];
        [populateThread cancel];
        while ([populateThread isExecuting]) {
            [NSThread sleepForTimeInterval:.1];
        }
        [populateThread release];
        populateThread = nil;
    }
        
    // Save the contents of the AllRecipesProxy
    [[MenuManager instance] serializeMenu];
        
    // Save the menuState
    [[NSUserDefaults standardUserDefaults] setInteger:menuState forKey:@"menuState"];
    NSLog(@"This is menuState, %d.", menuState);
    
    // Have the recipes been updated.
    [[NSUserDefaults standardUserDefaults] setBool:[AllRecipesProxy instance].recipesUpdated forKey:@"recipesUpdated"];
    
    // The date selection index for the SELECT_RECIPES state
    [[NSUserDefaults standardUserDefaults ] setInteger:date forKey:@"date"];
    
    // Whether a UIWebView has been pushed into view and the table row that view
    // corresponds to.
    [[NSUserDefaults standardUserDefaults ] setInteger:pushedViewInt forKey:@"pushedViewInt"];
    [[NSUserDefaults standardUserDefaults ] setBool:pushedViewBool forKey:@"pushedViewBool"];
    
    // Save the progress of the progress bar, remove it from its super view and release it
    [[NSUserDefaults standardUserDefaults ] setFloat:progressBar.progress forKey:@"progress"];
    [progressBar removeFromSuperview];
    [progressBar release];
    
    //  Release the populate thread even if it hasn't been run.
    if (populateThread) {
        [populateThread release];
        populateThread = nil;
    }
    
    // Remove the gesture recognizer
    for (UIGestureRecognizer * gr in self.tableView.gestureRecognizers) {
        if ([gr isMemberOfClass:[UILongPressGestureRecognizer class]]) {
            [self.tableView removeGestureRecognizer:gr];
        }
        
    }
    
}


/*********************************************************
 * 
 * Inputs  : None
 *          
 * Purpose : The method that's called when the populate thread
 *           has finished its run.  Let's the user know if the
 *           populate thread was able to find at least 7 recipes
 *           and displays them if the thread has.
 *
 * Outputs : None
 *
 ***********************************************************/
-(void) populateTable
{
    // If we haven't found 7 recipes.  Let the user know.
    if ([[AllRecipesProxy instance].recipeList count] < 7) 
    {
        [(FullPlateAppDelegate *)[[UIApplication sharedApplication] delegate] showAlertWithTitleandMessage:[NSArray arrayWithObjects: @"Warning",
                       @"Full Plate was unable to find seven recipes to fill your menu.  Please press Restart or try different settings.", nil]];
    }
    // Otherwise, display the recipes
    else {
        
        // We are now in the SELECT_RECIPES menuState
        menuState = SELECT_RECIPES;
        self.title = [NSString stringWithFormat:@"Menu - %d", [[AllRecipesProxy instance].recipeList count]];        
    }
    [populateThread release];
    populateThread = nil;
    
    self.navigationItem.rightBarButtonItem.title = @"Restart";
    // Display the recipes
    [self.tableView reloadData];
    
    // Make sure table is still scrollable
    self.tableView.scrollEnabled = YES;
}

/*********************************************************
 * 
 * Inputs  : NSString - a number in string format that corresponds
 *                      to how far along in the recipe search the populate
 *                      thread is.
 *          
 * Purpose : This method is called by the populate thread to update
 *           the UIProgressView as it progresses through the search.
 *
 * Outputs : None
 *
 ***********************************************************/
-(void) updateProgressBar:(NSString *)percentage
{
    float floatPercentage = [percentage floatValue];
  
    
    // Set the "length" of the progress bar
    [progressBar setProgress:floatPercentage];
    
    // If percentage is "done", then we can hide the progress bar
    if ([percentage isEqualToString:@"done"]) 
    {
        progressBar.hidden = YES;
        
        // Redraw the UITableView
        self.tableView.contentInset = UIEdgeInsetsZero;
        
        // Enable the Restart button
        self.navigationItem.rightBarButtonItem.enabled = YES;
    }
}

/******************************************************************
 *
 * Inputs  : None
 *
 * Purpose : Check if we can actually reach the allrecipes.com website
 *           either via cell radio or the WiFi radio.
 *
 * Outputs : NetworkStatus - A number that indicates what type of network
 *           connection we have.
 *
 ******************************************************************/
- (NetworkStatus) currentReachabilityStatus
{
	SCNetworkReachabilityRef reachabilityRef = SCNetworkReachabilityCreateWithName(NULL, [@"allrecipes.com" UTF8String]);
    NetworkStatus retVal = NotReachable;
	SCNetworkReachabilityFlags flags;
    
	if (SCNetworkReachabilityGetFlags(reachabilityRef, &flags))
	{
        retVal = [self networkStatusForFlags: flags];
	}

	return retVal;
}

/******************************************************************
 *
 * Inputs  : SCNetworkReachabilityFlags - The bits that determine
 *           what sort of network connection we have
 *
 * Purpose : Bitwise and the flags against various constants to determine
 *           what type of network access is available.
 *
 * Outputs : NetworkStatus - A number that indicates what type of network
 *           connection we have.
 *
 ******************************************************************/
- (NetworkStatus) networkStatusForFlags: (SCNetworkReachabilityFlags) flags
{

	if ((flags & kSCNetworkReachabilityFlagsReachable) == 0)
	{
		// if target host is not reachable
		return NotReachable;
	}
    
	BOOL retVal = NotReachable;
	
	if ((flags & kSCNetworkReachabilityFlagsConnectionRequired) == 0)
	{
		// if target host is reachable and no connection is required
		//  then we'll assume (for now) that your on Wi-Fi
		retVal = ReachableViaWiFi;
	}
	
	
	if ((((flags & kSCNetworkReachabilityFlagsConnectionOnDemand ) != 0) ||
         (flags & kSCNetworkReachabilityFlagsConnectionOnTraffic) != 0))
	{
        // ... and the connection is on-demand (or on-traffic) if the
        //     calling application is using the CFSocketStream or higher APIs
        
        if ((flags & kSCNetworkReachabilityFlagsInterventionRequired) == 0)
        {
            // ... and no [user] intervention is needed
            retVal = ReachableViaWiFi;
        }
    }
	
	if ((flags & kSCNetworkReachabilityFlagsIsWWAN) == kSCNetworkReachabilityFlagsIsWWAN)
	{
		// ... but WWAN connections are OK if the calling application
		//     is using the CFNetwork (CFSocketStream?) APIs.
		retVal = ReachableViaWWAN;
	}
	return retVal;
}

/*************************************************************
 *
 * Inputs  : None
 *
 * Purpose : Set the "label" for this UITableViewCell.  In reality
 *           the textLabel and detailTextLabel not used.  We want
 *           to be able to do a couple of things here, 1) have the
 *           text label wrap if it needs to and 2) Have the day of
 *           the week appear in a bold font with the recipe name in
 *           a regular font.  So, instead of the *Labels, we add UILabels
 *           to the contextView to achieve this effect.
 *
 * Outputs : None
 * 
 *************************************************************/
-(void) setLabel:(UITableViewCell *)cell fromRecipe:(Recipe *)recipe;
{
    UILabel * firstLabel, * secondLabel, * thirdLabel;
    CGRect firstRect, secondRect, thirdRect;
    NSMutableString * labelString = [[NSMutableString alloc] initWithCapacity:1];
    CGSize tempSize1, tempSize2;
    int i,j,k;
    float contentViewX = 10.0f;
    float contentViewY = cell.contentView.frame.origin.y;
    float contentViewWidth;
    float contentViewHeight = cell.contentView.frame.size.height;
    float fontSize = 15.0f;
    float accessorySize = 20.0f;
    
    // Break the recipeTitle up at space boundaries into an array of strings
    NSArray * labelArray = [recipe.recipeTitle componentsSeparatedByString:@" "];
    int labelArraySize = [labelArray count];
    
    // Set the width of the context 
    contentViewWidth = cell.contentView.frame.size.width - accessorySize;
    
    // Remove any labels we added the last time we
    // called this method
    for (UIView *view in cell.contentView.subviews) {
        [view removeFromSuperview];
    } 
    
    // Do the following if the date is not set
    if ([recipe.recipeDateString isEqualToString:@""] && 
         ![recipe.recipeTitle isEqualToString:@""]) 
    {
        
        //NSLog(@"recipeDateString is empty.");
        // Check how wide the recipeTitle is
        tempSize1 = [recipe.recipeTitle sizeWithFont:[UIFont systemFontOfSize:fontSize]];
        
        // If it is less than the contenViewWidth, we can set it in
        // one UILabel
        if (tempSize1.width <= contentViewWidth) 
        {
            firstRect = CGRectMake(contentViewX, contentViewY, contentViewWidth, contentViewHeight/2.0f);
            firstLabel = [[UILabel alloc] initWithFrame:firstRect];
            firstLabel.text = recipe.recipeTitle;
            firstLabel.font = [UIFont systemFontOfSize:fontSize];
            [cell.contentView addSubview: firstLabel];
            [firstLabel release];
        } 
        // Otherwise, we need to find out the largest string 
        // we can fit into the content view, make that one label
        // and put the rest in a second label
        else {
            
            // Start with the whole recipeTitle string and work down
            for (i = labelArraySize; i >= 0; i--) 
            {
                // Put the string back together
                for (j = 0; j < i; j++) 
                {
                    [labelString appendString:[labelArray objectAtIndex:j]];
                    if (j != i-1) 
                    {
                        [labelString appendString:@" "];
                    }
                }
                
                // Check the size of this string
                tempSize1 = [labelString sizeWithFont:[UIFont systemFontOfSize:fontSize]];
                
                // If the substring is shorter than the content view
                if (tempSize1.width <= contentViewWidth) 
                {
                    // Add that substring into the content view
                    firstRect = CGRectMake(contentViewX, contentViewY, contentViewWidth, contentViewHeight/2.0f);
                    firstLabel = [[UILabel alloc] initWithFrame:firstRect];
                    firstLabel.text = labelString;
                    firstLabel.font = [UIFont systemFontOfSize:fontSize];
                    [cell.contentView addSubview: firstLabel];
                    [firstLabel release];
                    [labelString setString:@""];
                    
                    // Construct the rest of the string
                    for (k = j; k < labelArraySize; k++) 
                    {
                        [labelString appendString:[labelArray objectAtIndex:k]];
                        if (k != labelArraySize - 1) 
                        {
                            [labelString appendString:@" "];
                        }
                    }
                    
                    // Add that substring below the first into the contentView
                    secondRect = CGRectMake(contentViewX, contentViewY + contentViewHeight/2.0f, contentViewWidth, contentViewHeight/2.0f);
                    secondLabel = [[UILabel alloc] initWithFrame:secondRect];
                    secondLabel.text = labelString;
                    secondLabel.font = [UIFont systemFontOfSize:fontSize];
                    [cell.contentView addSubview: secondLabel];
                    [secondLabel release];
                    break;
                    
                } 
                [labelString setString:@""];
            }
        }
    }
    
    // Do the following if both the date and recipeTitle are set
    if (![recipe.recipeTitle isEqualToString:@""] && 
        ![recipe.recipeDateString isEqualToString:@""])
    {
        // NSLog(@"recipeDateString:%@ recipeTitle: %@.", self.recipeDateString, self.recipeTitle);
        
        // Start from the whole recipeTitle string
        for (i = [labelArray count]; i >= 0; i--) 
        {
            //[labelString appendString:@" - "];
            for (j = 0; j < i; j++) 
            {
                [labelString appendString:[labelArray objectAtIndex:j]];
                if (j != i-1) 
                {
                    [labelString appendString:@" "];
                }
            }
            
            // Get the width of that string
            tempSize1 = [labelString sizeWithFont:[UIFont systemFontOfSize:fontSize]];
            // And the width of the recipeDateString
            tempSize2 = [recipe.recipeDateString sizeWithFont:[UIFont boldSystemFontOfSize:fontSize]];
            
            // NSLog(@"j : %d  i : %d", j , i);
            
            // If those two widths are less than the width of the contentView
            if (tempSize1.width + tempSize2.width <= contentViewWidth) 
            {
                // This means the whole recipeTitle and recipeDateString are less
                // than the width of the contentView.  So we use two UILabels. 
                // The UILabel for the date is in bold font.  The recipeTitle UILabel
                // is in a regular font.
                if (j == labelArraySize) 
                {
                    // NSLog(@"This should be here for empty cells.");
                    // The date UILabel
                    firstRect = CGRectMake(contentViewX, contentViewY, tempSize2.width, contentViewHeight/2.0f);
                    firstLabel = [[UILabel alloc] initWithFrame:firstRect];
                    firstLabel.text = recipe.recipeDateString;
                    firstLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                    [cell.contentView addSubview: firstLabel];
                    [firstLabel release];    
                    
                    // The title UILabel
                    secondRect = CGRectMake(contentViewX + tempSize2.width, contentViewY, tempSize1.width, contentViewHeight/2.0f);
                    secondLabel = [[UILabel alloc] initWithFrame:secondRect];
                    secondLabel.text = labelString;
                    secondLabel.font = [UIFont systemFontOfSize:fontSize];
                    [cell.contentView addSubview: secondLabel];
                    [secondLabel release];    
                }
                // If we're here, then we need three UILabels.  The date UILabel will be inline with
                // a substring of the recipe title.  The rest of the recipe title will lie below the
                // date UIlabel.  The date UILabel will be in bold.
                else {
                    
                    //  The UILabel for the date
                    firstRect = CGRectMake(contentViewX, contentViewY, tempSize2.width, contentViewHeight/2.0f);
                    firstLabel = [[UILabel alloc] initWithFrame:firstRect];
                    firstLabel.text = recipe.recipeDateString;
                    firstLabel.font = [UIFont boldSystemFontOfSize:fontSize];
                    [cell.contentView addSubview: firstLabel];
                    [firstLabel release]; 
                    
                    // The UILabel for the first substring of the title
                    secondRect = CGRectMake(contentViewX + tempSize2.width, contentViewY, tempSize1.width, contentViewHeight/2.0f);
                    secondLabel = [[UILabel alloc] initWithFrame:secondRect];
                    secondLabel.text = labelString;
                    secondLabel.font = [UIFont systemFontOfSize:fontSize];
                    [cell.contentView addSubview: secondLabel];
                    [secondLabel release];    
                    [labelString setString:@""];
                    
                    // Construct the rest of the recipe title 
                    for (k = j; k < labelArraySize; k++) 
                    {
                        [labelString appendString:[labelArray objectAtIndex:k]];
                        if (k != labelArraySize - 1) 
                        {
                            [labelString appendString:@" "];
                        }
                    }
                    
                    // Add that as a UILabel below the two other labels
                    thirdRect = CGRectMake(contentViewX, 
                                           contentViewY + contentViewHeight/2.0f, 
                                           contentViewWidth, 
                                           contentViewHeight/2.0f);
                    thirdLabel = [[[UILabel alloc] initWithFrame:thirdRect] autorelease];
                    thirdLabel.text = labelString;
                    thirdLabel.font = [UIFont systemFontOfSize:fontSize];
                    [cell.contentView addSubview: thirdLabel];
                    
                    
                }
                break;
            } 
            [labelString setString:@""];
        }
    }
    
    [labelString release];
    
    NSLog(@"The cell's contentView has this many subviews %d.",[cell.contentView.subviews count]);
    //[cell.contentView.subviews count];
}

/**********************************************
 *
 * Inputs  : None
 *
 * Purpose : Release all the memory we've been holding onto
 *           in member variables.
 *
 * Outputs : None 
 *
 **********************************************/
-(void) dealloc
{    
    [progressBar release];
    
    [populateThread release];
    
    [super dealloc];
}

@end












