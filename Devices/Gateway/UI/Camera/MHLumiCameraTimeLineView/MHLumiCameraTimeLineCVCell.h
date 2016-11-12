//
//  MHLumiCameraTimeLineCVCell.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 16/10/22.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHLumiCameraTimeLineDataUnit.h"

typedef NS_ENUM(NSInteger, MHLumiCameraTimeLineCVCellSeparatedStatus){
    MHLumiCameraTimeLineCVCellSeparatedStatusEnable,
    MHLumiCameraTimeLineCVCellSeparatedStatusDisable,
};


@interface MHLumiCameraTimeLineCVCell : UICollectionViewCell
- (void)configureCellWithDataUnit:(MHLumiCameraTimeLineDataUnit *)dataUnit;
@property (readonly, strong, nonatomic) MHLumiCameraTimeLineDataUnit *dataUnit;
@end
