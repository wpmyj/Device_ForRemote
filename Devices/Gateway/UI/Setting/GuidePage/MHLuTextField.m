//
//  MHLuTextField.m
//  MiHome
//
//  Created by guhao on 4/17/16.
//  Copyright © 2016 小米移动软件. All rights reserved.
//

#import "MHLuTextField.h"

@interface MHLuTextField (ExtentRange)

@end

@implementation MHLuTextField
#pragma mark - 设定光标位置
- (void)setSelectedRange:(NSRange)range
{
    UITextPosition* beginning = self.beginningOfDocument;
    
    UITextPosition* startPosition = [self positionFromPosition:beginning offset:range.location];
    UITextPosition* endPosition = [self positionFromPosition:beginning offset:range.location + range.length];
    UITextRange* selectionRange = [self textRangeFromPosition:startPosition toPosition:endPosition];
    
    [self setSelectedTextRange:selectionRange];
}

@end
