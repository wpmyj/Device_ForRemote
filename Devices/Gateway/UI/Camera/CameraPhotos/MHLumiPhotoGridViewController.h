//
//  MHLumiPhotoGridViewController.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/24.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <UIKit/UIKit.h>
#import <Photos/Photos.h>
#import "MHViewController.h"

@interface MHLumiPhotoGridViewController : MHViewController
@property (strong, nonatomic)PHFetchResult *fetchResult;
@property (strong, nonatomic)NSMutableArray<NSMutableArray<PHAsset *> *> *dateSource;
- (void)reloadData;
@end
