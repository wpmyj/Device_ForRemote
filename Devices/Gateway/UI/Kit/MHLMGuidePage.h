//
//  MHLMGuidePage.h
//  MiHome
//
//  Created by ayanami on 8/22/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef void(^ComfirmBlock)(void);


@interface MHLMGuidePage : UIView

@property (nonatomic, assign) BOOL isExitOnClickBg;
@property (nonatomic, copy) ComfirmBlock okBlock;
@property (nonatomic, copy) ComfirmBlock closeBlock;

@end

