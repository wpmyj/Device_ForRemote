//
//  MHLumiAlarmVideoDownloadUnit.m
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/23.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiAlarmVideoDownloadUnit.h"

@interface MHLumiAlarmVideoDownloadUnit()
@end

@implementation MHLumiAlarmVideoDownloadUnit
- (instancetype)initWithDic:(NSDictionary *)dic
{
    self = [super init];
    if (self) {
        if ([dic[@"uid"] isKindOfClass:[NSString class]]){
            _uid = dic[@"uid"];
        }
        if ([dic[@"did"] isKindOfClass:[NSString class]]){
            _did = dic[@"did"];
        }
        if ([dic[@"type"] isKindOfClass:[NSString class]]){
            _type = dic[@"type"];
        }
        if ([dic[@"key"] isKindOfClass:[NSString class]]){
            _key = dic[@"key"];
        }
        _videoDuration = 0;
        _fileName = nil;
        if ([dic[@"value"] isKindOfClass:[NSString class]]){
            NSData *jsonData = [dic[@"value"] dataUsingEncoding:NSUTF8StringEncoding];
            NSError *err;
            NSArray <NSDictionary *> *dics = [NSJSONSerialization JSONObjectWithData:jsonData
                                                                options:NSJSONReadingMutableContainers
                                                                  error:&err];
            if(err || ![dics isKindOfClass:[NSArray class]]) {
                NSLog(@"MHLumiAlarmVideoDownloadUnit json解析失败：%@",err);
            }else{
                if ([dics.firstObject isKindOfClass:[NSDictionary class]]) {
                    NSDictionary *todoDic = dics.firstObject;
                    NSLog(@"%@",todoDic);
                    _fileName = todoDic[@"video_name"];
                    _videoDuration = [todoDic[@"video_len"] integerValue];
                }
            }
        }
        _time = [dic[@"time"] integerValue];
    }
    return self;
}

- (NSString *)suffix{
    if (_fileName){
       return [_fileName pathExtension];
    }
    return nil;
}

@end
