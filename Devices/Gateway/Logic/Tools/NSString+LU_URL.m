//
//  NSString+URL.m
//  MiHome
//
//  Created by Lynn on 11/2/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "NSString+LU_URL.h"

@implementation NSString (LU_URL)

- (NSString *)gw_URLEncodedString
{
    NSString *encodedString = (NSString *)
    CFBridgingRelease(CFURLCreateStringByAddingPercentEscapes(kCFAllocatorDefault,
                                            (CFStringRef)self,
                                            (CFStringRef)@"!$&'()*+,-./:;=?@_~%#[]",
                                            NULL,
                                            kCFStringEncodingUnicode));
    return encodedString;
}

- (NSString *)gw_DecodeURLFromPercentEscapeString
{
    NSMutableString *outputStr = [NSMutableString stringWithString:self];
    [outputStr replaceOccurrencesOfString:@" "
                               withString:@""
                                  options:NSLiteralSearch
                                    range:NSMakeRange(0, [outputStr length])];
    
    return [outputStr stringByReplacingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
}

@end
