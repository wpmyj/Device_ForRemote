//
//  MHACPartnerAddSucceedViewController.h
//  MiHome
//
//  Created by ayanami on 16/5/22.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceAcpartner.h"

typedef enum : NSInteger {
    ADD_SUCCESS_INDEX,//成功
    ADD_AUTO_FAILURE_INDEX,//自动匹配失败
    ADD_OTHER_FAILURE_INDEX,//非自动失败
    UPLOAD_INDEX,//上传
} ACPARTNER_SUCCEED_TYPE;

@interface MHACPartnerAddSucceedViewController : MHLuViewController

- (id)initWithAcpartner:(MHDeviceAcpartner *)acpartner successType:(ACPARTNER_SUCCEED_TYPE)type;

@end
