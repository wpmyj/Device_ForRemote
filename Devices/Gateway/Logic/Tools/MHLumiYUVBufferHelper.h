//
//  MHLumiYUVBufferHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 16/10/3.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLumiYUVBufferHelper : NSObject
+ (NSData *)yuvBufferWithYData:(uint8_t **)data linesize:(int *)linesize frameWidth:(int)width frameHeight:(int)height;
- (instancetype)initWithPath:(NSString *)path;
- (BOOL)isReadToEnd;
- (NSData *)fetchYUVBufferData;
@end
