//
//  MHLMDecimalBinaryTools.m
//  MiHome
//
//  Created by ayanami on 16/7/13.
//  Copyright © 2016年 小米移动软件. All rights reserved.
//

#import "MHLMDecimalBinaryTools.h"

@implementation MHLMDecimalBinaryTools


+ (NSString *)binaryToDecimal:(NSString *)binary {
    int sum = 0;
    for (int i = 0; i < binary.length; i++) {
        sum *= 2;
        char c = [binary characterAtIndex:i];
        sum += c - '0';
    }
    return [NSString stringWithFormat:@"%d",sum];
}
//10进制转16
+ (NSString *)decimalToHex:(long)decimal
{
    NSString *nLetterValue;
    NSString *str = @"";
    long ttmpig;
    for (int i = 0; i < 20; i++) {
        ttmpig = decimal % 16;
        decimal = decimal / 16;
        switch (ttmpig)
        {
            case 10:
            nLetterValue = @"A";break;
            case 11:
            nLetterValue = @"B";break;
            case 12:
            nLetterValue = @"C";break;
            case 13:
            nLetterValue = @"D";break;
            case 14:
            nLetterValue = @"E";break;
            case 15:
            nLetterValue = @"F";break;
            default:
            nLetterValue = [NSString stringWithFormat:@"%lu",ttmpig];
            
        }
        str = [nLetterValue stringByAppendingString:str];
        if (decimal == 0) {
            break;
        }
        
    }
    return str;
}

+ (NSString *)hexToBinary:(NSString *)hex
{
    NSMutableDictionary  *hexDic = [[NSMutableDictionary alloc] init];
    
    hexDic = [[NSMutableDictionary alloc] initWithCapacity:16];
    
    [hexDic setObject:@"0000" forKey:@"0"];
    
    [hexDic setObject:@"0001" forKey:@"1"];
    
    [hexDic setObject:@"0010" forKey:@"2"];
    
    [hexDic setObject:@"0011" forKey:@"3"];
    
    [hexDic setObject:@"0100" forKey:@"4"];
    
    [hexDic setObject:@"0101" forKey:@"5"];
    
    [hexDic setObject:@"0110" forKey:@"6"];
    
    [hexDic setObject:@"0111" forKey:@"7"];
    
    [hexDic setObject:@"1000" forKey:@"8"];
    
    [hexDic setObject:@"1001" forKey:@"9"];
    
    [hexDic setObject:@"1010" forKey:@"A"];
    
    [hexDic setObject:@"1011" forKey:@"B"];
    
    [hexDic setObject:@"1100" forKey:@"C"];
    
    [hexDic setObject:@"1101" forKey:@"D"];
    
    [hexDic setObject:@"1110" forKey:@"E"];
    
    [hexDic setObject:@"1111" forKey:@"F"];
    
    NSString *binaryString=[[NSString alloc] init];
    
    for (int i=0; i<[hex length]; i++) {
        
        NSRange rage;
        
        rage.length = 1;
        
        rage.location = i;
        
        NSString *key = [hex substringWithRange:rage];
        
        //NSLog(@"%@",[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]);
        
        binaryString = [NSString stringWithFormat:@"%@%@",binaryString,[NSString stringWithFormat:@"%@",[hexDic objectForKey:key]]];
        
    }
    
    //NSLog(@"转化后的二进制为:%@",binaryString);
    
    return binaryString;
    
}

//  二进制转十进制
+ (NSString *)binarytoDecimal:(NSString *)binary
{
    int ll = 0 ;
    int  temp = 0 ;
    for (int i = 0; i < binary.length; i ++)
    {
        temp = [[binary substringWithRange:NSMakeRange(i, 1)] intValue];
        temp = temp * powf(2, binary.length - i - 1);
        ll += temp;
    }
    
    NSString * result = [NSString stringWithFormat:@"%d",ll];
    
    return result;
}

+ (NSString *)decimalToBinary:(int)tmpid backLength:(int)length
{
    NSString *a = @"";
    while (tmpid)
    {
        a = [[NSString stringWithFormat:@"%d",tmpid % 2] stringByAppendingString:a];
        if (tmpid/2 < 1)
        {
            break;
        }
        tmpid = tmpid/2 ;
    }
    
    if (a.length <= length)
    {
        NSMutableString *b = [[NSMutableString alloc]init];;
        for (int i = 0; i < length - a.length; i++)
        {
            [b appendString:@"0"];
        }
        
        a = [b stringByAppendingString:a];
    }
    
    return a;
    
}

@end
