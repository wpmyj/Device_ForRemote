//
//  MHGatewayLogCell.m
//  MiHome
//
//  Created by Woody on 15/4/10.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayLogCell.h"
#import "MHDataGatewayLog.h"
#import "MHDeviceGateway.h"
#import "NSString+WeiboStringDrawing.h"
#import "MHOpenInMiHomeManager.h"
#import "MHDeviceListCache.h"

@interface MHGatewayLogCell () <UIActionSheetDelegate>

@end

@implementation MHGatewayLogCell {
    UIView*         _vSpLineUp;
    UIView*         _vSpLineDown;
    UIImageView*    _firstLogMarker;
    
    UIImageView*    _unselMarker;
    UILabel*        _labelLogDetail;
    
    //For fake log
    
    UILabel*        _labelDay;
    UILabel*        _labelMonth;
    UILabel*        _labelWeekday;
    MHDataGatewayLog*           _log;
    NSMutableArray *            _cameraList;
    NSString *                  _dateString;
}

//- (id)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
//    if (self = [super initWithStyle:style reuseIdentifier:reuseIdentifier]) {
//        [self buildSubviews];
//    }
//    return self;
//}

- (void)buildSubviewsWithLog:(MHDataGatewayLog* )log {
    _log = log;
    CGFloat spLineHeight = CGRectGetHeight(self.contentView.frame) / 2.0f;
    
    if (log.hasPrev) {
        _vSpLineUp = [[UIView alloc] initWithFrame:CGRectMake(40, 0, 0.5, spLineHeight)];
        _vSpLineUp.backgroundColor = [MHColorUtils colorWithRGB:0xdcdcdc];
        [self.contentView addSubview:_vSpLineUp];
    }
    if (log.hasNext) {
        _vSpLineDown = [[UIView alloc] initWithFrame:CGRectMake(40, spLineHeight, 0.5, spLineHeight)];
        _vSpLineDown.backgroundColor = [MHColorUtils colorWithRGB:0xdcdcdc];
        [self.contentView addSubview:_vSpLineDown];
    }
    
    _unselMarker = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 7, 7)];
    [_unselMarker setImage:[UIImage imageNamed:@"gateway_log_unsel"]];
    [_unselMarker setCenter:CGPointMake(40, spLineHeight)];
    [self.contentView addSubview:_unselMarker];
    
    if (log.isFirst) {
        MHDeviceGatewayBase *tmpSensor = [[MHDeviceGatewayBase alloc] init];
        _cameraList = [NSMutableArray arrayWithCapacity:1];
        MHDeviceListCache *deviceListCache = [[MHDeviceListCache alloc] init];
        NSArray *deviceList = [deviceListCache syncLoadAll];
        for (MHDevice *device in deviceList){
            NSString *deviceModel = [tmpSensor modelCutVersionCode:device.model];
            if([deviceModel isEqualToString:@"yunyicamera"]){
                [_cameraList addObject:device];
            }
        }
        
        _firstLogMarker = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 12, 12)];
        NSString *imageName = @"gateway_log_sel";
        if(_cameraList.count > 0){
            imageName = @"lumi_logcell_camera_icon";
            _firstLogMarker.frame = CGRectMake(0, 0, 30, 30);
        }
        [_firstLogMarker setImage:[UIImage imageNamed:imageName]];
        [_firstLogMarker setCenter:_unselMarker.center];
        [self.contentView addSubview:_firstLogMarker];
    }
    
    CGFloat logDetailX = 40 + 25;
    _labelLogDetail = [[UILabel alloc] initWithFrame:CGRectMake(logDetailX, 0, CGRectGetWidth(self.contentView.frame) - logDetailX - 20, CGRectGetHeight(self.contentView.frame))];
    _labelLogDetail.font = [UIFont systemFontOfSize:14];
    _labelLogDetail.textColor = [MHColorUtils colorWithRGB:0x333333];
    if (log.isFirst) _labelLogDetail.textColor = [UIColor colorWithRed:49.f/255 green:186.f/255 blue:164.f/255 alpha:1.f];
    [self.contentView addSubview:_labelLogDetail];
    
    UITapGestureRecognizer *tap = [[UITapGestureRecognizer alloc] initWithTarget:self action:@selector(tapGestureAction:)];
    tap.numberOfTapsRequired = 1;
    tap.numberOfTouchesRequired = 1;
    [self addGestureRecognizer:tap];
}

-(void)tapGestureAction:(id)sender{
    MHDeviceGatewayBase *tmpSensor = [[MHDeviceGatewayBase alloc] init];
    _cameraList = [NSMutableArray arrayWithCapacity:1];
    MHDeviceListCache *deviceListCache = [[MHDeviceListCache alloc] init];
    NSArray *deviceList = [deviceListCache syncLoadAll];
    for (MHDevice *device in deviceList){
        NSString *deviceModel = [tmpSensor modelCutVersionCode:device.model];
        if([deviceModel isEqualToString:@"yunyicamera"]){
            [_cameraList addObject:device];
        }
    }

    NSTimeInterval interval = [_log.time timeIntervalSince1970];
    _dateString = [NSString stringWithFormat:@"%.0f",interval];
    
    if(_cameraList.count == 1){
        [self openCamera:0];
    }
    else if(_cameraList.count > 1){
        UIActionSheet *action = [[UIActionSheet alloc]
                                 initWithTitle:NSLocalizedStringFromTable(@"mydevice.gateway.log.opencamera", @"plugin_gateway", nil)
                                                            delegate:self
                                 cancelButtonTitle:NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", nil)
                                              destructiveButtonTitle:nil
                                                   otherButtonTitles:nil];
        for(MHDevice *camera in _cameraList){
            [action addButtonWithTitle:camera.name];
        }
        [action showInView:self.superview];
    }
}

- (void)buildSubviewsForFakeLog {
    
    _labelDay = [[UILabel alloc] init];
    _labelDay.font = [UIFont systemFontOfSize:24];
    _labelDay.textColor = [MHColorUtils colorWithRGB:0x333333];
    _labelDay.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_labelDay];

    _labelMonth = [[UILabel alloc] init];
    _labelMonth.font = [UIFont systemFontOfSize:11];
    _labelMonth.textColor = [MHColorUtils colorWithRGB:0x999999];
    _labelMonth.textAlignment = NSTextAlignmentLeft;
    [self.contentView addSubview:_labelMonth];
    

    _labelWeekday = [[UILabel alloc] init];
    _labelWeekday.font = [UIFont systemFontOfSize:11];
    _labelWeekday.textColor = [MHColorUtils colorWithRGB:0x999999];
    _labelWeekday.textAlignment = NSTextAlignmentRight;
    [self.contentView addSubview:_labelWeekday];
}

- (void)configureWithDataObject:(id)object {
    for (UIView* view in [self.contentView subviews]) {
        [view removeFromSuperview];
    }
    
    MHDataGatewayLog* log = (MHDataGatewayLog*)object;
    if ([log.type isEqualToString:@"fake"]) {
        [self buildSubviewsForFakeLog];
        
        NSDateFormatter *dateFormat = [[NSDateFormatter alloc] init];
        [dateFormat setDateFormat:@"d"];
        _labelDay.text = [dateFormat stringFromDate:log.time];
        
        CGSize sizeDay = [_labelDay.text singleLineSizeWithFont:_labelDay.font];
        _labelDay.frame = CGRectMake(20, (CGRectGetHeight(self.contentView.frame) - sizeDay.height)/ 2.0f, sizeDay.width, sizeDay.height);
        
        [dateFormat setDateFormat:@"MMMM"];
        _labelMonth.text = [dateFormat stringFromDate:log.time];
        CGSize sizeMonth = [_labelMonth.text singleLineSizeWithFont:_labelMonth.font];
        CGFloat monthX = CGRectGetMaxX(_labelDay.frame) + 3;
        CGFloat monthY = CGRectGetMaxY(_labelDay.frame) - sizeMonth.height - 3;
        _labelMonth.frame = CGRectMake(monthX, monthY, sizeMonth.width, sizeMonth.height);
        
        [dateFormat setDateFormat:@"eeee"];
        _labelWeekday.text = [dateFormat stringFromDate:log.time];
        
        CGSize sizeWeekday = [_labelWeekday.text singleLineSizeWithFont:_labelWeekday.font];
        CGFloat weekdayX = CGRectGetWidth(self.contentView.frame) - sizeWeekday.width - 20;
        CGFloat weekdayY = CGRectGetMaxY(_labelMonth.frame) - sizeWeekday.height;
        _labelWeekday.frame = CGRectMake(weekdayX, weekdayY, sizeWeekday.width, sizeWeekday.height);
    } else {
        [self buildSubviewsWithLog:log];
        _labelLogDetail.text = [MHDeviceGateway getLogDetailString:log];
    }
}

#pragma mark - carmer
-(void)openCamera:(NSInteger)index
{
    MHDevice *camera = _cameraList[index];
    NSString* camOpenUrl = [NSString stringWithFormat:@"mihome://openCamera?did=%@&time=%@", camera.did,_dateString];
    [[MHOpenInMiHomeManager sharedInstance] handleOpenURLString:camOpenUrl];
}

#pragma mark - action sheet delegate
-(void)actionSheet:(UIActionSheet *)actionSheet clickedButtonAtIndex:(NSInteger)buttonIndex{
    if (buttonIndex != 0){
        [self openCamera:buttonIndex - 1];
    }
}

@end
