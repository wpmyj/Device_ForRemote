//
//  MHACPartnerSceneCell.m
//  MiHome
//
//  Created by ayanami on 16/5/30.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHACPartnerSceneCell.h"

@implementation MHACPartnerSceneCell

- (void)configureWithDataObject:(id)object {
    [super configureWithDataObject:(id)object];
    if([object isKindOfClass:NSClassFromString(@"MHDataIFTTTRecomRecord")]) {
        _recomendRecord = object;
        [self buildRecomRecordSubviews];
    }
    
}


- (void)buildRecomRecordSubviews {
    self.backgroundColor = [UIColor whiteColor];
    self.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    self.selectionStyle = UITableViewCellSelectionStyleNone;
    
    _sceneDetailLabel.hidden = YES;
    _sceneNameLabel.hidden = YES;
    _launchBtn.hidden = YES;
    _reLocateBtn.hidden = YES;
    _nameLabel.hidden = NO;
    _icon.image = nil;
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





@end
