//
//  MHLumiIFTTTHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiIFTTTHelper.h"
#import "MHIFTTTManager.h"
@implementation MHLumiIFTTTHelper

//无线开关的单击trigerId： 4
//网关的警戒切换actionId：138
//无线开关的双击trigerId： 19
//小米智能插座（zigBee版）开／关 actionId：184
+ (void)addCustomIFTTTAtDouble11WithGateway:(MHDeviceGatewayBase *)gateway
                                   actionId:(NSString *)actionId
                             subDeviceClass:(Class) subDeviceClass
                                   trigerId:(NSString *)trigerId
                                 customName:(NSString *)customName
                          completionHandler:(void (^)(bool flag))completionHandler{
    void (^gotSubDevices)(NSArray <MHDeviceGatewayBase *>*) = ^(NSArray <MHDeviceGatewayBase *>*subDevices){
        NSString *todoDid = nil;
        for (MHDeviceGatewayBase *subDevice in subDevices) {
            //应该后续不需要判断是否在线
            if ([subDevice isKindOfClass:subDeviceClass]){
                todoDid = subDevice.did;
                NSLog(@"%@",subDevice);
                break;
            }
        }
        if (todoDid == nil){
            completionHandler(NO);
            return;
        }
        
        [[MHIFTTTManager sharedInstance] getTemplateCompletion:^(NSInteger errorCode){
            NSLog(@"get scene template complete");
            MHDataIFTTTRecord *record = [MHDataIFTTTRecord new];
            MHDataIFTTTTrigger *todoTriger = nil;
            MHDataIFTTTAction *todoAction = nil;
            NSArray <MHDataIFTTTTrigger *> *triggers = ((MHDataDeviceIFTTTTemplate *)[[MHIFTTTManager sharedInstance] triggerTemplatesForQualifiedDid:todoDid].firstObject).triggers;
            for (MHDataIFTTTTrigger *triger in triggers) {
                if ([triger.triggerId isEqualToString:trigerId]){
                    todoTriger = triger;
                    break;
                }
            }
            NSLog(@"todoTriger %@",todoTriger.name);
            NSArray <MHDataIFTTTAction *> *actions = ((MHDataDeviceIFTTTTemplate *)[[MHIFTTTManager sharedInstance] actionTemplatesForQualifiedDid:gateway.did].firstObject).actions;
            for (MHDataIFTTTAction *action in actions) {
                if ([action.actionId isEqualToString:actionId]){
                    todoAction = action;
                    break;
                }
            }
            NSLog(@"actions %@",todoAction.actionId);
            record.triggers = [NSArray arrayWithObject:triggers.firstObject];
            record.actions = [NSArray arrayWithObject:actions[2]];
            record.name = customName == nil ? [record defaultName] : customName;
            NSLog(@"%@",record.name);
            [[MHIFTTTManager sharedInstance] editRecord:record success:^{
                [[MHIFTTTManager sharedInstance].recordList addObject:record];
                completionHandler(YES);
            } failure:^(NSInteger flag) {
                completionHandler(NO);
            }];

        }];
    };
    
    if (gateway.subDevices.count <= 0) {
        [gateway getSubDeviceListWithSuccess:^(id obj) {
            NSArray <MHDataDevice *>* dataDevices = obj;
            NSMutableArray <MHDeviceGatewayBase *>* subDevices = [NSMutableArray array];
            for (MHDataDevice *dataDevice in dataDevices) {
                MHDeviceGatewayBase *subDevice = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:dataDevice.model dataDevice:dataDevice];
                [subDevices addObject:subDevice];
            }
            gotSubDevices(subDevices);
        } failuer:^(NSError *error) {
            completionHandler(NO);
        }];
    }else{
        gotSubDevices(gateway.subDevices);
    }
}

@end
