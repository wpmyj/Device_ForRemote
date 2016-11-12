//
//  MHACPartnerAddListCell.h
//  MiHome
//
//  Created by ayanami on 16/5/18.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHACPartnerAddListCell : UITableViewCell

@property (nonatomic, strong) UIImageView *arrowImage;
@property (nonatomic, strong) UILabel *nameLabel;

// 通过数据对象配置cell
- (void)configureWithDataObject:(id)object;
@end
