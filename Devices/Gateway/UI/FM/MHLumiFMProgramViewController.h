//
//  MHLumiFMViewController.h
//  MiHome
//
//  Created by Lynn on 11/16/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHLuViewController.h"
#import "MHDeviceGateway.h"
#import "MHLumiXMDataManager.h"

@interface MHLumiFMProgramViewController : MHLuViewController

@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MHLumiXMRadio *currentRadio;
@property (nonatomic, strong) void (^dataLoaded)(NSMutableArray *dataSource);

- (id)initWithFrame:(CGRect)frame andRadio:(MHLumiXMRadio *)radio;

@end
