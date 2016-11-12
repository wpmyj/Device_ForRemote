//
//  MHLumiFMCollectionInvoker.m
//  MiHome
//
//  Created by Lynn on 11/26/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLumiFMCollectionInvoker.h"

@implementation MHLumiFMCollectionInvoker

- (void)addElementToCollection:(MHLumiXMRadio *)radio
                   WithSuccess:(void (^)(id obj))success
                               andFailure:(void (^)(NSError *error))failure {

    __block void (^pdataSuccessBlock)(NSMutableArray *newArray);
    //1，向配置表添加收藏纪录，用户配置信息表的存储设备 ＝＝ 多台设备收藏表之和,通过deviceDid做分页
    [[MHLumiXMDataManager sharedInstance] setCollectionRadio:radio
                                               withDeviceDid:self.radioDevice.did
                                               andActionType:@"add"
                                                 WithSuccess:^(id obj){
                                                     pdataSuccessBlock(obj);
                                                     
                                                 } andFailure:^(NSError *error) {
                                                     if(error.code == 1001)
                                                        [[MHTipsView shareInstance]  showTipsInfo:NSLocalizedStringFromTable(@"mydevice.gateway.setting.xmfm.device.limited", @"plugin_gateway", nil) duration:1.5f modal:YES];
                                                     if(failure)failure(error);
                                                 }];
    
    //2，向设备添加收藏（设备存量目前不能大于20个电台），RPC方法
    XM_WS(weakself);
    pdataSuccessBlock = ^(NSMutableArray *newArray){
        
        [weakself.radioDevice setGatewayFMCollection:newArray withSuccess:^(id obj) {
            NSLog(@"%@",obj);
            
        } andFailure:^(NSError *error) {
            
        }];
        
        //3，向本地缓存收藏列表
        [[MHLumiXMDataManager sharedInstance] saveCollectedRadioDeviceDid:self.radioDevice.did
                                                             withDataList:newArray];
    };
}

- (void)removeElementFromCollection:(MHLumiXMRadio *)radio
                        WithSuccess:(void (^)(id obj))success
                         andFailure:(void (^)(NSError *error))failure {
    
    __block void (^getNewArraySuccess)(NSMutableArray *newArray);
    
    //1，设置Pdata
    [[MHLumiXMDataManager sharedInstance] setCollectionRadio:radio
                                               withDeviceDid:self.radioDevice.did
                                               andActionType:@"remove"
                                                 WithSuccess:^(id obj){
                                                     getNewArraySuccess(obj);
                                                     
                                                 } andFailure:^(NSError *error){
                                                     if(failure)failure(error);
                                                 }];
    
    //2，设置设备收藏表
    XM_WS(weakself);
    getNewArraySuccess = ^(NSMutableArray *newArray){
        NSLog(@"%@",newArray);
        [weakself.radioDevice setGatewayFMCollection:newArray withSuccess:^(id obj) {
            NSLog(@"%@",obj);
            
        } andFailure:^(NSError *error) {
            
        }];
    };
}

- (void)fetchCollectionListWithSuccess:(void (^)(NSMutableArray *datalist))success
                            andFailure:(void (^)(NSError *error))failure {
    //1，获取缓存的列表
    XM_WS(weakself);
    __block void (^restoreListSuccess)();
    [[MHLumiXMDataManager sharedInstance]
     restoreCollectionRadioDeviceDid:self.radioDevice.did
     withFinish:^(NSMutableArray *datalist){
         if(datalist.count) {
             if(success)success(datalist);
             restoreListSuccess();
         }
         else{
             [weakself loadSpinningWithSuccess:^(NSMutableArray *datalist){
                 if(success)success(datalist);
             } andFailure:^(NSError *error){
                 if(failure)failure(error);
             }];
         }
     }];
    
    //2，再偷偷在后台加载Pdata数据，以Pdata数据为准，重新RPC设置设备列表
    restoreListSuccess = ^(){
        [weakself loadlistDataWithSuccess:^(NSMutableArray *datalist){
            
            //更新网关数据
            [weakself.radioDevice setGatewayFMCollection:datalist withSuccess:^(id obj) {
                NSLog(@"%@",obj);

            } andFailure:^(NSError *v) {
                
            }];
            
            if(success)success(datalist);
            
        } andFailure:nil];
    };
}

- (void)mainPageFetchCollectionListWithSuccess:(void (^)(NSMutableArray *datalist))success
                                    andFailure:(void (^)(NSError *error))failure {
    //1，获取缓存的列表
    XM_WS(weakself);
    __block void (^restoreListSuccess)();
    [[MHLumiXMDataManager sharedInstance]
     restoreCollectionRadioDeviceDid:self.radioDevice.did
     withFinish:^(NSMutableArray *datalist){
         if(datalist.count) {
             if(success)success(datalist);
             restoreListSuccess();
         }
         else{
             [weakself loadlistDataWithSuccess:^(NSMutableArray *datalist){
            if(success)success(datalist);
                 
             } andFailure:nil];
         }
     }];
    
    //2，再偷偷在后台加载Pdata数据，以Pdata数据为准，重新RPC设置设备列表
    restoreListSuccess = ^(){
        [weakself loadlistDataWithSuccess:^(NSMutableArray *datalist){
            
            //更新网关数据
            [weakself.radioDevice setGatewayFMCollection:datalist withSuccess:^(id obj) {
                NSLog(@"%@",obj);
                
            } andFailure:^(NSError *v) {
                
            }];
            if(success)success(datalist);
            
        } andFailure:nil];
    };

}
//偷偷加载数据用的
- (void)loadlistDataWithSuccess:(void (^)(NSMutableArray *datalist))success
                     andFailure:(void (^)(NSError *error))failure {
    [[MHLumiXMDataManager sharedInstance]
     fetchCollectionRadioWithDeviceDid:self.radioDevice.did
     WithSuccess:^(NSMutableArray *datalist){
         if(success)success(datalist);
        
     } andFailure:^(NSError *error){
         if(failure)failure(error);
     }];
}

//带提醒的加载数据用的
- (void)loadSpinningWithSuccess:(void (^)(NSMutableArray *datalist))success
                         andFailure:(void (^)(NSError *error))failure {
    [[MHTipsView shareInstance] showTips:NSLocalizedStringFromTable(@"updating", @"plugin_gateway", nil) modal:YES];
    [self loadlistDataWithSuccess:^(NSMutableArray *datalist){
        [[MHTipsView shareInstance] hide];
        if(success)success(datalist);
        
    } andFailure:^(NSError *error){
        [[MHTipsView shareInstance] hide];
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"busy", @"plugin_gateway", nil) duration:1.5f modal:YES];
    }];
}

@end
