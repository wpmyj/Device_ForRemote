//
//  MHLumiIFTTTHelper.m
//  MiHome
//
//  Created by LM21Mac002 on 16/10/9.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLumiIFTTTHelper.h"
#import "MHIFTTTManager.h"
#import "MHDeviceGateway.h"
@implementation MHLumiIFTTTHelper

//无线开关的单击trigerId： 18
//网关的警戒切换actionId：138
//无线开关的双击trigerId： 19
//小米智能插座（zigBee版）开／关 actionId：184
+ (void)addCustomIFTTTAtDouble11WithGateway:(MHDeviceGatewayBase *)gateway
                                   actionId:(NSString *)actionId
                             subDeviceClass:(Class) subDeviceClass
                                   trigerId:(NSString *)trigerId
                                 customName:(NSString *)customName
                          completionHandler:(void (^)(bool flag))completionHandler{
    
    [MHLumiIFTTTHelper fetchGatewaySubDevices:gateway withCompletionHandler:^(NSArray<MHDeviceGatewayBase *> *subDevices) {
        if (subDevices == nil){
            completionHandler(NO);
            return;
        }
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
            NSLog(@"actions %@",todoAction.name);
            record.triggers = [NSArray arrayWithObject:todoTriger];
            record.actions = [NSArray arrayWithObject:todoAction];
            record.name = customName == nil ? [record defaultName] : customName;
            NSLog(@"%@",record.name);
            [[MHIFTTTManager sharedInstance] editRecord:record success:^{
                [[MHIFTTTManager sharedInstance].recordList addObject:record];
                completionHandler(YES);
            } failure:^(NSInteger flag) {
                completionHandler(NO);
            }];
        }];
    }];
}

+ (void)addCustomIFTTTAtDouble11WithGateway:(MHDeviceGatewayBase *)gateway
                                   actionId:(NSString *)actionId
                          actionDeviceClass:(Class) actionDeviceClass
                                   trigerId:(NSString *)trigerId
                          trigerDeviceClass:(Class) trigerDeviceClass
                                 customName:(NSString *)customName
                          completionHandler:(void (^)(bool flag))completionHandler{
    [MHLumiIFTTTHelper fetchGatewaySubDevices:gateway withCompletionHandler:^(NSArray<MHDeviceGatewayBase *> *subDevices) {
        if (subDevices == nil){
            completionHandler(NO);
            return;
        }
        NSString *actionDeviceDid = nil;
        NSString *trigerDeviceDid = nil;
        for (MHDeviceGatewayBase *subDevice in subDevices) {
            //应该后续不需要判断是否在线
            if ([subDevice isKindOfClass:actionDeviceClass]){
                actionDeviceDid = subDevice.did;
                NSLog(@"%@",subDevice);
            }
            if ([subDevice isKindOfClass:trigerDeviceClass]){
                trigerDeviceDid = subDevice.did;
                NSLog(@"%@",subDevice);
            }
        }
        if (actionDeviceDid == nil || trigerDeviceDid == nil){
            completionHandler(NO);
            return;
        }
        
        [[MHIFTTTManager sharedInstance] getTemplateCompletion:^(NSInteger errorCode){
            NSLog(@"get scene template complete");
            MHDataIFTTTRecord *record = [MHDataIFTTTRecord new];
            MHDataIFTTTTrigger *todoTriger = nil;
            MHDataIFTTTAction *todoAction = nil;
            NSArray <MHDataIFTTTTrigger *> *triggers = ((MHDataDeviceIFTTTTemplate *)[[MHIFTTTManager sharedInstance] triggerTemplatesForQualifiedDid:trigerDeviceDid].firstObject).triggers;
            for (MHDataIFTTTTrigger *triger in triggers) {
                NSLog(@"triggers: name-%@,id-%@",triger.name, triger.triggerId);
                if ([triger.triggerId isEqualToString:trigerId]){
                    todoTriger = triger;
                    break;
                }
            }
            NSLog(@"todoTriger %@",todoTriger.name);
            NSArray <MHDataIFTTTAction *> *actions = ((MHDataDeviceIFTTTTemplate *)[[MHIFTTTManager sharedInstance] actionTemplatesForQualifiedDid:actionDeviceDid].firstObject).actions;
            for (MHDataIFTTTAction *action in actions) {
                NSLog(@"actions: name-%@,id-%@",action.name, action.actionId);
                if ([action.actionId isEqualToString:actionId]){
                    todoAction = action;
                    break;
                }
            }
            NSLog(@"actions %@",todoAction.name);
            record.triggers = [NSArray arrayWithObject:todoTriger];
            record.actions = [NSArray arrayWithObject:todoAction];
            record.name = customName == nil ? [record defaultName] : customName;
            NSLog(@"%@",record.name);
            [[MHIFTTTManager sharedInstance] editRecord:record success:^{
                [[MHIFTTTManager sharedInstance].recordList addObject:record];
                completionHandler(YES);
            } failure:^(NSInteger flag) {
                completionHandler(NO);
            }];
        }];
    }];
    
}

#pragma mark - convenience func
+ (void)fetchGatewaySubDevices:(MHDeviceGatewayBase *)gateway withCompletionHandler:(void(^)(NSArray <MHDeviceGatewayBase *>*subDevices))completionHandler{
    if (gateway.subDevices.count <= 0) {
        [gateway getSubDeviceListWithSuccess:^(id obj) {
            NSArray <MHDataDevice *>* dataDevices = obj;
            NSMutableArray <MHDeviceGatewayBase *>* subDevices = [NSMutableArray array];
            for (MHDataDevice *dataDevice in dataDevices) {
                MHDeviceGatewayBase *subDevice = (MHDeviceGatewayBase *)[MHDevFactory deviceFromModelId:dataDevice.model dataDevice:dataDevice];
                [subDevices addObject:subDevice];
            }
            completionHandler(subDevices);
        } failuer:^(NSError *error) {
            completionHandler(nil);
        }];
    }else{
        completionHandler(gateway.subDevices);
    }
}

@end
