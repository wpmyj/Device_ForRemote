//
//  MHGatewayUserDefineDataResponse.h
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayUserDefineDataResponse : MHBaseResponse

@property (nonatomic,strong) NSMutableArray *valueList;

+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring;

@end
