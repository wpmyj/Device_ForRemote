//
//  MHGatewayInfoSensorCell.m
//  MiHome
//
//  Created by Lynn on 2/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayInfoSensorCell.h"
#import "MHDeviceGatewayBase.h"
#import "MHDeviceGatewaySensorHumiture.h"

#define TableViewCellHeight 60.f

@implementation MHGatewayInfoSensorCell
{
    MHDeviceGatewayBase *       _sensor;

    UIImageView *               _icon;
    UILabel *                   _nameLabel;
    UILabel *                   _detailLabel;
    UIView *                    _bottomeLine;
}

- (void)configureWithDataObject:(id)object {
    _sensorInfo = object;
    _sensor = [[_sensorInfo valueForKey:@"sensors"] firstObject];
    
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
        _icon = [[UIImageView alloc] initWithFrame:CGRectMake(75, 7, 45, 45)];
        [self addSubview:_icon];
    }
    if(!_sensor.services.count && [_sensor isKindOfClass:[MHDeviceGatewayBase class]]) [_sensor buildServices];
    if(_sensor.services.count) _icon.image = [_sensor getMainPageSensorIconWithService:_sensor.services[0]];

    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 10, 200, 20)];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:15.f];
        _nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self addSubview:_nameLabel];
    }
    if(_sensor.isOnline){
        if ([_sensor isKindOfClass:[MHDeviceGatewaySensorHumiture class]]) {
            _nameLabel.text = [(MHDeviceGatewaySensorHumiture *)_sensor getStatusText];
        }
        else {
            _nameLabel.text = [_sensor.logManager getLatestLogDescription];
        }
    }
    else {
        _nameLabel.text = NSLocalizedStringFromTable(@"mydevice.label.offline", @"plugin_gateway", nil);
    }
    
    if(!_detailLabel){
        _detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(130, 30, 200, 20)];
        _detailLabel.textAlignment = NSTextAlignmentLeft;
        _detailLabel.font = [UIFont systemFontOfSize:13.f];
        _detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
        [self addSubview:_detailLabel];
    }
    _detailLabel.text = _sensor.name;
}

#pragma mark - long press
- (void)longPressed:(UILongPressGestureRecognizer *)gesture {
    if(gesture.state == UIGestureRecognizerStateBegan)
        if(self.longPressed)self.longPressed(self);
}
@end
