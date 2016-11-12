//
//  MHDataGatewaySceneLogMessage.h
//  MiHome
//
//  Created by guhao on 16/5/17.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHDataGatewaySceneLogMessage : MHDataBase
@property (nonatomic, assign) BOOL devConState;
@property (nonatomic, assign) NSInteger error;//error:0 执行成功 error:-2 设备离线 error:-3 执行超时 error:0其他负值 异常错误
@property (nonatomic, copy) NSString* methodDesc;
@property (nonatomic, copy) NSString* targetDesc;
@property (nonatomic, copy) NSString *target;
@property (nonatomic, copy) NSString* note;
@property (nonatomic, assign) NSInteger t;    //0 rpc方法 1 push消息

@property (nonatomic, assign) BOOL isLast;     //是否是最后一条message
@property (nonatomic, weak) id history;

- (NSString* )errorDetail;
@end
