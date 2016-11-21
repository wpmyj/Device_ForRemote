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
#import "MHLumiAlarmVideoDataSource.h"
@class MHLumiPhotoGridViewController;
@protocol MHLumiPhotoGridViewControllerDelegate <NSObject>
@optional
- (void)photoGridViewController:(MHLumiPhotoGridViewController *)photoGridViewController didSelectItemAtIndexPath:(NSIndexPath *)indexPath;

@end

@interface MHLumiPhotoGridViewController : MHViewController
@property (nonatomic, strong)PHFetchResult *fetchResult;
@property (nonatomic, strong)NSMutableArray<NSMutableArray<PHAsset *> *> *dataSource;
- (void)reloadData;
@property (nonatomic, weak) id<MHLumiPhotoGridViewControllerDelegate> delegate;
@end
