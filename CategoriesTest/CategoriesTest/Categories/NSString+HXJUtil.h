//
//  NSString+HXJUtil.h
//  CategoriesTest
//
//  Created by mayiAngel on 2018/6/25.
//  Copyright © 2018年 test. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

@interface NSString (HXJUtil)

///返回指定样式的富文本
- (NSAttributedString *)attributedStringOfString:(NSString *)string
                                       baseColor:(UIColor *)baseColor
                                        baseFont:(UIFont *)baseFont
                                     targetColor:(UIColor *)targetColor
                                      targetFont:(UIFont *)targetFont;

@end
