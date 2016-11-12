//
//  MHLumiBindItem.h
//  MiHome
//
//  Created by Lynn on 1/11/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MiHomeKit/MiHomeKit.h>

/*
 * 联动 描述
 */
@interface MHLumiBindItem : NSObject <NSCoding>

@property (nonatomic, copy) NSString* from_sid;     //联动的发起方
@property (nonatomic, copy) NSString* to_sid;       //联动的接收方
@property (nonatomic, copy) NSString* method;       //接收方执行的动作
@property (nonatomic, retain) NSArray* params;      //接收方执行动作时所需的参数列表
@property (nonatomic, copy) NSString* event;        //联动发起方产生的事件
@property (nonatomic, assign) BOOL enable;
@property (nonatomic, assign) NSInteger index;

- (BOOL)isEqualTo:(MHLumiBindItem* )item;

@end
