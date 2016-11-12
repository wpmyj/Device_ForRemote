//
//  MHLumiPhotoGridViewHeaderView.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHLumiPhotoGridViewHeaderView : UICollectionReusableView
@property (readonly, strong, nonatomic) UILabel *titleLabel;
+ (NSString *)reuseIdentifier;
@end
