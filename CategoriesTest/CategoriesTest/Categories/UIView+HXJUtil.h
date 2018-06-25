//
//  UIView+HXJUtil.h
//  CategoriesTest
//
//  Created by mayiAngel on 2018/6/25.
//  Copyright © 2018年 test. All rights reserved.
//

#import <UIKit/UIKit.h>

#define iPhoneXBottomMargin 34

@interface UIView (HXJUtil)

///返回视图是否被键盘遮盖，若是，offset 的值表示视图要避免遮盖的位移量
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset;

///计算的遮盖值 offset 要忽略 ignoreOffset 值
///这是因为在 iPhone X 设备中，底部输入框视图高度可能包含了设备底部虚拟按钮部分，所以随键盘上移时，忽略相应的高度
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset ignoreOffset:(CGFloat)ignoreOffset;

///判断当前视图是否被其他视图遮盖
- (BOOL)isCoveredByView:(UIView *)view offset:(CGFloat *)offset;

///是否可见
- (BOOL)isViewVisiable;

///添加键盘收起事件
- (void)addGestureHideKeyboard:(UIView *)shouldendEditingView;

/**
 注册键盘变化事件，如果当前控件被遮盖，则作出相应的移动
 @param shouldMovedView 键盘变化时，应该移动的控件，如果为 nil ，则默认为当前控件移动
 */
- (void)registerKeyboardChangeNotification:(UIView *)shouldMovedView;

///取消键盘变化监听事件
- (void)unregisterKeyboardChangeNotification;

@end
