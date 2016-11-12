//
//  MHGetP2PIdResponse.h
//  	
//
//  Created by huchundong on 15/12/29.
//  Copyright © 2015年 小米移动软件. All rights reserved.
//

#import <MiHomeKit/MiHomeKit.h>

@interface MHGetP2PIdResponse : MHBaseResponse
@property(nonatomic, strong)NSString*   p2pId;
@property(nonatomic, strong)NSString*   password;
@end
