//
//  MHGatewayTabView.h
//  MiHome
//
//  Created by Lynn on 10/20/15.
//  Copyright © 2015 小米移动软件. All rights reserved.
//

#import <UIKit/UIKit.h>

typedef enum {
    LumiTabStyleDefault,
    LumiTabStyleWithFrame,
    LumiTabStyleInTitle,    //titleArray @{ @"name" : ... , @"color" : ... }
} LumiTabStyle;

@interface MHGatewayTabView : UIView

@property (nonatomic,strong) NSArray *titleArray;
@property (nonatomic,assign) NSInteger currentIndex;

- (id)initWithFrame:(CGRect)frame
         titleArray:(NSArray*)titleArray
           callback:(void(^)(NSInteger))callback;

- (id)initWithFrame:(CGRect)frame
         titleArray:(NSArray*)titleArray
          stypeType:(LumiTabStyle)style
           callback:(void(^)(NSInteger))callback;

- (void)selectItem:(NSInteger)idx;

@end
