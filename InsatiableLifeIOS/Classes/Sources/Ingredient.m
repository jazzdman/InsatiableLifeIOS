//
//  Ingredient.m
//  FullPlate
//
//  Created by Jason Mazzotta on 5/14/11.
//  Copyright 2011 Full Plate Productions. All rights reserved.
//

#import "Ingredient.h"


@implementation Ingredient

// Create the setters and getters for the properties
@synthesize number;
@synthesize quantity;
@synthesize name;
@synthesize inContainer;
@synthesize isPerishable;
@synthesize isLiquid;
@synthesize isBulk;
@synthesize isIndividual;
@synthesize needsPrep;
@synthesize color;

/***************************************************
 *
 * Inputs  : None
 *
 * Purpose : Set initial values for the member variables
 *           of an object of this class.
 *
 * Outputs : An initialized object of type GrocerieManager
 *
 ***************************************************/
-(id) init
{
    id tempItem;
    self = [super init];
    
    if (self) {
        self.number = 0.0f;
        
        tempItem = [[NSString alloc] initWithString:@""];
        self.quantity = tempItem;
        self.name = tempItem;
        [tempItem release];
        self.inContainer = NO;
        self.isPerishable = NO;
        self.isLiquid = NO;
        self.isBulk = NO;
        self.isIndividual = NO;
        self.needsPrep = NO;
        self.color = [UIColor blackColor];
    }
        
    return self;
}

/****************************************************
 *
 * Inputs  : NSZone - the memory zone in which we make the copy
 *
 * Purpose : Create a copy of an object
 *
 * Outputs : A copy of the object
 *
 ****************************************************/
- (id)copyWithZone:(NSZone *)zone 
{
    Ingredient * other = [[Ingredient allocWithZone:zone] init];
    other.number = self.number;
    other.quantity = self.quantity;
    other.name = self.name;
    other.inContainer = self.inContainer;
    other.isPerishable = self.isPerishable;
    other.isLiquid = self.isLiquid;
    other.isBulk = self.isBulk;
    other.isIndividual = self.isIndividual;
    other.needsPrep = self.needsPrep;
    other.color = self.color;
    
    return other;
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
-(void)dealloc
{
    [quantity release];
    
    [name release];
    
    [color release];
    
    [super dealloc];
}

@end
