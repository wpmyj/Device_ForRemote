//
//  MHGatewayHtDataRequest.h
//  MiHome
//
//  Created by ayanami on 16/8/10.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayHtDataRequest : MHBaseRequest

@property (nonatomic, copy) NSString* did;
@property (nonatomic, assign) NSTimeInterval timeStart;
@property (nonatomic, assign) NSTimeInterval timeEnd;
@property (nonatomic, copy) NSString* type;
@property (nonatomic, copy) NSString* key;
@property (nonatomic, copy) NSString* group;


@end
