//
//  MHGatewayScensView.m
//  MiHome
//
//  Created by Lynn on 9/4/15.
//  Copyright (c) 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayScensView.h"
#import "MHDeviceSettingSwitchCell.h"
#import "MHDataScene.h"
#import <MiHomeKit/MiHomeKit.h>
#import "MHTableViewControllerInternalV2.h"
#import "MHIFTTTEditViewController.h"
#import "MHGatewaySensorSceneCell.h"

@interface MHGatewayScensView () <MHTableViewControllerInternalDelegateV2, UIAlertViewDelegate, UIScrollViewDelegate, UIActionSheetDelegate>
@property (nonatomic,strong) MHDeviceGatewayBase *device;
@property (nonatomic,strong) NSMutableArray *sceneList; //数据源
@property (nonatomic,strong) NSMutableArray *recomendList; //数据源
@property (nonatomic,strong) MHTableViewControllerInternalV2 *tvInternal;

@end

@implementation MHGatewayScensView
{
    MHDeviceGatewayBase *        _device;
    BOOL                        _reloading;
}

- (id)initWithFrame:(CGRect)frame andDevices:(MHDeviceGatewayBase *)device
{
    if (self = [super init]) {
        _device = device;
        _reloading = NO;
        self.frame = frame;
        self.device = device;
        [self buildSubviews];
    }
    return self;
}

- (void)fetchRecomendData {
    XM_WS(weakself);
    [[MHIFTTTManager sharedInstance] getRecomRecordOfDevice:self.device.did completion:^(NSArray *array) {
        [weakself refreshRecomend:array];
    }];
}

- (void)refreshRecomend:(NSArray *)dataList {
    self.recomendList = [NSMutableArray arrayWithArray:dataList];
    [self refreshDataSource];
}

- (void)fetchRecordData {
    XM_WS(weakself);
    [[MHIFTTTManager sharedInstance] getRecordsOfDevices:@[self.device.did] completion:^(NSArray *array) {
        weakself.sceneList = [NSMutableArray arrayWithArray:array];
        [weakself refreshDataSource];
    }];
}

- (void)refreshDataSource {
    NSMutableArray *dataSource = [NSMutableArray new];
    if(self.sceneList.count) [dataSource addObject:self.sceneList];
    if(self.recomendList.count) [dataSource addObject:self.recomendList];
    self.tvInternal.dataSource = [dataSource mutableCopy];
    [self.tvInternal stopRefreshAndReload];
}

-(void)buildSubviews{
    [self fetchRecomendData];
    [self fetchRecordData];
    
    self.backgroundColor = [UIColor whiteColor];
    CGRect tableRect = CGRectMake(0, 0, CGRectGetWidth(self.frame), CGRectGetHeight(self.frame));
    self.tvInternal = [[MHTableViewControllerInternalV2 alloc] initWithStyle:UITableViewStyleGrouped];
    self.tvInternal.delegate = self;
    self.tvInternal.cellClass = [MHGatewaySensorSceneCell class];
    [self.tvInternal.view setFrame:tableRect];
//    self.tvInternal.view.backgroundColor = [UIColor whiteColor];
    [self addSubview:self.tvInternal.view];
    
    [self.tvInternal pullDownToRefresh];
}

#pragma mark - table view datasource
- (void)startRefresh {
    [self fetchRecomendData];
    [self fetchRecordData];
}

- (CGFloat)heightForHeaderInSection:(NSInteger)section {
    return 40.f;
}

- (CGFloat)heightForFooterInSection:(NSInteger)section {
    return 5.f;
}

- (UIView *)viewForFooterInSection:(NSInteger)section {
    UIView *back = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40)];
    return back;
}

- (UIView *)viewForHeaderInSection:(NSInteger)section {
    UIView *headerView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, WIN_WIDTH, 40)];
    UILabel *detailLabel = [[UILabel alloc] initWithFrame:CGRectMake(20, 10, WIN_WIDTH - 70, 30)];
    detailLabel.textAlignment = NSTextAlignmentLeft;
    detailLabel.font = [UIFont systemFontOfSize:14.f];
    detailLabel.textColor = [UIColor colorWithWhite:0.6 alpha:1.0];
    if(_sceneList.count && _recomendList.count) {
        detailLabel.text = !section ? NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom", @"plugin_gateway", nil) : NSLocalizedStringFromTable(@"mydevice.gateway.suggest.bind", @"plugin_gateway", nil);
    }
    else {
        if(_recomendList.count) detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.suggest.bind", @"plugin_gateway", nil);
        else detailLabel.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.custom", @"plugin_gateway", nil);
    }
    [headerView addSubview:detailLabel];
    
    UIView *bottomeLine = [[UIView alloc] initWithFrame:CGRectMake(20.0f, 39.f, WIN_WIDTH - 40.f, 0.5)];
    bottomeLine.backgroundColor = [MHColorUtils colorWithRGB:0xD1D1D1];
    [headerView addSubview:bottomeLine];
    
    return headerView;
}

- (UIView*)emptyView {
    UIView *messageView = [[UIView alloc] initWithFrame:self.bounds];
    [messageView setBackgroundColor:[MHColorUtils colorWithRGB:0xefefef alpha:0.4f]];
    UIImageView *icon = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"tableview_blank_logo"]];
    [messageView addSubview:icon];
    CGRect frame = icon.frame;
    frame.origin.x = messageView.bounds.size.width / 2.0f - icon.frame.size.width / 2.0f;
    frame.origin.y = CGRectGetHeight(self.bounds) * 2.f / 5.f;
    [icon setFrame:frame];
    UIView *sep = [[UIView alloc] initWithFrame:CGRectMake((messageView.frame.size.width - 117) / 2, CGRectGetMaxY(icon.frame) + 5.f , 117, 1.0f)];
    [sep setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
    [messageView addSubview:sep];
    UILabel *label = [[UILabel alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(sep.frame) + 8.0f, sep.frame.size.width, 19.0f)];
    label.text = NSLocalizedStringFromTable(@"mydevice.gateway.scene.list.none", @"plugin_gateway", @"列表内容为空");
    label.textAlignment = NSTextAlignmentCenter;
    [label setTextColor:[MHColorUtils colorWithRGB:0xcfcfcf]];
    [label setFont:[UIFont systemFontOfSize:13.0f]];
    [messageView addSubview:label];
    UIView *sep2 = [[UIView alloc] initWithFrame:CGRectMake(sep.frame.origin.x, CGRectGetMaxY(label.frame) + 8.0f, sep.frame.size.width, sep.frame.size.height)];
    [messageView addSubview:sep2];
    [sep2 setBackgroundColor:[MHColorUtils colorWithRGB:0xe6e6e6]];
    
    return messageView;
}

- (CGFloat)heightForRowAtIndexPath:(NSIndexPath *)indexPath {
    return TableViewCellHeight;
}

- (UITableViewCell *)cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    static NSString *sysCellIdentifier = @"sysCell";
    static NSString *customCellIdentifier = @"customCell";
    
    if(indexPath.section == 0){
        id obj;
        if(_sceneList.count){
            obj = _sceneList[indexPath.row];
        }
        else {
            obj = _recomendList[indexPath.row];
        }
        MHGatewaySensorSceneCell* cell = (MHGatewaySensorSceneCell *)[self.tvInternal.tableView dequeueReusableCellWithIdentifier:sysCellIdentifier];
        [cell configureWithDataObject:obj];
        return cell;
    }
    else {
        MHDataIFTTTRecord *record = _recomendList[indexPath.row];
        MHGatewaySensorSceneCell *cell = (MHGatewaySensorSceneCell *)[self.tvInternal.tableView dequeueReusableCellWithIdentifier:customCellIdentifier];
        [cell configureWithDataObject:record];
        return cell;
    }
}


- (void)extraConfigureCell:(UITableViewCell *)cell withDataObject:(id)object {
    if ([object isKindOfClass:[MHDataIFTTTRecord class]]) {
        MHGatewaySensorSceneCell *scene = (MHGatewaySensorSceneCell *)cell;
        MHDataIFTTTRecord *record = (MHDataIFTTTRecord *)object;
        XM_WS(weakself);
        scene.relocateRecordBlock = ^{
            NSLog(@"%@", record);
            [weakself retryLocal:record];
        };
        
        [scene setOfflineRecord:^{
            if (weakself.offlineRecord) {
                weakself.offlineRecord(record);
            }
        }];
    }
}

- (void)didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(_sceneList.count){
            id scene = _sceneList[indexPath.row];
            if(self.onSelectedScene)self.onSelectedScene(scene);
        }
        else {
            id recom = _recomendList[indexPath.row];
            if(self.onSelectedRecom)self.onSelectedRecom(recom);
        }
    }
    else {
        id recom = _recomendList[indexPath.row];
        if(self.onSelectedRecom)self.onSelectedRecom(recom);
    }
}

- (UITableViewCellEditingStyle)editingStyleForRowAtIndexPath:(NSIndexPath *)indexPath {
    if(indexPath.section == 0){
        if(_sceneList.count){
            return UITableViewCellEditingStyleDelete;
        }
    }
    return UITableViewCellEditingStyleNone;
}

- (void)commitEditingStyle:(UITableViewCellEditingStyle)editingStyle forRowAtIndexPath:(NSIndexPath *)indexPath {
    XM_WS(weakself);
    if (editingStyle == UITableViewCellEditingStyleDelete){
        MHDataIFTTTRecord *record = _sceneList[indexPath.row];
        [[MHIFTTTManager sharedInstance] deleteRecord:record success:^{
            [weakself.sceneList removeObject:record];
            [weakself.tvInternal stopRefreshAndReload];
            [weakself.tvInternal pullDownToRefresh];
            
        } failure:^(NSError *error){
            [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"delete.failed", @"plugin_gateway", nil) duration:1.f modal:YES];
        }];
    }
}

#pragma mark - 重新本地化
- (void)retryLocal:(MHDataIFTTTRecord *)record {
    NSString *strDelete = NSLocalizedStringFromTable(@"delete", @"plugin_gateway", "删除");
    NSString *strRetry = NSLocalizedStringFromTable(@"retry", @"plugin_gateway", "重试");
    NSString *strCancle = NSLocalizedStringFromTable(@"Cancel", @"plugin_gateway", "取消");
    NSString *strTitle = nil;
    NSArray *buttonArray = nil;
    
    if (record.status == -1) {
        strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.delete.alert.title", @"plugin_gateway", "请确保网关在线后再删除");
        buttonArray = @[ strCancle, strDelete ];
    }
    else {
        strTitle = NSLocalizedStringFromTable(@"ifttt.scene.local.alert.title", @"plugin_gateway", "自动化同步失败");
        buttonArray = @[ strDelete, strRetry ];
        
    }
    
    
    XM_WS(weakself);
    [[MHPromptKit shareInstance] showAlertWithHandler:^(NSInteger buttonIndex, NSArray *inputs) {
        switch (buttonIndex) {
            case 0: {
                if (record.status == -1) {
                    //取消
                }
                else {
                    //删除
                    [[MHIFTTTManager sharedInstance] deleteRecord:record success:^{
                        [weakself.sceneList removeObject:record];
                        [weakself.tvInternal stopRefreshAndReload];
                    } failure:^(NSError *v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.delete.failed", @"plugin_gateway", "删除自动化失败") duration:1.0f modal:NO];
                    }];
                }
            }
                break;
            case 1: {
                if (record.status == -1) {
                    //删除
                    [[MHIFTTTManager sharedInstance] deleteRecord:record success:^{
                        [weakself.sceneList removeObject:record];
                        [weakself.tvInternal stopRefreshAndReload];
                    } failure:^(NSError *v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.delete.failed", @"plugin_gateway", "删除自动化失败") duration:1.0f modal:NO];
                    }];
                }
                else {
                    //编辑
                    [[MHIFTTTManager sharedInstance] editRecord:record success:^{
                        [weakself.tvInternal pullDownToRefresh];
                    } failure:^(NSInteger v) {
                        [[MHTipsView shareInstance] showFailedTips:NSLocalizedStringFromTable(@"ifttt.scene.local.alert.edit.tips", @"plugin_gateway", "自动化本地化失败") duration:1.0f modal:NO];
                    }];
                }
            }
                break;
                
            default:
                break;
        }
    } withTitle:strTitle message:nil style:UIAlertViewStyleDefault defaultText:nil cancelButtonTitle:nil otherButtonTitlesArray:buttonArray];
    
    
}


@end
