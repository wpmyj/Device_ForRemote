//
//  MHLMShareListBar.m
//  MiHome
//
//  Created by guhao on 15/12/9.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHLMShareListBar.h"
#import "AppDelegate.h"


@implementation MHLMShareListBar



#ifdef UseWeiboSDK
+ (void)shareToWBWithTitle:(NSString *)title description:(NSString *)description thumbnail:(UIImage *)thumbnail url:(NSString *)url
{
    AppDelegate *myDelegate =(AppDelegate*)[[UIApplication sharedApplication] delegate];
    
    WBAuthorizeRequest *authRequest = [WBAuthorizeRequest request];
    authRequest.redirectURI = @"https://api.weibo.com/oauth2/default.html";
    authRequest.scope = @"all";
    
    WBMessageObject *message = [WBMessageObject message];
    
    message.text = [NSString stringWithFormat:@"#%@# %@", title, description];
    
    WBWebpageObject *webpage = [WBWebpageObject object];
    webpage.objectID = @"identifier1";
    webpage.title = title;
    webpage.description = description;
    webpage.thumbnailData = [self compressedImageDataForThumbnail:thumbnail];
    webpage.webpageUrl = url;
    message.mediaObject = webpage;
    
    WBSendMessageToWeiboRequest *request = [WBSendMessageToWeiboRequest requestWithMessage:message authInfo:authRequest access_token:myDelegate.wbtoken];
    request.userInfo = nil;// @{@"ShareMessageFrom": @"SendMessageToWeiboViewController",
    //                         @"Other_Info_1": [NSNumber numberWithInt:123],
    //                         @"Other_Info_2": @[@"obj1", @"obj2"],
    //                         @"Other_Info_3": @{@"key1": @"obj1", @"key2": @"obj2"}};
    //    //    request.shouldOpenWeiboAppInstallPageIfNotInstalled = NO;
    BOOL send = [WeiboSDK sendRequest:request];
}
#endif

/**
 *  @brief 缩略图image要控制在32k
 */
+ (NSData *)compressedImageDataForThumbnail:(UIImage *)image
{
    NSData *imageData = UIImageJPEGRepresentation(image, 1.0f);
    
    float quality = 0.8f;
    
    // 微信缩略图不能超过32k
    while (imageData.length > 32000 && quality >= 0)
    {
        imageData = UIImageJPEGRepresentation(image, quality);
        quality -= 0.2f;
    }
    
    return imageData;
}
@end
