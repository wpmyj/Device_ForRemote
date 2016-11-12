//
//  MHGatewayInfoFolderCell.m
//  MiHome
//
//  Created by Lynn on 2/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayInfoFolderCell.h"
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewaySensorHumiture.h"

#define TableViewCellHeight 60.f

@implementation MHGatewayInfoFolderCell
{
    UIImageView *           _accessoryImageView;
    UIImageView *           _icon;
    UILabel *               _nameLabel;
    UILabel *               _detailLabel;
    UIView *                _bottomeLine;
    UILabel *               _countLabel;
    
    NSArray *               _sensors;
    int                     _sensorCnt;
}

- (void)configureWithDataObject:(id)object {
    _folderInfo = object;
    _sensorCnt = [[_folderInfo valueForKey:@"count"] intValue];
    _sensors = [_folderInfo valueForKey:@"sensors"];
    if(_sensorCnt == 1) _canUnfold = NO;
    else _canUnfold = YES;
    
    UILongPressGestureRecognizer *longPress = [[UILongPressGestureRecognizer alloc] initWithTarget:self action:@selector(longPressed:)];
    longPress.minimumPressDuration = 1.3f;
    [self addGestureRecognizer:longPress];

    [self buildSubviews];
}

- (void)buildSubviews {
    self.backgroundColor = [UIColor whiteColor];
    
    if(!_bottomeLine){
        _bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, TableViewCellHeight - 1, WIN_WIDTH - 40.f, 0.7)];
        _bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
        [self addSubview:_bottomeLine];
    }
    
    if(!_icon){
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(20, 7, 45, 45)];
        [self addSubview:_icon];
    }
    MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[_sensors firstObject];
    if(!sensor.services.count && [sensor isKindOfClass:[MHDeviceGatewayBase class]]) [sensor buildServices];
    if(sensor.services.count) {
        if (_sensors.count > 1){
            _icon.image = [sensor getMainPageSensorIconWithService:nil];
        }
        else {
            _icon.image = [sensor getMainPageSensorIconWithService:sensor.services[0]];
        }
    }
    
    if(!_nameLabel){
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 20, 200, 20)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:15.f];
        _nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self addSubview:_nameLabel];
    }
    _nameLabel.text = [_folderInfo valueForKey:@"cellName"];
    
    if(!_accessoryImageView){
        _accessoryImageView = [[UIImageView alloc] initWithFrame:CGRectMake(WIN_WIDTH - 40, 25, 20, 10)];
        if(_sensorCnt == 1) _accessoryImageView.hidden = YES;
        [self addSubview:_accessoryImageView];
    }
    if(_shouldfold) _accessoryImageView.image = [UIImage imageNamed:@"gateway_up_arrow"];
    else _accessoryImageView.image = [UIImage imageNamed:@"gateway_down_arrow"];

    if(_sensorCnt != 1) {
        if(!_countLabel) {
            _countLabel = [[UILabel alloc] initWithFrame:CGRectMake(WIN_WIDTH - 95, 20, 50, 20)];
            _countLabel.textAlignment = NSTextAlignmentRight;
            _countLabel.font = [UIFont systemFontOfSize:13.f];
            _countLabel.textColor = [UIColor colorWithWhite:0.7 alpha:1.0];
            [self addSubview:_countLabel];
        }
        _countLabel.text = [NSString stringWithFormat:@"%d%@",_sensorCnt, NSLocalizedStringFromTable(@"mydevice.gateway.mainpage.panel.info.count", @"plugin_gateway", nil)];
        _detailLabel.hidden = YES;
    }
    else {
        [self buildSensorView];
    }
}

- (void)buildSensorView {
    _nameLabel.frame = CGRectMake(80, 10, 200, 20);
    MHDeviceGatewayBase *sensor = (MHDeviceGatewayBase *)[_sensors firstObject];
    if(sensor.isOnline) {
        if ([sensor isKindOfClass:[MHDeviceGatewaySensorHumiture class]]) {
            _nameLabel.text = [(MHDeviceGatewaySensorHumiture *)sensor getStatusText];
        }
        else {
            _nameLabel.text = [sensor.logManager getLatestLogDescription];
        }
    }
    else {
        _nameLabel.text = NSLocalizedStringFromTable(@"mydevice.label.offline", @"plugin_gateway", nil);
    }
    
    if(!_detailLabel){
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(80, 30, 200, 20)];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.font = [UIFont systemFontOfSize:13.f];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        [self addSubview:_detailLabel];
    }
    _detailLabel.text = [[_sensors firstObject] name];
}

- (void)setShouldfold:(BOOL)shouldfold {
    _shouldfold = shouldfold;
    if(shouldfold) _accessoryImageView.image = [UIImage imageNamed:@"gateway_up_arrow"];
    else _accessoryImageView.image = [UIImage imageNamed:@"gateway_down_arrow"];
}

#pragma mark - long press
- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan)
        if(self.longPressed)self.longPressed(self);
}

@end
