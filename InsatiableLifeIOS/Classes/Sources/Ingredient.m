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
@synthesize number = _number;
@synthesize quantity = _quantity;
@synthesize name = _name;
@synthesize inContainer = _inContainer;
@synthesize isPerishable = _isPerishable;
@synthesize isLiquid = _isLiquid;
@synthesize isBulk = _isBulk;
@synthesize isIndividual = _isIndividual;
@synthesize needsPrep = _needsPrep;
@synthesize color = _color;

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
        _quantity = tempItem;
        [_quantity retain];
        _name = tempItem;
        [_name retain];
        _inContainer = NO;
        _isPerishable = NO;
        _isLiquid = NO;
        _isBulk = NO;
        _isIndividual = NO;
        _needsPrep = NO;
        _color = [UIColor blackColor];
        [_color retain];
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
    [_quantity release];
    
    [_name release];
    
    [_color release];
    
    [super dealloc];
}

@end
