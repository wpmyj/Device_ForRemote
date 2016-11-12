//
//  MHLumiCameraMediaDataManager.h
//  Lumi_demo_OC
//
//  Created by LM21Mac002 on 2016/10/25.
//  Copyright © 2016年 LM21Mac002. All rights reserved.
//

#import <Foundation/Foundation.h>
typedef NS_ENUM(NSInteger, MHLumiCameraMediaDataType){
    MHLumiCameraMediaDataTypeAll,
    MHLumiCameraMediaDataTypeAlarm,
    MHLumiCameraMediaDataTypePhotoWithoutAlarm,
    MHLumiCameraMediaDataTypeVideoWithoutAlarm,
};
@class PHAsset;
@class PHFetchResult;
@class PHAssetCollection;
@interface MHLumiCameraMediaDataManager : NSObject
@property (nonatomic, strong, readonly) PHAssetCollection *assetCollection;

- (NSMutableArray<NSMutableArray<PHAsset *> *> *)fetchDataWithType:(MHLumiCameraMediaDataType)type;
- (instancetype)initWithAssetCollection:(PHAssetCollection *)assetCollection;
- (void)saveImage:(UIImage *)image andError:(NSError **)error;
+ (PHAssetCollection *)lumiCameraAssetCollection;
+ (void)saveImage:(UIImage *)image
 toAssetColletion:(PHAssetCollection *)assetColletion
         andError:(NSError **)error;
+ (void)saveVideoWithPath:(NSString *)path
        toAssetCollection:(PHAssetCollection *)assetCollection
                 andError:(NSError **)error;
@end
