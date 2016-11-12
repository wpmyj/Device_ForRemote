//
//  MHGetSubDataResponse.h
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGetSubDataResponse : MHBaseResponse
@property (nonatomic, retain) NSArray* logs;
- (void)extraFilterForSmokeAndNatgasSensorWithDeviceModel:(NSString *)model;
@end
