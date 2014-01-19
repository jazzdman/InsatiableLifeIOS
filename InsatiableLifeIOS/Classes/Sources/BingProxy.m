//
//  AllRecipesProxy.m
//  FullPlate
//
//  Created by Jason Mazzotta on 5/22/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import "BingProxy.h"

@implementation BingProxy

// Construct the settes and gettings for the properties
@synthesize recipeURLs;

/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : This method is the "constructor" for this class.  It
 *            initializes all member variables.
 *
 *  Outputs : AllRecipesProxy - a pointer to a AllRecipesProxy object
 *
 ******************************************************************/
-(BingProxy *) init
{
    id tempObject;
    self=[super init];
    
	if (self) 
	{
        tempObject = [[NSMutableArray alloc] initWithCapacity:1];
        self.recipeURLs = tempObject;
        [tempObject release];
	}
	
	return self;
	
}

/******************************************************************
 *
 *  Inputs  : NSString - a string that is a URL to ask Bing to search
 *                      allrecipes.com for recipes with various ingredients
 *
 *  Purpose : This method uses an NSURLConnection to get search results
 *            from Bing.  Bing searches allrecipes.com for recipes with
 *            various ingredients.  A Regular Expression is then used
 *            to strip out the URLs for thos recipes.  Those URLs are
 *            stored in the recipeURLs instance variable.
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) findRecipes:(NSString *) searchString
{
    // A pointer to the HTML returned by Bing when we do the
    // search encapsulated in searchString
    NSString * bingPage;
    // An error object populated by the RE evaluation if a problem
    // is encountered
	NSError * error;
    // The RE that finds the various pages from the search results
    NSRegularExpression * pageRegex = [NSRegularExpression 
                                       regularExpressionWithPattern:@"<a href=\"(/search[^\"]*)\"[^>]*>\\d</a>" 
                                       options:NSRegularExpressionDotMatchesLineSeparators 
                                       error:&error];
    // The RE that will find the links to the recipes we want
	NSRegularExpression * recipeRegex = [NSRegularExpression 
                                         regularExpressionWithPattern:@"<a href=\"(http://allrecipes.com/[Rr]ecipe/[^/]*/).*?\"" 
                                         options:NSRegularExpressionDotMatchesLineSeparators 
                                         error:&error];
    // A pointer that will temporarily hold the results of the RE evaluation
    NSArray * tempArray;
    NSMutableArray * tempArray2 = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    NSMutableArray * itemsToDiscard = [[[NSMutableArray alloc] initWithCapacity:1] autorelease];
    NSMutableString * tempString = [[[NSMutableString alloc] initWithCapacity:1] autorelease];
    NSURL * tempURL = [NSURL URLWithString:searchString]; 
    int i = 0, rndIndex;
    NSString * tempURL2;
    NSTextCheckingResult * tempResult;
    NSRange tempRange;
    
    srandom(time(NULL));
    
    // Make sure the list of recipeURLs is empty
    [self.recipeURLs removeAllObjects];
   
	// Create a HTTP request based on the searchString
	NSMutableURLRequest * theRequest = [NSMutableURLRequest requestWithURL: tempURL
                                                            cachePolicy:NSURLRequestUseProtocolCachePolicy
                                                            timeoutInterval:60.0];
        
	
	// Simultaneously make the searchString request and get back the HTML from Bing
	bingPage =[[[NSString alloc] initWithData: [NSURLConnection sendSynchronousRequest: theRequest 
                                                                returningResponse: nil 
                                                                error: &error]
                                  encoding: NSASCIIStringEncoding] autorelease];
    
    if ([[NSThread currentThread] isCancelled]) {
        [NSThread exit];
    }
	
    //NSLog(@"bing page %@.", bingPage);
    tempArray = [pageRegex matchesInString:bingPage 
                           options:NSMatchingWithTransparentBounds 
                           range:NSMakeRange(0, [bingPage length])];
    
    // Get one of the pages of results if there is more than one.
    if ([tempArray count] != 0) 
    {
        rndIndex = random()%[tempArray count];
        if (rndIndex != 0) {
            tempResult = [tempArray objectAtIndex:rndIndex];
            tempRange = [tempResult rangeAtIndex:1];
            [tempString appendString:tempURL.host];
            [tempString appendString:[[bingPage substringWithRange:tempRange] stringByDecodingHTMLEntities]];
            [tempString insertString:@"http://" atIndex:0];
            
            tempURL = [NSURL URLWithString:tempString];
            theRequest = [NSMutableURLRequest requestWithURL:tempURL
                                              cachePolicy:NSURLRequestUseProtocolCachePolicy
                                              timeoutInterval:60.0];
            
            //[bingPage release];
            
            // Get a pointer to the array of allrecipes.com URLs that the Bing request returns
            bingPage =[[[NSString alloc] initWithData: [NSURLConnection sendSynchronousRequest: theRequest 
                                                                        returningResponse: nil 
                                                                        error: &error]
                                         encoding: NSASCIIStringEncoding] autorelease];
        }
        
        // Get the array of recipe URLs
        tempArray = [recipeRegex matchesInString:bingPage 
                                 options:NSMatchingWithTransparentBounds 
                                 range:NSMakeRange(0, [bingPage length])];
        
        // Get all the URLs we've found
        for (NSTextCheckingResult * tempResult in tempArray) 
        {
            tempRange = [tempResult rangeAtIndex:1];
            [tempArray2 addObject:[bingPage substringWithRange:tempRange]];
        }
        
        i= 0;
        
        // Make sure there are no duplicates
        for (NSString * tempURL in tempArray2) 
        {
            if (i < [tempArray count]-1) 
            {
                i++;
            } else {
                break;
            }
            tempURL2 = [tempArray2 objectAtIndex:i];
            if ([[tempURL lowercaseString] isEqualToString:[tempURL2 lowercaseString]]) {
                [itemsToDiscard addObject:tempURL2];
            }
        }
        [tempArray2 removeObjectsInArray:itemsToDiscard];
        
        // Store the URLs in the recipeURLs instance variable.
        for (NSString * url in tempArray2) 
        {
            [self.recipeURLs addObject:[url stringByAppendingString:@"Detail.aspx"]];
            //[self.recipeURLs addObject:url];
            //[url autorelease];
        }
        
    }   
    [itemsToDiscard removeAllObjects];
    [tempArray2 removeAllObjects];
}


/******************************************************************
 *
 *  Inputs  : None
 *
 *  Purpose : If we've done everything correctly, this should
 *            set the retain count for the instance variables to
 *            0 so the runtime environment can reclaim memory.
 *
 *  Outputs : None
 *
 ******************************************************************/
-(void) dealloc
{
	[super dealloc];
    
    if (recipeURLs) {
        [recipeURLs release];
    }
	
}

@end
