//
//  MHGatewaySceneTplResponse.h
//  MiHome
//
//  Created by Lynn on 9/7/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewaySceneTplResponse : MHBaseResponse

@property (nonatomic,strong) NSMutableArray *ifList;
@property (nonatomic,strong) NSMutableArray *thenList;
@property (nonatomic,strong) NSMutableDictionary *ifThenDictionary;

@property (nonatomic,strong) void (^completionBlock)(NSMutableDictionary *);

@end
