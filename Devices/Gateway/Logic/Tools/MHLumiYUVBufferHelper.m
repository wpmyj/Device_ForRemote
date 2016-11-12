//
//  MHLumiYUVBufferHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/3.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHLumiYUVBufferHelper.h"
#import <string.h>
@implementation MHLumiYUVBufferHelper
+ (NSData *)yuvBufferWithYData:(uint8_t **)data linesize:(int *)linesize frameWidth:(int)width frameHeight:(int)height{
    
    int picSize = width * height;
    int newSize = picSize * 1.5;
    unsigned char *buf = (unsigned char *)malloc(newSize);
    memset(buf, 0, newSize);
    int a=0,j;
    for (j=0; j<height; j++){
        memcpy(buf+a,data[0] + j * linesize[0], width);
        a+=width;
    }
    for (j=0; j<height/2; j++){
        memcpy(buf+a,data[1] + j * linesize[1], width/2);
        a+=width/2;
    }
    for (j=0; j<height/2; j++)
    {
        memcpy(buf+a,data[2] + j * linesize[2], width/2);
        a+=width/2;
    }
    NSData *todoData = [[NSData alloc] initWithBytes:buf length:newSize];
    free(buf);
    return todoData;
}

@end
