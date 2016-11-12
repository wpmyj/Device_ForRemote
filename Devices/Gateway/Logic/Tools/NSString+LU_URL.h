//
//  NSString+URL.h
//  MiHome
//
//  Created by Lynn on 11/2/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface NSString (LU_URL)

- (NSString *)gw_URLEncodedString;
- (NSString *)gw_DecodeURLFromPercentEscapeString;

@end
