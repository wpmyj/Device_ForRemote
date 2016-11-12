//
//  MHGatewayBellChooseCell.m
//  MiHome
//
//  Created by Lynn on 10/30/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import "MHGatewayBellChooseCell.h"

#define DeleteButtonSize 60.f

@implementation MHGatewayBellChooseCell
{
    UILabel *               _labelTitle;
    UILabel *               _labelDetail;
    
    id                      _attribute;
    
    UIButton *              _uploadBtn;     //上传按钮
    UIButton *              _deleteBtn;     //删除按钮
    BOOL                    _deleteBtnShow;
}

- (instancetype)initWithStyle:(UITableViewCellStyle)style reuseIdentifier:(NSString *)reuseIdentifier {
    self = [super initWithStyle:style reuseIdentifier:reuseIdentifier];
    if (self) {
        [self buildSubviews];
    }
    return self;
}

- (void)configureWithDataObject:(id)attribute {
    _attribute = attribute;
    CGFloat duration = [[attribute valueForKey:@"duration"] doubleValue];
    _labelTitle.text = [NSString stringWithFormat:@"%.0f″",duration];
    _labelDetail.text = [NSString stringWithFormat:@"%@%@",[attribute valueForKey:@"createtime"],NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.title",@"plugin_gateway", nil)];
}

-(void)layoutSubviews{
    [super layoutSubviews];
    [self buildConstraints];
}

-(void)buildSubviews
{
    CGFloat CellHeight = CGRectGetHeight(self.contentView.frame);
    
    self.backgroundColor = [UIColor redColor];
    self.contentView.backgroundColor = [UIColor whiteColor];
    self.imageView.image = [UIImage imageNamed:@"lumi_gateway_audio3"];
    CGFloat iconWidth = CGRectGetWidth(self.imageView.frame);
    
    _deleteBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_deleteBtn addTarget:self action:@selector(deleteclicked:) forControlEvents:UIControlEventTouchUpInside];
    _deleteBtn.frame = CGRectMake([UIScreen mainScreen].bounds.size.width - DeleteButtonSize, 5, DeleteButtonSize, CellHeight);
    _deleteBtn.backgroundColor = [UIColor redColor];
    [_deleteBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.record.delete",@"plugin_gateway", nil) forState:UIControlStateNormal];
    _deleteBtn.titleLabel.center = CGPointMake(_deleteBtn.titleLabel.center.x, _deleteBtn.titleLabel.center.y);
    _deleteBtn.titleLabel.font = [UIFont boldSystemFontOfSize:17.f];

    [self addSubview:_deleteBtn];
    [self addSubview:self.contentView];
    
    _labelTitle = [[UILabel alloc] initWithFrame:CGRectMake(iconWidth + 15, 8 , 100, CellHeight/2)];
    _labelTitle.text = @"test test";
    _labelTitle.font = [UIFont systemFontOfSize:15];
    _labelTitle.textColor = [MHColorUtils colorWithRGB:0x5f5f5f];
    [self.contentView addSubview:_labelTitle];
    
    _labelDetail = [[UILabel alloc] init];
    _labelDetail.frame = CGRectMake(_labelTitle.frame.origin.x, CellHeight/2 , 200, CellHeight/2);
    _labelDetail.text = @"test test";
    _labelDetail.font = [UIFont systemFontOfSize:11];
    _labelDetail.textColor = [MHColorUtils colorWithRGB:0x999999];
    [self.contentView addSubview:_labelDetail];
    
    _uploadBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_uploadBtn addTarget:self action:@selector(uploadClicked:) forControlEvents:UIControlEventTouchUpInside];
    _uploadBtn.layer.cornerRadius = 3.0f;
    [_uploadBtn setTitle:NSLocalizedStringFromTable(@"mydevice.gateway.setting.cloudmusic.upload.button",@"plugin_gateway", "上传") forState:UIControlStateNormal];
    _uploadBtn.titleLabel.font = [UIFont systemFontOfSize:13.f];
    [_uploadBtn setBackgroundColor:[MHColorUtils colorWithRGB:0x80af00]];
    [self.contentView addSubview:_uploadBtn];
    
//    UIPanGestureRecognizer *pan = [[UIPanGestureRecognizer alloc] initWithTarget:self action:@selector(pan:)];
//    [self.contentView addGestureRecognizer:pan];
}

-(void)pan:(UIPanGestureRecognizer*)gestureRecognizer
{
    CGPoint curPoint = [gestureRecognizer locationInView:self];
    static CGFloat firstPointX;
    CGFloat currentPointX;
    static CGFloat lastPointX;
    CGFloat offsizeX = 0.0;
    if (_deleteBtnShow) offsizeX = -DeleteButtonSize;
    
    if (gestureRecognizer.state == UIGestureRecognizerStateBegan ){
        firstPointX = curPoint.x;
    }
    else if(gestureRecognizer.state == UIGestureRecognizerStateEnded){
        lastPointX = curPoint.x;
        offsizeX = lastPointX - firstPointX;
        if(-offsizeX > DeleteButtonSize/3){
            offsizeX = -DeleteButtonSize;
            _deleteBtnShow = YES;
        }
        else{
            offsizeX = 0;
            _deleteBtnShow = NO;
        }
    }
    else{
        currentPointX = curPoint.x;
        offsizeX = currentPointX - firstPointX;
        if (offsizeX < -DeleteButtonSize - 15) offsizeX = -DeleteButtonSize - 15;
        else if (offsizeX > 0) {
            if(_deleteBtnShow) {
                if(offsizeX > DeleteButtonSize) offsizeX = DeleteButtonSize;
                offsizeX = offsizeX - DeleteButtonSize;
            }
            else offsizeX = 0;
        }
    }

    NSLog(@"%f",offsizeX);
    //求偏移量，控制移动范围 （－DeleteButtonSize～0）
    CGFloat centerX = [UIScreen mainScreen].bounds.size.width /2;
    self.contentView.center = CGPointMake(centerX + offsizeX, self.contentView.center.y);
}

-(void)buildConstraints
{
    CGFloat iconWidth = CGRectGetWidth(self.imageView.frame);
    CGFloat CellHeight = CGRectGetHeight(self.contentView.frame);
    CGFloat CellWidth = CGRectGetWidth(self.contentView.frame);
    _labelTitle.frame =CGRectMake(iconWidth + 15, 8 , 100, CellHeight/2);
    _labelDetail.frame = CGRectMake(_labelTitle.frame.origin.x, CellHeight/2 , 200, CellHeight/2);
    _uploadBtn.frame = CGRectMake(CellWidth - 60, 10, 50, 35);
}

-(void)uploadClicked:(id)sender{
    if(self.uploadPressed)self.uploadPressed(self);
}

-(void)deleteclicked:(id)sender{
    if(self.deletePressed)self.deletePressed(self);
}
@end
