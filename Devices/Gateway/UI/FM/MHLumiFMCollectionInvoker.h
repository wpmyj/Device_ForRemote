//
//  MHLumiFMCollectionInvoker.h
//  MiHome
//
//  Created by Lynn on 11/26/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import "MHDeviceGateway.h"
#import "MHLumiXMDataManager.h"

@interface MHLumiFMCollectionInvoker : NSObject

@property (nonatomic,strong) MHDeviceGateway *radioDevice;

- (void)addElementToCollection:(MHLumiXMRadio *)radio
                   WithSuccess:(void (^)(id obj))success
                    andFailure:(void (^)(NSError *error))failure;

- (void)removeElementFromCollection:(MHLumiXMRadio *)radio 
                        WithSuccess:(void (^)(id obj))success
                         andFailure:(void (^)(NSError *error))failure;

- (void)fetchCollectionListWithSuccess:(void (^)(NSMutableArray *datalist))success
                            andFailure:(void (^)(NSError *error))failure;

- (void)mainPageFetchCollectionListWithSuccess:(void (^)(NSMutableArray *datalist))success
                            andFailure:(void (^)(NSError *error))failure;

//不带提醒的
- (void)loadlistDataWithSuccess:(void (^)(NSMutableArray *datalist))success
                     andFailure:(void (^)(NSError *error))failure ;

//带提醒的
- (void)loadSpinningWithSuccess:(void (^)(NSMutableArray *datalist))success
                     andFailure:(void (^)(NSError *error))failure;
@end
