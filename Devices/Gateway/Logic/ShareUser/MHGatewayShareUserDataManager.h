//
//  MHGatewayShareUserDataManager.h
//  MiHome
//
//  Created by guhao on 4/18/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"

@interface MHGatewayShareUserDataManager : NSObject
+ (id)sharedInstance;

/**
 *  获取被分享用户的列表
 *
 *  @param did     网关did
 *  @param success 被分享用户的数组,数组元素为空则网关未被分享,否则被分享
 *  @param failure failure
 */
/**
 *  @brief 数组不为空时,元素结构
 *           {"userid":123,  //用户id
 *           "nickname":"abc",  // 用户名
 *           "status":1,  // 分享状态，1表示已接受，否则表示待处理
 *           "icon":"http://....", // 头像url
 *           "sharetime":11111} // 分享时间
 */
- (void)getShareUserListWithGatewayDid:(NSString *)did success:(SucceedBlock)success failure:(FailedBlock)failure;

@end
