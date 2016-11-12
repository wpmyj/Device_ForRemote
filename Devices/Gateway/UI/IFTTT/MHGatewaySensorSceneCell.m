//
//  MHGatewaySensorSceneCell.m
//  MiHome
//
//  Created by Lynn on 3/8/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewaySensorSceneCell.h"
#import "MHIFTTTManager.h"
#import "MHPromptKit.h"
#import "MHDevListManager.h"

@implementation MHGatewaySensorSceneCell
{
    MHDataIFTTTRecord *         _record;
    MHDataIFTTTRecomRecord *    _recomendRecord;
    
    UILabel *                   _nameLabel;
    UILabel *                   _detailLabel;
    UILabel *                   _sceneNameLabel;
    UILabel *                   _sceneDetailLabel;
    UIButton* _reLocateBtn; //重新本地化
    UIButton*                   _offlineBtn; //有自动化设备离线

    UIButton *                  _launchBtn;

    UIView *                    _bottomeLine;
}

- (void)configureWithDataObject:(id)object {
    if([object isKindOfClass:NSClassFromString(@"MHDataIFTTTRecord")]){
        _record = object;
        [self buildRecordSubviews];
    }
    else {
        _recomendRecord = object;
        [self buildRecomRecordSubviews];
    }
}

- (void)buildRecordSubviews {
    self.backgroundColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    _sceneDetailLabel.hidden = NO;
    _sceneNameLabel.hidden = NO;
    _nameLabel.hidden = YES;
    _detailLabel.hidden = YES;
    
    CGRect nameFrame = CGRectMake(20, 20, WIN_WIDTH - 140, 20);
    if(!_sceneNameLabel) {
        _sceneNameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        _sceneNameLabel.textAlignment = NSTextAlignmentLeft;
        _sceneNameLabel.font = [UIFont systemFontOfSize:15.f];
        _sceneNameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self.contentView addSubview:_sceneNameLabel];
    }
    _sceneNameLabel.frame = nameFrame;
    _sceneNameLabel.text = _record.name;
    
    CGRect detailFrame = CGRectMake(WIN_WIDTH - 100, 20, 60, 20);
    if(!_sceneDetailLabel){
        _sceneDetailLabel = [[UILabel alloc] initWithFrame:detailFrame];
        _sceneDetailLabel.textAlignment = NSTextAlignmentRight;
        _sceneDetailLabel.font = [UIFont systemFontOfSize:13.f];
        [self.contentView addSubview:_sceneDetailLabel];
    }
    _sceneDetailLabel.frame = detailFrame;
    _sceneDetailLabel.text = _record.enabled ? NSLocalizedStringFromTable(@"mydevice.gateway.scene.enable", @"plugin_gateway", "已开启") : NSLocalizedStringFromTable(@"mydevice.gateway.scene.disable", @"plugin_gateway", "未开启");
    _sceneDetailLabel.textColor = _record.enabled ? [MHColorUtils colorWithRGB:0x00ba7c] : [UIColor colorWithWhite:0.6 alpha:1.0];
    
    
    _launchBtn.hidden = YES;
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    if ([_record.triggers count]) {
        MHDataIFTTTTrigger* trigger = [_record.triggers objectAtIndex:0];
        if (trigger.type == MHIFTTTTriggerClickToLaunch && _record.enabled) { //触发条件为点击启动时，显示执行按钮
            if (_launchBtn == nil) {
                _launchBtn = [UIButton buttonWithType:UIButtonTypeRoundedRect];
                _launchBtn.frame = CGRectMake(WIN_WIDTH - 80, 25, 50, 25);
                _launchBtn.layer.borderColor = [[MHColorUtils colorWithRGB:0x0BB58B] CGColor];
                _launchBtn.layer.borderWidth = 0.5;
                _launchBtn.layer.cornerRadius = 25/2.f;
                _launchBtn.titleLabel.font = [UIFont systemFontOfSize:12];
                [_launchBtn setTitleColor:[MHColorUtils colorWithRGB:0x0BB58B] forState:UIControlStateNormal];
                [_launchBtn setTitle:NSLocalizedStringFromTable(@"ifttt.scene.execute", @"plugin_gateway", "执行") forState:UIControlStateNormal];
                [_launchBtn addTarget:self action:@selector(executeBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
                [self.contentView addSubview:_launchBtn];
            }
            _launchBtn.hidden = NO;
            self.accessoryType = UITableViewCellAccessoryNone;
        }
    }

    
    XM_WS(weakself);
    _reLocateBtn.hidden = YES;
    if (_record.status != 0) { //自动化本地化失败
        if (_reLocateBtn == nil) {
            _reLocateBtn = [UIButton new];
            UIImage* failedMark = [UIImage imageNamed:@"plug_status_timer"];
            [_reLocateBtn setBackgroundImage:failedMark forState:UIControlStateNormal];
            [_reLocateBtn addTarget:self action:@selector(relocateBtnClicked:) forControlEvents:UIControlEventTouchUpInside];
            [self.contentView addSubview:_reLocateBtn];
            
            [_reLocateBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakself.contentView);
                make.trailing.equalTo(weakself.contentView).offset(-23);
                make.size.mas_equalTo(failedMark.size);
            }];
        }
        _reLocateBtn.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
    }
    
    _offlineBtn.hidden = YES;
    if ([self isHasOfflineDevice]) { //自动化中有离线或者删除设备
        if (_offlineBtn == nil) {
            _offlineBtn = [UIButton new];
            UIImage* failedMark = [UIImage imageNamed:@"plug_status_timer"];
            
            [_offlineBtn setBackgroundImage:failedMark forState:UIControlStateNormal];
            //            [_reLocateBtn setImage:failedMark forState:UIControlStateNormal];
            [_offlineBtn addTarget:self action:@selector(offlineClicked:) forControlEvents:UIControlEventTouchUpInside];
            
            [self.contentView addSubview:_offlineBtn];
            
            [_offlineBtn mas_makeConstraints:^(MASConstraintMaker *make) {
                make.centerY.equalTo(weakself.contentView);
                make.trailing.equalTo(weakself.contentView).offset(-40);
                make.size.mas_equalTo(failedMark.size);
            }];
        }
        _offlineBtn.hidden = NO;
        self.accessoryType = UITableViewCellAccessoryNone;
    }

    
    if (_record.status != 0) { //自动化本地化失败
        _launchBtn.hidden = YES;
        _sceneDetailLabel.hidden = YES;
        _reLocateBtn.hidden = NO;
        _offlineBtn.hidden = YES;
    }
    else {
        _reLocateBtn.hidden = YES;
        if ([self isHasOfflineDevice]) {
            _launchBtn.hidden = YES;
            _sceneDetailLabel.hidden = YES;
            _offlineBtn.hidden = NO;
        }
        else {
            _offlineBtn.hidden = YES;
            if ([_record.triggers count]) {
                MHDataIFTTTTrigger* trigger = [_record.triggers objectAtIndex:0];
                if (trigger.type == MHIFTTTTriggerClickToLaunch && _record.enabled) { //点击执行开启
                    _launchBtn.hidden = NO;
                    _sceneDetailLabel.hidden = YES;
                }
                else {
                    _sceneDetailLabel.hidden = NO;
                    _launchBtn.hidden = YES;
                }
            }
        }
        
    }



    
    
    if(!_bottomeLine){
        _bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, TableViewCellHeight - 1, WIN_WIDTH - 40.f, 0.5)];
        _bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
        [self addSubview:_bottomeLine];
    }
}

- (void)buildRecomRecordSubviews {
    self.backgroundColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _sceneDetailLabel.hidden = YES;
    _sceneNameLabel.hidden = YES;
    _nameLabel.hidden = NO;
    _reLocateBtn.hidden = YES;
    _launchBtn.hidden = YES;
    _offlineBtn.hidden = YES;

    CGRect nameFrame = CGRectMake(20, 16, WIN_WIDTH - 60, 30);
    if(!_nameLabel) {
        _nameLabel = [[UILabel alloc] initWithFrame:nameFrame];
        _nameLabel.textAlignment = NSTextAlignmentLeft;
        _nameLabel.font = [UIFont systemFontOfSize:15.f];
        _nameLabel.textColor = [UIColor colorWithWhite:0.3 alpha:1.0];
        [self.contentView addSubview:_nameLabel];
    }
    _nameLabel.frame = nameFrame;
    _nameLabel.text = _recomendRecord.name;
    
    _detailLabel.hidden = YES;
    
    if(!_bottomeLine){
        _bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, TableViewCellHeight - 1, WIN_WIDTH - 40.f, 0.5)];
        _bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
        [self addSubview:_bottomeLine];
    }
}

- (BOOL)isHasOfflineDevice {
    __block BOOL hasOffline = NO;
    if ([_record.triggers count]) {
        [_record.triggers enumerateObjectsUsingBlock:^(MHDataIFTTTTrigger *trigger, NSUInteger idx, BOOL * _Nonnull stop) {
            if (trigger.type == MHIFTTTTriggerDevice) {
                MHDevice *device = [[MHDevListManager sharedManager] deviceForDid:trigger.did];
                NSLog(@"%@%@", device, device.name);
                if (device.isOnline == NO || !device) {
                    hasOffline = YES;
                    *stop = YES;
                }
            }
        }];
    }
    if (hasOffline) {
        return hasOffline;
    }
    if ([_record.actions count]) {
        [_record.actions enumerateObjectsUsingBlock:^(MHDataIFTTTAction *action, NSUInteger idx, BOOL * _Nonnull stop) {
            if (action.type == MHIFTTTActionDevice) {
                MHDevice *device = [[MHDevListManager sharedManager] deviceForDid:action.did];
                NSLog(@"%@%@", device, device.name);
                if (device.isOnline == NO || !device) {
                    hasOffline = YES;
                    *stop = YES;
                }
            }
        }];
    }
    return hasOffline;
}
- (void)executeBtnClicked:(id)sender
{
    [[MHIFTTTManager sharedInstance] executeRecord:_record success:^{
        [[MHTipsView shareInstance] showFinishTips:NSLocalizedStringFromTable(@"ifttt.scene.execute.succeed", @"plugin_gateway", "自动化执行完毕") duration:1.5 modal:NO];
    } failure:^{
        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.execute.failed", @"plugin_gateway", "自动化执行失败，请重试") duration:1.5 modal:NO];
    }];
}


#pragma mark - 重新本地化
- (void)relocateBtnClicked:(id)sender
{
    //编辑
    if (self.relocateRecordBlock) {
        self.relocateRecordBlock();
    }

}

- (void)offlineClicked:(id)sender {
    if (self.offlineRecord) {
        self.offlineRecord();
    }
}
@end
