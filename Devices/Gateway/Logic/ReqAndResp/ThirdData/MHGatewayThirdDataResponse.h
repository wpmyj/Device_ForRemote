//
//  MHGatewayMusicResponse.h
//  MiHome
//
//  Created by Lynn on 8/31/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayThirdDataResponse : MHBaseResponse

@property (nonatomic,strong) NSMutableArray *valueList;

+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring;

@end
