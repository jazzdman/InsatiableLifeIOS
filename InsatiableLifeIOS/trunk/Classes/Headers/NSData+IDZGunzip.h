//
//  NSData+IDZGunzip.h
//  Full Plate
//
//  Created by Jason Mazzotta on 12/28/13.
//  Copyright (c) 2013 Full Plate Productions. All rights reserved.
//
//  Copied from http://iosdeveloperzone.com/2013/03/14/code-snippet-decompressing-a-gzipped-buffer/
//

#import <Foundation/Foundation.h>

extern NSString* const IDZGunzipErrorDomain;

@interface NSData (IDZGunzip)

- (NSData*)gunzip:(NSError**)error;

@end