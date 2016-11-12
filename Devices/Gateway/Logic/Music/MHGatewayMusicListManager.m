//
//  MHGatewayMusicListManager.m
//  MiHome
//
//  Created by Lynn on 8/17/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayMusicListManager.h"
#import "MHGatewayThirdDataRequest.h"
#import "MHGatewayThirdDataResponse.h"

@implementation MHGatewayMusicListManager

-(void)fetchMusicListWithPageIndex:(int)pageIndex success:(void (^)(id))success andfailure:(void (^)(NSError *))failure
{
    MHGatewayThirdDataRequest *req = [[MHGatewayThirdDataRequest alloc] init];
    req.pageIndex = [NSString stringWithFormat:@"%d", pageIndex];
    [[MHNetworkEngine sharedInstance] sendRequest:req success:^(id json) {
        MHGatewayThirdDataResponse *rsp = [MHGatewayThirdDataResponse responseWithJSONObject:json];
        NSLog(@"%@", rsp);
        NSLog(@"%@", rsp.valueList);
//        NSMutableArray *userPdata = rsp.valueList;
//        NSMutableDictionary *pageInfo = [userPdata lastObject];
//        NSMutableArray *valueList = [NSMutableArray arrayWithArray:[userPdata subarrayWithRange:NSMakeRange(0, userPdata.count - 1)]];
//        
//        int total = [[pageInfo valueForKey:@"total"] intValue];
//        int size = [[pageInfo valueForKey:@"size"] intValue];
//        
//        int keyForPageIndex = (total / size) + (BOOL)(total % size);
//        
//        NSLog(@"%ld",(long)keyForPageIndex);
        if(success)success(rsp.valueList);
        
    } failure:^(NSError *error) {
        if(failure)failure(error);
    }];

}

@end
