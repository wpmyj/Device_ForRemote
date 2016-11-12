//
//  GatewayZipTools.h
//  MiHome
//
//  Created by Lynn on 8/31/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface GatewayZipTools : NSObject

+ (NSData *)uncompressZippedData:(NSData *)compressedData;

+ (NSData *)gzipData:(NSData *)pUncompressedData ;

@end
