//
//  MHPlugCountdownTableView.h
//  MiHome
//
//  Created by hanyunhui on 15/9/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface MHPlugCountdownTableView : UIView<UITableViewDelegate, UITableViewDataSource>

@property(nonatomic, copy) void (^selectedCountdownTable)(int);

- (id)initWithTableView:(NSArray* )countdownArray rectFrame:(CGRect)rect;

@end
