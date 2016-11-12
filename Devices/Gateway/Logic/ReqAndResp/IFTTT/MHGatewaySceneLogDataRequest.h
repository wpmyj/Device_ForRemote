//
//  MHGatewaySceneLogDataRequest.h
//  MiHome
//
//  Created by guhao on 16/5/6.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewaySceneLogDataRequest : MHBaseRequest

@property (nonatomic, copy) NSArray *dids;
@property (nonatomic, assign) NSInteger timeStart;
@property (nonatomic, assign) NSInteger timeEnd;
@property (nonatomic, assign) NSInteger limit;
@property (nonatomic, assign) NSTimeInterval timestamp;


@end
