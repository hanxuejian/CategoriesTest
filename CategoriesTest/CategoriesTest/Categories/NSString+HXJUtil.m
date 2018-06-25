//
//  NSString+HXJUtil.m
//  CategoriesTest
//
//  Created by mayiAngel on 2018/6/25.
//  Copyright © 2018年 test. All rights reserved.
//

#import "NSString+HXJUtil.h"

@implementation NSString (HXJUtil)

#pragma mark - 返回处理指定 string 的富文本
- (NSAttributedString *)attributedStringOfString:(NSString *)string
                                       baseColor:(UIColor *)baseColor
                                        baseFont:(UIFont *)baseFont
                                     targetColor:(UIColor *)targetColor
                                      targetFont:(UIFont *)targetFont
{
    NSMutableAttributedString *attr = [[NSMutableAttributedString alloc]initWithString:self];
    [attr addAttribute:NSFontAttributeName value:baseFont range:NSMakeRange(0, self.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:baseColor range:NSMakeRange(0, self.length)];
    
    NSRange range = [self rangeOfString:string options:NSBackwardsSearch];
    [attr addAttribute:NSFontAttributeName value:targetFont range:NSMakeRange(0, self.length)];
    [attr addAttribute:NSForegroundColorAttributeName value:targetColor range:range];
    
    return [attr copy];
}


@end
