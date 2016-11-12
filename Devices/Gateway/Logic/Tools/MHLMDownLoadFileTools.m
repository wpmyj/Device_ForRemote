//
//  MHLMDownLoadFileTools.m
//  MiHome
//
//  Created by Lynn on 3/19/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLMDownLoadFileTools.h"
#import <AFNetworking/AFNetworking.h>

static void *ProgressObserverContext = &ProgressObserverContext;

@implementation MHLMDownLoadFileTools
{
    NSProgress *    _progress;
}

+ (id)sharedInstance {
    static MHLMDownLoadFileTools *obj = nil;
    static dispatch_once_t pred;
    dispatch_once(&pred, ^{
        obj = [[MHLMDownLoadFileTools alloc] init];
    });
    return obj;
}

-(void)downloadFileWithURL:(NSString *)url
                    suffix:(NSString *)suffix
              saveFilePath:(NSURL *)filepath
                  fileName:(NSString *)fileName
      andCompletionHandler:(CompletionHandler)completionHandler {
    
    NSURLSessionConfiguration *configuration = [NSURLSessionConfiguration defaultSessionConfiguration];
    AFURLSessionManager *manager = [[AFURLSessionManager alloc] initWithSessionConfiguration:configuration];
    
    NSURL *URL = [NSURL URLWithString:url];
    NSURLRequest *request = [NSURLRequest requestWithURL:URL];
    
    NSProgress *localProgress = nil;
    NSURLSessionDownloadTask *downloadTask = [manager downloadTaskWithRequest:request progress:&localProgress destination:^NSURL *(NSURL *targetPath, NSURLResponse *response) {
        return [filepath URLByAppendingPathComponent:fileName];
    } completionHandler:^(NSURLResponse *response, NSURL *filePath, NSError *error) {
        if(completionHandler) completionHandler(filePath,error);
        NSLog(@"File downloaded to: %@", filePath);
    }];
    
    [downloadTask resume];
    
    //监控下载进度
    _progress = [manager downloadProgressForTask:downloadTask];
    [self.downloadProgressBlock addObserver:self
                                 forKeyPath:@"fractionCompleted"
                                    options:NSKeyValueObservingOptionInitial
                                    context:ProgressObserverContext];
}

- (void)observeValueForKeyPath:(NSString *)keyPath
                      ofObject:(id)object
                        change:(NSDictionary *)change
                       context:(void *)context {
    if (context == ProgressObserverContext){
        NSProgress *progress = object;
        NSLog(@"download at %f", progress.fractionCompleted);
        if(self.downloadProgressBlock)self.downloadProgressBlock(progress.fractionCompleted);
    }
    else{
        [super observeValueForKeyPath:keyPath ofObject:object change:change context:context];
    }
}


@end
