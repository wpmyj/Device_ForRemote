//
//  MHLumiAssetPreviewViewController.h
//  Lumi_demo_OC
//
//  Created by Noverre on 2016/10/30.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "MHViewController.h"

@class PHAsset;
@interface MHLumiAssetPreviewViewController : MHViewController
@property (nonatomic, strong)NSMutableArray<NSMutableArray<PHAsset *> *> *dateSource;
@property (nonatomic, assign)NSIndexPath *defaultIndexPath;
@end
