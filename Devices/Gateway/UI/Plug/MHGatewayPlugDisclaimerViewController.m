//
//  MHGatewayPlugDisclaimerViewController.m
//  MiHome
//
//  Created by Lynn on 3/16/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHGatewayPlugDisclaimerViewController.h"
#import "NSString+WeiboStringDrawing.h"


#define Top     87
#define Left    40
#define Right   40
#define Gap     20

#define LineSpacing 5

@implementation MHGatewayPlugDisclaimerViewController {
    UILabel*    _num1;
    UILabel*    _desclaimerItem1;
    UILabel*    _num2;
    UILabel*    _desclaimerItem2;
    UILabel*    _num3;
    UILabel*    _desclaimerItem3;
    UILabel*    _num4;
    UILabel*    _desclaimerItem4;
    UILabel*    _num5;
    UILabel*    _desclaimerItem5;
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
    self.title = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer",@"plugin_gateway","nil");
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
    _desclaimerItem1.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer.item1", @"plugin_gateway",nil);
    //    _desclaimerItem1.attributedText = [self createAttrStringFrom:NSLocalizedStringFromTable(@"mydevice.gateway.disclaimer.item1",@"plugin_gateway", nil)];
    _desclaimerItem1.frame = CGRectMake(CGRectGetMaxX(_num1.frame), Top, itemWidth, [_desclaimerItem1.text sizeWithFont:_desclaimerItem1.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem1];
    
    
    _num2 = [[UILabel alloc] init];
    _num2.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num2.font = [UIFont systemFontOfSize:14];
    _num2.text = @"2、";
    _num2.textAlignment = NSTextAlignmentRight;
    _num2.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem1.frame) + Gap, numWidth, [_num2.text singleLineSizeWithFont:_num2.font].height);
    [self.view addSubview:_num2];
    
    _desclaimerItem2 = [[UILabel alloc] init];
    _desclaimerItem2.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem2.font = [UIFont systemFontOfSize:14];
    _desclaimerItem2.numberOfLines = 0;
    _desclaimerItem2.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer.item2",@"plugin_gateway", nil);
    _desclaimerItem2.frame = CGRectMake(CGRectGetMaxX(_num2.frame), CGRectGetMinY(_num2.frame), itemWidth, [_desclaimerItem2.text sizeWithFont:_desclaimerItem2.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem2];
    
    _num3 = [[UILabel alloc] init];
    _num3.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num3.font = [UIFont systemFontOfSize:14];
    _num3.text = @"3、";
    _num3.textAlignment = NSTextAlignmentRight;
    _num3.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem2.frame) + Gap, numWidth, [_num3.text singleLineSizeWithFont:_num3.font].height);
    [self.view addSubview:_num3];
    
    _desclaimerItem3 = [[UILabel alloc] init];
    _desclaimerItem3.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem3.font = [UIFont systemFontOfSize:14];
    _desclaimerItem3.numberOfLines = 0;
    _desclaimerItem3.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer.item3",@"plugin_gateway", nil);
    _desclaimerItem3.frame = CGRectMake(CGRectGetMaxX(_num3.frame), CGRectGetMinY(_num3.frame), itemWidth, [_desclaimerItem3.text sizeWithFont:_desclaimerItem3.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem3];
    
    _num4 = [[UILabel alloc] init];
    _num4.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num4.font = [UIFont systemFontOfSize:14];
    _num4.text = @"4、";
    _num4.textAlignment = NSTextAlignmentRight;
    _num4.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem3.frame) + Gap, numWidth, [_num4.text singleLineSizeWithFont:_num4.font].height);
    [self.view addSubview:_num4];
    
    _desclaimerItem4 = [[UILabel alloc] init];
    _desclaimerItem4.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem4.font = [UIFont systemFontOfSize:14];
    _desclaimerItem4.numberOfLines = 0;
    _desclaimerItem4.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer.item4",@"plugin_gateway", nil);
    _desclaimerItem4.frame = CGRectMake(CGRectGetMaxX(_num4.frame), CGRectGetMinY(_num4.frame), itemWidth, [_desclaimerItem4.text sizeWithFont:_desclaimerItem4.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem4];

    _num5 = [[UILabel alloc] init];
    _num5.textColor = [MHColorUtils colorWithRGB:0x666666];
    _num5.font = [UIFont systemFontOfSize:14];
    _num5.text = @"5、";
    _num5.textAlignment = NSTextAlignmentRight;
    _num5.frame = CGRectMake(0, CGRectGetMaxY(_desclaimerItem4.frame) + Gap, numWidth, [_num5.text singleLineSizeWithFont:_num5.font].height);
    [self.view addSubview:_num5];
    
    _desclaimerItem5 = [[UILabel alloc] init];
    _desclaimerItem5.textColor = [MHColorUtils colorWithRGB:0x666666];
    _desclaimerItem5.font = [UIFont systemFontOfSize:14];
    _desclaimerItem5.numberOfLines = 0;
    _desclaimerItem5.text = NSLocalizedStringFromTable(@"mydevice.gateway.sensor.plug.disclaimer.item5",@"plugin_gateway", nil);
    _desclaimerItem5.frame = CGRectMake(CGRectGetMaxX(_num5.frame), CGRectGetMinY(_num5.frame), itemWidth, [_desclaimerItem5.text sizeWithFont:_desclaimerItem5.font constrainedToWidth:itemWidth].height);
    [self.view addSubview:_desclaimerItem5];
}

- (void)onBack:(id)sender {
    if (self.onBack) {
        self.onBack();
    }
    [super onBack:sender];
}
@end
