//
//  MHGatewayCubeGuidePages.h
//  MiHome
//
//  Created by guhao on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>
typedef void(^ActionBlock)(id);


#define kCubeMovieURLCN @"https://app-ui.aqara.cn/magicCube/cn/magicCube.html"
#define kCubeMovieURLEN @"https://app-ui.aqara.cn/magicCube/en/magicCube.html"

@interface MHGatewayCubeGuidePages : UIView{
    ActionBlock _cancelBlock;
    
}
@property (nonatomic, assign) BOOL isExitOnClickBg;
@property (nonatomic, copy) ActionBlock okBlock;

@end
