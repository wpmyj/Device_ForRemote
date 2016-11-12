//
//  MHLuDeviceChangeNameView.h
//  MiHome
//
//  Created by guhao on 3/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHPopupViewBase.h"

@interface MHLuDeviceChangeNameView : MHPopupViewBase

@property (nonatomic, copy) NSString *labelTitleText;
- (void)setName:(NSString* )name;

@end
