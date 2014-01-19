//
//  AllRecipesProxy.h
//  FullPlate
//
//  Created by Jason Mazzotta on 5/22/10.
//  Copyright 2010 Full Plate Productions. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "SettingsManager.h"
#import "NSString+HTML.h"

/***********************************************************************
 *
 * This class is responsible for taking the URL created by the 
 * RecipeRequestConstructor, passing it to Bing and parsing out the URL 
 * for the AllRecipesManager to parse into ingredients.  Using Bing instead 
 * of Google, because I can't achieve the results I want with Google.
 *
 *************************************************************************/
@interface BingProxy : NSObject 
{
    // The array of URLs for recipes that we've found 
    // from the recipe request
	NSMutableArray * recipeURLs;
    
}

// A property to allow us to easily access the
// recipeURLs from outside this class
@property (retain) NSMutableArray * recipeURLs;

// The "constructor" for this class
-(BingProxy *) init;

// Find recipes that BING returns using searchString
// as a search request.
-(void) findRecipes:(NSString *) searchString;

// The "destructor" for this class
-(void) dealloc;

@end
