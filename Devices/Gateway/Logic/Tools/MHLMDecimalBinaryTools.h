//
//  MHLMDecimalBinaryTools.h
//  MiHome
//
//  Created by ayanami on 16/7/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLMDecimalBinaryTools : NSObject

+ (NSString *)binaryToDecimal:(NSString *)binary;
+ (NSString *)decimalToHex:(long)decimal;
+ (NSString *)hexToBinary:(NSString *)hex;

+ (NSString *)binarytoDecimal:(NSString *)binary;
+ (NSString *)decimalToBinary:(int)tmpid backLength:(int)length;

@end
