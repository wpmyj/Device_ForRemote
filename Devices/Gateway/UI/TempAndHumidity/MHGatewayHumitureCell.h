//
//  MHGatewayHumitureCell.h
//  MiHome
//
//  Created by guhao on 15/12/31.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"

typedef void (^warmTextCallBack)(void);
@interface MHGatewayHumitureCell : MHTableViewCell

@property (nonatomic, strong) NSString *outerTemperature;
@property (nonatomic, strong) NSString *outerHumidity;
@property (nonatomic, assign) float temperature;
@property (nonatomic, assign) float humidity;
@property (nonatomic, strong) NSString *outterCity;
@property (nonatomic, strong) NSString *lastTime;
@property (nonatomic, strong) warmTextCallBack cozyClickCallBack;
@property (nonatomic, strong) warmTextCallBack loglistClickCallBack;

- (void)refreshUI;
//- (NSString *)getHTStautsWithTemperature:(float)temperature humidity:(float)humidity;

@end
