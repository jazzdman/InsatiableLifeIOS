//
//  FullPlateAppDelegate.m
//  FullPlate
//
//  Created by Jason Todd Mazzotta on 4/15/10.
//  Copyright Full Plate Productions 2010. All rights reserved.
//

#import "FullPlateAppDelegate.h"
#import "SettingsManager.h"
#import "GroceriesViewController.h"
#import "PantryViewController.h"
#import "SettingsViewController.h"

#import <dlfcn.h>


@implementation FullPlateAppDelegate

// Create setters and getters for the properties
@synthesize window;
@synthesize tabBarController;
@synthesize pickerView;
@synthesize displayItems;
@synthesize selectedPick;

/**********************************************
 *
 * Inputs  : None
 *
 * Purpose : Constructor for this class.  Allows
 *           us to create and initialize a variable
 *           to track whether didEnterBackground was called.
 *
 * Outputs : A pointer to an object of this class.
 *
 *********************************************/
-(id) init
{
    self = [ super init];
    
    if (self) {
        didEnterBackground = NO;
        alertViewHidden = NO;
        pickerViewHidden = NO;
        
        smallJar = [[UIImage imageNamed:@"small jar.png"] retain];
        mediumJar = [[UIImage imageNamed:@"medium jar.png"] retain];
        largeJar = [[UIImage imageNamed:@"large jar.png"] retain];
    }
    
    return self;
}

/**********************************************
 *
 * Inputs  : UIApplication - This application
 *           NSDictionary - 
 *
 * Purpose : Make sure the main window appears and that
 *           the user is directed to the right tab on startup.
 *
 * Outputs : BOOL - The application did start successfully.
 *
 *********************************************/
- (BOOL)application:(UIApplication *)application didFinishLaunchingWithOptions:(NSDictionary *)launchOptions 
{
    selectedTabIndex = [[NSUserDefaults standardUserDefaults] integerForKey:@"selectedTabIndex"];
	
	// If the user has not selected any settings, direct
    // them first to the settings tab.  Otherwise, open the tab
    // that the application was on when the application entered the background.
    // If the application is starting, this index will be 0.
	if ([SettingsManager instance].prepTime == nil) 
	{
		tabBarController.selectedIndex = 3;
		
	} else 
    {
		tabBarController.selectedIndex = selectedTabIndex;
	} 
    
    // Add the tab bar controller's current view as a subview of the window
    self.window.rootViewController = tabBarController;
    [window addSubview:tabBarController.view];
    [window makeKeyAndVisible];
    
    //[self loadReveal];
    
    return YES;
}

/**********************************************
 *
 * Inputs  : UIApplication - This application
 *
 * Purpose : Do what needs to be done when the 
 *           application enters the foreground.
 *
 * Outputs : None
 *
 *********************************************/
- (void)applicationWillEnterForeground:(UIApplication *)application
{   
    
    UINavigationController * nc;
    // If the application is coming back from the background
    // call the controllerUp methods to re-initialize the 
    // instance variables for the ViewControllers.  Have to do
    // this one at a time because Objective-C's dynamic binding is
    // only so dynamic.
    if(didEnterBackground)
    {
        for (nc in tabBarController.viewControllers) {
            [nc.topViewController controllerUp];
        }

        tabBarController.selectedIndex = selectedTabIndex;
    } 
        
}

/**********************************************
 *
 * Inputs  : UIApplication - A pointer to this application
 *
 * Purpose : Do what needs to be done when the 
 *           application enters the background.
 *
 * Outputs : None.
 *
 *********************************************/
- (void)applicationDidEnterBackground:(UIApplication *)application
{
    UIApplication * app = [UIApplication sharedApplication];
    
    // Take note of which tab was selected when the application
    // entered the background.
    selectedTabIndex = tabBarController.selectedIndex;
    
    // Take note of the fact that the application is entering the background
    didEnterBackground = YES;
    
    // Set up a background task to make sure the state of the 
    // application is saved.
    bgTask = [app beginBackgroundTaskWithExpirationHandler:^{
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    }];
    
    // Make sure the state of each of the views is saved.
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
               
        for (UINavigationController * nc in tabBarController.viewControllers) 
        {
            if ([nc.topViewController.view isMemberOfClass:[UIWebView class]]) {
                [nc popViewControllerAnimated:NO];
            }
            [nc.topViewController controllerDown];
        }
        
        [app endBackgroundTask:bgTask];
        bgTask = UIBackgroundTaskInvalid;
    });
    
}

/**********************************************
 *
 * Inputs  : UIApplication - A pointer to this application
 *
 * Purpose : Do what needs to be done when the application
 *           resigns its active status.
 *
 * Outputs : None.
 *
 *********************************************/
- (void)applicationWillResignActive:(UIApplication *)application
{
    // Hide the UIAlertView 
    if (!alert.hidden) {
        alert.hidden = YES;
	alertViewHidden = YES;
    }
    
    // Hide the UIPickerView
    if (!pickerView.hidden) {
        pickerView.hidden = YES;
	pickerViewHidden = YES;
    }
    
}

/**********************************************
 *
 * Inputs  : UIApplication - A pointer to this application.
 *
 * Purpose : Nothing at this point
 *
 * Outputs : None.
 *
 *********************************************/
- (void)applicationDidBecomeActive:(UIApplication *)application
{
    
    UINavigationController * nc;
    // Perform viewDidAppear on the Menu View when the application 
    // becomes active.
    if(didEnterBackground)
    {
        nc = [tabBarController.viewControllers objectAtIndex:selectedTabIndex];
        [nc.topViewController viewDidAppearPartTwo];
        didEnterBackground = NO;
    } 
    if(alertViewHidden)
    {
        alert.hidden = NO;
	alertViewHidden = NO;
    } 
    if(pickerViewHidden)
    {
        pickerView.hidden = NO;
	pickerViewHidden = NO;
    } 
}

/**********************************************
 *
 * Inputs  : UIApplicaiton - A pointer to this application.
 *
 * Purpose : Do what needs to be donw when the application
 *           is terminated.
 *
 * Outputs : None
 *
 *********************************************/
-(void) applicationWillTerminate:(UIApplication *)application 
{
    // Save the tab open tab
	[[NSUserDefaults standardUserDefaults] setInteger:tabBarController.selectedIndex forKey:@"selectedTabIndex"];

}

/**********************************************
 *
 * Inputs  : NSString - The title for the UIAlertView
 *           NSString - A message to display in the UIAlertView
 *
 * Purpose : Show a UIAlertView to the user.
 *
 * Outputs : None.
 *
 *********************************************/
-(void) showAlertWithTitleandMessage:(NSArray*)strings
{
    if (alert == nil) {
        alert = [[[UIAlertView alloc] initWithTitle: @""
                                      message: @""
                                      delegate: nil
                                      cancelButtonTitle: @"OK"
                                      otherButtonTitles: nil] retain];
    }
    
    alert.title = (NSString *)[strings objectAtIndex:0];;
    alert.message = (NSString *)[strings objectAtIndex:1];
    
    [alert show];
}

/********************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *
 * Purpose : Let the application know how many components/columns
 *           there are in this view.
 *
 * Outputs : NSInteger - there is only one component/column for 
 *                       this view.
 *
 *******************************************************/
- (NSInteger)numberOfComponentsInPickerView:(UIPickerView *)pickerView
{
    return 1;
}

/********************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *           NSInteger - the current component the application 
 *                       wants to populate
 *
 * Purpose : Let the application know how many rows there 
 *           are in this component.
 *
 * Outputs : NSInteger - we have as many rows as there are
 *                       items to display.
 *
 *******************************************************/
- (NSInteger)pickerView:(UIPickerView *)thePickerView numberOfRowsInComponent:(NSInteger)component
{
    return [displayItems count];
}

/********************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *           NSInteger - the current row the user has selected
 *           NSInteger - the current component/column the user has
 *                       selected.
 *
 * Purpose : Keep track of the row that the user has selected.
 *
 * Outputs : None
 *
 *******************************************************/
- (void)pickerView:(UIPickerView *)thePickerView didSelectRow:(NSInteger)row inComponent:(NSInteger)component
{
    self.selectedPick = row;
}

/********************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *           NSInteger - the current component/column the user has
 *                       selected.
 *
 * Purpose : Define the height of a row in the UIPickerView
 *
 * Outputs : CGFloat - the height of each row
 *
 *******************************************************/
- (CGFloat)pickerView:(UIPickerView *)thePickerView rowHeightForComponent:(NSInteger)component
{
    return smallJar.size.height+10.0f;
}

/********************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *           NSInteger - the current row the user has selected
 *           NSInteger - the current component/column the user has
 *                       selected.
 *           UIView * - a view to display
 *
 * Purpose : Define the value to display in a particular row of the 
 *           UIPickerView.
 *
 * Outputs : UIView * - the contents of a particular view
 *
 *******************************************************/
- (UIView *)pickerView:(UIPickerView *)pickerView viewForRow:(NSInteger)row forComponent:(NSInteger)component reusingView:(UIView *)view
{
    UIView * rowView = [[[UIView alloc] init] autorelease]; 
    UIImageView * imageView = nil;
    UILabel * rowLabel = [[UILabel alloc] init];
    UIImage * rowImage = rowImage = smallJar;
        
    if ([[displayItems objectAtIndex:0] isEqualToString:@"Small"]) {
        switch (row) {
            case 0:
                rowView.frame = CGRectMake(0.0f, 0.0f, 310.0f, rowImage.size.height+10.0f);
                break;
            case 1:
                rowImage = mediumJar;
                rowView.frame = CGRectMake(0.0f, 0.0f, 310.0f, rowImage.size.height+10.0f);
                break;
            case 2:
                rowImage = largeJar;
                rowView.frame = CGRectMake(0.0f, 0.0f, 310.0f, rowImage.size.height+10.0f);
                break;
            default:
                [self showAlertWithTitleandMessage:[NSArray arrayWithObjects:@"Error",
                                                    @"An unexpected error has occurred.  Please exit and restart FullPlate (FullPlateAppDelegate)",nil]];
                break;
        }
        rowLabel.frame = CGRectMake(rowImage.size.width + 10.0f, 0.0f, 160.0f, rowImage.size.height);
        rowLabel.text = [displayItems objectAtIndex:row];
        rowLabel.backgroundColor = [UIColor clearColor];
        [rowView addSubview:rowLabel];
        imageView = [[UIImageView alloc] initWithImage:rowImage];
        //imageView.frame = CGRectMake(0.0f, 160.0f, 160.0f, rowImage.size.height+10.0f);
        [rowView addSubview:imageView];
        
    } else {
        rowLabel.frame = CGRectMake(10.0f, 0.0f, 310.0f, rowImage.size.height+10.0f);  
        rowLabel.backgroundColor = [UIColor clearColor];
        rowLabel.text = [displayItems objectAtIndex:row];
        [rowView addSubview:rowLabel];
        

    }
    
    [imageView release];
    [rowLabel release];
    return rowView;
}

/***************************************************
 *
 * Inputs  : UIPickerView - the view for this controller
 *           NSInteger - the current component/column the user has
 *                       selected.
 *
 * Purpose : Define the width of each row in the UIPickerView
 *
 * Outputs : CGFloat - the width of each row in the 
 *                     UIPickerView
 *
 ***************************************************/
- (CGFloat)pickerView:(UIPickerView *)thePickerView widthForComponent:(NSInteger)component
{
    return 320.0f;
}


#pragma mark - Reveal


- (void)loadReveal
{
    NSString *revealLibName = @"libReveal";
    NSString *revealLibExtension = @"dylib";
    NSString *dyLibPath = [[NSBundle mainBundle] pathForResource:revealLibName ofType:revealLibExtension];
    NSLog(@"Loading dynamic library: %@", dyLibPath);
    
    void *revealLib = NULL;
    revealLib = dlopen([dyLibPath cStringUsingEncoding:NSUTF8StringEncoding], RTLD_NOW);
    
    if (revealLib == NULL)
    {
        char *error = dlerror();
        NSLog(@"dlopen error: %s", error);
        NSString *message = [NSString stringWithFormat:@"%@.%@ failed to load with error: %s", revealLibName, revealLibExtension, error];
        [[[UIAlertView alloc] initWithTitle:@"Reveal library could not be loaded" message:message delegate:nil cancelButtonTitle:@"OK" otherButtonTitles:nil] show];
    }
}


/**********************************************
 *
 * Inputs  : None
 *
 * Purpose : The destructor for this class. 
 *
 * Outputs : None
 *
 *********************************************/
- (void)dealloc {
    
    [super dealloc];
    
    if (pickerView) {
        [pickerView release];
    }
    
    if (alert) {
        [alert release];
    }
    
    if (tabBarController) {
        [tabBarController release];
    }
    
    if (window) {
        [window release];
    }
    
    [smallJar release];
    [mediumJar release];
    [largeJar release];

}

@end

