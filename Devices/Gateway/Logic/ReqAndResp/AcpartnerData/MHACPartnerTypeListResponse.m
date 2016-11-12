//
//  MHACPartnerTypeListResponse.m
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerTypeListResponse.h"
#import "Base64.h"
#import "GatewayZipTools.h"
#import "MHACTypeModel.h"

@implementation MHACPartnerTypeListResponse

+ (instancetype)responseWithJSONObject:(id)object {
    MHACPartnerTypeListResponse *response = [[self alloc] init];
    
    response.code = [[object objectForKey:@"code"] integerValue];
    response.message = [object objectForKey:@"msg"];
    if([[object objectForKey:@"result"] isKindOfClass:[NSString class]] && response.code == 200){
        NSString *codeString = [object valueForKey:@"result"];
        NSData *codeData = [codeString dataUsingEncoding:NSUTF8StringEncoding];
        NSData *decodeData = [Base64 decodeData:codeData];
        NSData *upZipData = [GatewayZipTools uncompressZippedData:decodeData];
        
        /*
         {"recommend":[{"name":"格力", "eng_name":"Gred", "brand_id":97, number:25},{},{}...],"all":[{"name":"格力", "eng_name":"Gred", "brand_id":97, number:25},{},{}...]}
         */
        
        if(upZipData){
            MHSafeDictionary *recommends = [NSJSONSerialization JSONObjectWithData:upZipData
                                                                           options:NSJSONReadingMutableLeaves
                                                                             error:nil];
//            NSLog(@"%@", recommends);
            //recommend
            if ([recommends[@"all"] isKindOfClass:[NSArray class]]) {
                NSLog(@"%@", recommends[@"all"]);
                NSArray *allArray = recommends[@"all"];
                NSArray *recommendArray = recommends[@"recommend"];
                NSMutableArray *all = [NSMutableArray new];
                NSMutableArray *recommend = [NSMutableArray new];
                [allArray enumerateObjectsUsingBlock:^(NSDictionary *allDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    [all addObject:[MHACTypeModel instanceWithJSONObject:allDic]];
                }];
                [recommendArray enumerateObjectsUsingBlock:^(NSDictionary *recomDic, NSUInteger idx, BOOL * _Nonnull stop) {
                    [recommend addObject:[MHACTypeModel instanceWithJSONObject:recomDic]];
                }];
                
                
                NSLog(@"%@", all);
                

                response.typeList = @[ recommend, all];
            }
            else {
                response.typeList = [NSMutableArray new];
            }
        }
    }
    return response;

}
@end
