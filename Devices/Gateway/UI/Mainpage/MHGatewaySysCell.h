//
//  MHGatewaySysCell.h
//  MiHome
//
//  Created by Lynn on 2/23/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHTableViewCell.h"
#import "MHDataIFTTTRecord.h"
#import "MHDataIFTTTRecomRecord.h"

#define TableViewCellHeight 70.f

@interface MHGatewaySysCell : MHTableViewCell
{
    NSDictionary *              _dataObject;
    MHDataIFTTTRecord *         _record;
    MHDataIFTTTRecomRecord *    _recomendRecord;

    UIView *                    _bottomeLine;
    UIImageView *               _icon;
    UILabel *                   _nameLabel;
    UILabel *                   _detailLabel;
    
    UILabel *                   _sceneNameLabel;
    UILabel *                   _sceneDetailLabel;
    
    UIButton*                   _reLocateBtn; //重新本地化
    UIButton*                   _offlineBtn; //有自动化设备离线
    
    UIButton *                  _launchBtn;
}

@property (nonatomic, copy) void (^relocateRecordBlock)();
@property (nonatomic, copy) void (^offlineRecord)(MHDataIFTTTRecord *record);


@end
