//
//  MHGatewayUserDefineDataResponse.h
//  MiHome
//
//  Created by Lynn on 10/28/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGatewayGetZipPDataResponse : MHBaseResponse

@property (nonatomic,strong) NSMutableArray *valueList;
@property (nonatomic,strong) NSString *timeStamp;

+ (instancetype)responseWithJSONObject:(id)object andKeystring:(NSString *)keystring;

@end
