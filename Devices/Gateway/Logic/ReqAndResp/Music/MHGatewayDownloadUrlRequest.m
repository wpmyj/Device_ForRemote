//
//  MHGatewayDownloadUrlRequest.m
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayDownloadUrlRequest.h"

@implementation MHGatewayDownloadUrlRequest

- (NSString *)api
{
    return @"/home/getfileurl";
}


//允许参数：
//
//data:{"did":"123456","time":1345555512} time为毫秒
//根据did和登陆uid，time计算出文件名，并返回下载地址
//
//或data:{"obj_name":"2015/05/04/123456/aaa123_123444993.log"}
//此obj_name必须满足指定的文件名格式
//根据格式中提取出的uid和did检查权限，如果有权限，才会返回下载地址
- (id)jsonObject
{
    //1 一般用这种
    if (self.fileName){
        NSDictionary *json = @{@"obj_name":self.fileName};
        return json;
    }
    
    //2 时间戳有精确到秒和毫秒。这里要求是毫秒的
    NSMutableDictionary *json = [NSMutableDictionary dictionary];
    if (self.did){
        json[@"did"] = self.did;
    }
    if (self.uid){
        json[@"uid"] = self.uid;
    }
    if (self.suffix){
        json[@"suffix"] = self.suffix;
    }
    if (self.time){
        json[@"time"] = @(self.time);
    }
    return json;
}

- (NSString *)fetchFileName{
    return @"";
}

@end