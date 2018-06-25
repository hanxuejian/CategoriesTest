//
//  NSObject+HXJUtil.m
//  CategoriesTest
//
//  Created by mayiAngel on 2018/6/25.
//  Copyright © 2018年 test. All rights reserved.
//

#import "NSObject+HXJUtil.h"

#import <objc/runtime.h>

@implementation NSObject (HXJUtil)

#pragma mark - 获取类的所有属性名称
- (NSArray *)allPropertiesName {
    NSMutableArray *array = [NSMutableArray array];
    unsigned int outCount;
    objc_property_t *properties = class_copyPropertyList([self class],&outCount);
    for (int i = 0;i<outCount;i++,properties++) {
        [array addObject:[[NSString alloc]initWithUTF8String:property_getName(*properties)]];
    }
    return [array copy];
}

@end
