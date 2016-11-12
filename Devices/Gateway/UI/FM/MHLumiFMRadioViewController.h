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
#import "MHLumiFmPlayer.h"
#import "MHTableViewControllerInternal.h"

typedef enum{
    Radio_Country,
    Radio_Province,
    Radio_NetWork,
    Radio_Rank,
} RadioType;

@interface MHLumiFMRadioViewController : MHLuViewController

@property (nonatomic, assign) RadioType radioType;
@property (nonatomic, strong) MKPlacemark *currentPlace;
@property (nonatomic, strong) NSString *provinceCode;
@property (nonatomic, strong) void (^radioSelected)(MHLumiXMRadio *radio);
@property (nonatomic, assign) CGRect viewFrame;
@property (nonatomic, strong) NSMutableArray *dataSource;
@property (nonatomic, strong) MHTableViewControllerInternal* tvcInternal;

@property (nonatomic, strong) MHLumiFmPlayer *fmPlayer;

- (id)initWithFrame:(CGRect)frame andRadioDevice:(MHDeviceGateway *)radioDevice;

- (void)hideAllCellAnimation;
- (void)showAnimation:(MHLumiXMRadio *)currentRadio;

@end
