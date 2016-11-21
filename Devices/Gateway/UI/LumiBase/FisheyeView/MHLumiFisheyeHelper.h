//
//  MHLumiFisheyeHelper.h
//  MiHome
//
//  Created by LM21Mac002 on 2016/11/14.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHLumiFisheyeHeader.h"
//DewrapType:(FEDEWARPTYPE)dewrapType mountType:(FEMOUNTTYPE)mountType
@interface MHLumiFisheyeHelper : NSObject
+ (NSString *)nameFromDewrapType:(FEDEWARPTYPE) dewrapType;
+ (NSString *)nameFromMountType:(FEMOUNTTYPE) mountType;
+ (FEDEWARPTYPE)dewrapTypeFromString:(NSString *)string;
+ (FEMOUNTTYPE)mountTypeFromString:(NSString *)string;
@end
