//
//  MHVolumeBarView.h
//  MiHome
//
//  Created by Lynn on 11/3/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

#define DefaultBarColor [UIColor whiteColor]

@interface MHVolumeBarView : UIView

-(id)initWithFrame:(CGRect)frame andColor:(UIColor *)color Level:(int)level;

@end
