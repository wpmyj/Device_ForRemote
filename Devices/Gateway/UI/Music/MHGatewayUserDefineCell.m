//
//  MHGatewayUserDefineCell.m
//  MiHome
//
//  Created by Lynn on 11/5/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayUserDefineCell.h"

#define DeleteButtonSize 60.f

@implementation MHGatewayUserDefineCell
{
    UILabel *               _labelTitle;
    UILabel *               _labelDetail;
    
    id                      _fileinfo;
    
    UIButton *              _uploadBtn;     //上传按钮
    UIButton *              _deleteBtn;     //删除按钮
    BOOL                    _deleteBtnShow;
    
    UIView *                _bottomLine;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubviews];
    }
    return self;
}

- (void)configureWithDataObject:(id)fileinfo {
    _fileinfo = fileinfo;
    
    _labelTitle.text = [fileinfo valueForKey:@"alias_name"];
    
//    int min = 0;
//    int sec = 0;
//    int seconds = [[fileinfo objectForKey:@"time"] intValue];
//    if (seconds >= 60 && seconds < 3600) {
//        min = seconds / 60;
//        sec = seconds % 60;
//    } else if (seconds < 60) {
//        sec = seconds;
//    } else {
//        min = 59;
//        sec = 59;
//        assert(0);  //超过1小时暂时不支持显示
//    }
//    _labelDetail.text = [NSString stringWithFormat:@"%02d:%02d", min, sec];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self buildConstraints];
}

-(void)buildSubviews
{
    CGFloat CellHeight = CGRectGetHeight(self.contentView.frame);
    
    _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(15, 8 , 100, CellHeight/2)];
    _labelTitle.text = @"test test";
    _labelTitle.font = [UIFont systemFontOfSize:15];
    _labelTitle.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    [self.contentView addSubview:_labelTitle];
    
    _labelDetail = [[UILabel alloc] init];
    _labelDetail.frame = CGRectMake(_labelTitle.frame.origin.x, CellHeight/2 , 200, CellHeight/2);
    _labelDetail.text = @"test test";
    _labelDetail.font = [UIFont systemFontOfSize:11];
    _labelDetail.textColor = [MHColorUtils colorWithRGB:0x999999];
//    [self.contentView addSubview:_labelDetail];
    
    _bottomLine = [[UIView alloc] init];
    _bottomLine.backgroundColor = [MHColorUtils colorWithRGB:0xf1f1f1];
    [self.contentView addSubview:_bottomLine];
    
    self.backgroundColor = [UIColor whiteColor];
}

-(void)buildConstraints
{
    CGFloat iconWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat CellHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat CellWidth = CGRectGetWidth(self.contentView.frame);
    _labelTitle.frame =CGRectMake(iconWidth + 20, 8 , 100, CellHeight/2);
    _labelDetail.frame = CGRectMake(_labelTitle.frame.origin.x, CellHeight/2 , 200, CellHeight/2);
    _uploadBtn.frame = CGRectMake(CellWidth - 60, 10, 50, 35);
    [_bottomLine setFrame:CGRectMake(20.0f, self.bounds.size.height - 1.0f, self.bounds.size.width - 20.0f * 2, 1.0f)];
}

-(void)deleteclicked:(id)sender{
    if(self.deletePressed)self.deletePressed(self);
}

@end
