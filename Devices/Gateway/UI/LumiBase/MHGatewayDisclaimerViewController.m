//
//  MHGatewayDisclaimerViewController.m
//  MiHome
//
//  Created by Woody on 15/5/25.
//  Copyright (c) 2015年 小米移动软件. All rights reserved.
//

#import "MHGatewayDisclaimerViewController.h"
#import "NSString+WeiboStringDrawing.h"


#define Top     87
#define Left    40
#define Right   40
#define Gap     20

#define LineSpacing 5

@implementation MHGatewayDisclaimerViewController {
    UILabel*    _num1;
    UILabel*    _desclaimerItem1;
    UILabel*    _num2;
    UILabel*    _desclaimerItem2;
    UILabel*    _num3;
    UILabel*    _desclaimerItem3;
}

- (void)viewWillAppear:(BOOL)animated {
    [super viewWillAppear:animated];
    
    [self.navigationController.navigationBar setBackgroundImage:nil forBarMetrics:UIBarMetricsDefault];
}

- (NSMutableAttributedString* )createAttrStringFrom:(NSString* )src {
    NSMutableAttributedString* attrString = [[NSMutableAttributedString alloc] initWithString:src];
    NSMutableParagraphStyle* paragStyle = [[NSMutableParagraphStyle alloc] init];
    [paragStyle setLineSpacing:LineSpacing];
    [attrString addAttribute:NSParagraphStyleAttributeName value:paragStyle range:NSMakeRange(0, [src length])];
    return attrString;
}

- (void)buildSubviews {
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.name",@"plugin_gateway","《小米智能家庭套装使用须知》");
    self.isTabBarHidden = YES;
    
    CGFloat numWidth = Left;
    CGFloat itemWidth = CGRectGetWidth(self.view.bounds) - Left - Right;
    
    _num1 = [[UILabel alloc] init];
    _num1.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num1.font = [UIFont systemFontOfSize:14];
    _num1.text = @"1、";
    _num1.textAlignment = NSTextAlignmentRight;
    _num1.frame = CGRectMake(0, Top, numWidth, [_num1.text singleLineSizeWithFont:_num1.font].height);
    [self.view addSubview:_num1];

    _desclaimerItem1 = [[UILabel alloc] init];
    _desclaimerItem1.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem1.font = [UIFont systemFontOfSize:14];
    _desclaimerItem1.numberOfLines = 0;
    _desclaimerItem1.text = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.item1", @"plugin_gateway",nil);
//    _desclaimerItem1.attributedText = [self createAttrStringFrom:NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.item1",@"plugin_gateway", nil)];
    _desclaimerItem1.frame = CGRectMake(CGRectGetMaxX(_num1.frame), Top, itemWidth, [_desclaimerItem1.text sizeWithFont:_desclaimerItem1.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem1];
    
    
    _num2 = [[UILabel alloc] init];
    _num2.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num2.font = [UIFont systemFontOfSize:14];
    _num2.text = @"2、";
    _num2.textAlignment = NSTextAlignmentRight;
    _num2.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem1.frame), numWidth, [_num2.text singleLineSizeWithFont:_num2.font].height);
    [self.view addSubview:_num2];
    
    _desclaimerItem2 = [[UILabel alloc] init];
    _desclaimerItem2.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem2.font = [UIFont systemFontOfSize:14];
    _desclaimerItem2.numberOfLines = 0;
    _desclaimerItem2.text = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.item2",@"plugin_gateway", nil);
    _desclaimerItem2.frame = CGRectMake(CGRectGetMaxX(_num2.frame), CGRectGetMinY(_num2.frame), itemWidth, [_desclaimerItem2.text sizeWithFont:_desclaimerItem2.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem2];

    _num3 = [[UILabel alloc] init];
    _num3.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num3.font = [UIFont systemFontOfSize:14];
    _num3.text = @"3、";
    _num3.textAlignment = NSTextAlignmentRight;
    _num3.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem2.frame), numWidth, [_num3.text singleLineSizeWithFont:_num3.font].height);
    [self.view addSubview:_num3];
    
    _desclaimerItem3 = [[UILabel alloc] init];
    _desclaimerItem3.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem3.font = [UIFont systemFontOfSize:14];
    _desclaimerItem3.numberOfLines = 0;
    _desclaimerItem3.text = NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.item3",@"plugin_gateway", nil);
    _desclaimerItem3.frame = CGRectMake(CGRectGetMaxX(_num3.frame), CGRectGetMinY(_num3.frame), itemWidth, [_desclaimerItem3.text sizeWithFont:_desclaimerItem3.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem3];

}

- (void)onBack:(id)sender {
    if (self.onBack) {
        self.onBack();
    }
    [super onBack:sender];
}
@end
