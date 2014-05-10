//
//  NSData+IDZGunzip.m
//  Full Plate
//
//  Created by Jason Mazzotta on 12/28/13.
//  Copyright (c) 2013 Full Plate Productions. All rights reserved.
//
//  Copied from http://iosdeveloperzone.com/2013/03/14/code-snippet-decompressing-a-gzipped-buffer/
//

#import "NSData+IDZGunzip.h"
#import <zlib.h>

NSString* const IDZGunzipErrorDomain = @"com.iosdeveloperzone.IDZGunzip";

@implementation NSData (IDZGunzip)

- (NSData*)gunzip:(NSError *__autoreleasing *)error
{
    z_stream zStream;
    memset(&zStream, 0, sizeof(zStream));
    inflateInit2(&zStream, 16);
    
    UInt32 nUncompressedBytes = *(UInt32*)(self.bytes + self.length - 4);
    NSMutableData* gunzippedData = [NSMutableData dataWithLength:nUncompressedBytes];
    
    zStream.next_in = (Bytef*)self.bytes;
    zStream.avail_in = self.length;
    zStream.next_out = (Bytef*)gunzippedData.bytes;
    zStream.avail_out = gunzippedData.length;
    
    inflate(&zStream, Z_FINISH);
    
    inflateEnd(&zStream);
    
    return gunzippedData;
}

@end