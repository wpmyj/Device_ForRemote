//
//  MHLMDownLoadFileTools.h
//  MiHome
//
//  Created by Lynn on 3/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>

NS_ASSUME_NONNULL_BEGIN

typedef void (^CompletionHandler)(id __nullable result, NSError * __nullable error);

@interface MHLMDownLoadFileTools : NSObject

@property (nonatomic,strong) void (^downloadProgressBlock)(CGFloat progress);

+ (id)sharedInstance ;

/**
 *  下载
 *
 *  @param url               url description
 *  @param suffix            suffix description
 *  @param filepath          filepath description
 *  @param fileName          fileName description
 *  @param completionHandler completionHandler description
 */
-(void)downloadFileWithURL:(NSString *)url
                    suffix:(NSString *)suffix
              saveFilePath:(NSURL *)filepath
                  fileName:(NSString *)fileName
      andCompletionHandler:(CompletionHandler)completionHandler;

@end

NS_ASSUME_NONNULL_END
