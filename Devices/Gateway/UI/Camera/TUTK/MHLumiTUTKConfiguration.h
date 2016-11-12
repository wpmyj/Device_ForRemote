//
//  MHLumiTUTKConfiguration.h
//  MiHome
//
//  Created by LM21Mac002 on 16/9/20.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface MHLumiTUTKConfiguration : NSObject
+ (MHLumiTUTKConfiguration *)defaultConfiguration;
@property (nonatomic, assign) int nMaxChannelNum;                   //3
@property (nonatomic, copy) NSString *udid;                         //nil
@property (nonatomic, copy) NSString *account;                      //admin
@property (nonatomic, copy) NSString *password;                     //888888
@property (nonatomic, assign) unsigned int nTimeout;                //2000 (毫秒)
@property (nonatomic, assign) unsigned int nLaunchServeTimeout;     //5(秒)
@end
