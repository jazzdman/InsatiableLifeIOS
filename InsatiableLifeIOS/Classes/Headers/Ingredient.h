//
//  Ingredient.h
//  FullPlate
//
//  Created by Jason Mazzotta on 5/14/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

// Constants used to convert between volumes and 
// weights
#define TBSP_PER_CUP 16.0f
#define TBSP_PER_PINT TBSP_PER_CUP*2.0f
#define TBSP_PER_QUART TBSP_PER_CUP*4.0f
#define TBSP_PER_GALLON TBSP_PER_QUART*4.0f
#define TBSP_PER_TSP 0.333f
#define VOLUME_OUNCE_PER_TABLESPOON 0.5f
#define OZ_PER_POUND 16

#import <Foundation/Foundation.h>

/****************************************************
 *
 * This is part of the Model for both the Grocery and
 * Pantry views.  It helps to shape how the ingredients
 * are displayed in the Groceries view and whether
 * they should be displayed in the Pantry view.
 *
 ****************************************************/
@interface Ingredient : NSObject 
{
    // Assume that an ingredient is listed as something like
    //   2         cups      rice
    //(number)  (quantity)  (name)
    // Quantity and/or number might be empty
    float number;
    NSString * quantity;
    NSString * name;
    
    // Is this ingredient stored in a container?
    // Ingredients with a quantity of teaspoon, tablespoon or cup
    // might be in a container
    BOOL inContainer;
    
    // If this item is in a container, is it perishable (e.g. milk)?
    // If so, it won't go in the pantry.
    BOOL isPerishable;
    
    // If this item is in a container, is it a liquid (e.g oil)?
    BOOL isLiquid;
    
    // If this item is in a container, is it a bulk item (e.g flour)?
    BOOL isBulk;
    
    // If this item is in a container, are they used individually (e.g. a bay leaf)?
    BOOL isIndividual;
    
    // Does this item need preparation (e.g. chopped)?  Then, it can't be in a container.
    BOOL needsPrep;
    
    // The color of an ingredient, which denotes whether it has been selected or not.
    UIColor * color;
}

// Properties to wrap the member variables so 
// that we can easily access them outside this class.
@property float number;
@property (copy) NSString * quantity;
@property (copy) NSString * name;
@property BOOL inContainer;
@property BOOL isPerishable;
@property BOOL isLiquid;
@property BOOL isBulk;
@property BOOL isIndividual;
@property BOOL needsPrep;
@property (retain) UIColor * color;

// The constructor/initializer for this class
-(id)init;

// The destructor for this class
-(void)dealloc;

@end
