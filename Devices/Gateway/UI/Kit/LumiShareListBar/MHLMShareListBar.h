//
//  MHLMShareListBar.h
//  MiHome
//
//  Created by guhao on 15/12/9.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import "MHShareListBar.h"
#import <JavaScriptCore/JavaScriptCore.h>

@interface MHLMShareListBar : MHShareListBar
 
@property (nonatomic, strong) JSContext *jsContext;
@property (nonatomic, strong) UIWebView *webView;


@end
