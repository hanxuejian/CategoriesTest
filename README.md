# 自定义分类
有些情况使用分类比创建子类更加方便，也更能提高编码效率。

## 例子一
将字典中的数据解析为指定的数据模型，在设计时，将所有的类属性名称同字典的键相同，解析时，遍历类的所有属性进行赋值，避免字典中存在类中没有的属性键。

创建一个 NSObject 的分类，如下：

```
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

```

而后，在设计数据模型类时，声明同后台获取的字段相同的属性，再声明初始化方法。

```
- (instancetype)initWithDic:(NSDictionary *)dataDic {
    if (self = [self init]) {
        NSArray *properties = [self allPropertiesName];
        for (NSString *key in [dataDic allKeys]) {
            if ([properties containsObject:key]) {
                [self setValue:dataDic[key] forKey:key];
            }
        }
    }
    return self;
}
```

## 例子二
对于视图，尤其是输入框，存在被键盘遮盖的情况，所以可以设计一个视图分类来监听键盘变化事件，进行相应的处理。

下面的代码实现视图监听键盘变化的快速注册，并且可以绑定当键盘变化时，应该进行相应变化的视图。

```
@interface UIView (HXJUtil)

///返回视图是否被键盘遮盖，若是，offset 的值表示视图要避免遮盖的位移量
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset;

/**
 注册键盘变化事件，如果当前控件被遮盖，则作出相应的移动
 @param shouldMovedView 键盘变化时，应该移动的控件，如果为 nil ，则默认为当前控件移动
 */
- (void)registerKeyboardChangeNotification:(UIView *)shouldMovedView;

///取消键盘变化监听事件
- (void)unregisterKeyboardChangeNotification;

@end
```

```
@implementation UIView (HXJUtil)

#pragma mark 判断当前视图是否被键盘遮盖
- (BOOL)isCoveredByBoard:(CGRect)keyboardRect offset:(CGFloat *)offset {
    if (!self) {
        return NO;
    }
    if (![self superview]) {
        return NO;
    }
    if (self.hidden) {
        return NO;
    }
    UIWindow *keyWindow = [[UIApplication sharedApplication] keyWindow];
    NSArray *windows = [[UIApplication sharedApplication] windows];
    UIWindow *keyboardWindow;
    for (id window in windows) {
        
        NSString *keyboardWindowString = NSStringFromClass([window class]);
        if ([keyboardWindowString isEqualToString:@"UITextEffectsWindow"]) {
            keyboardWindow = window;
            break;
        }
    }
    if (keyboardWindow == nil) return NO;
    
    keyboardRect = [keyboardWindow convertRect:keyboardRect toWindow:keyWindow];
    CGRect rect = [self.superview convertRect:self.frame toView:keyWindow];
    if (CGRectIsEmpty(rect) || CGRectIsNull(rect) || CGSizeEqualToSize(rect.size, CGSizeZero)) {
        return NO;
    }
    CGFloat heightOfCovered = keyboardRect.origin.y - rect.origin.y - rect.size.height;
    heightOfCovered = heightOfCovered > -keyboardRect.size.height ? heightOfCovered : -keyboardRect.size.height;
    
    *offset = heightOfCovered;
    return CGRectIntersectsRect(rect, keyboardRect);
}

#pragma mark - 注册键盘显示及隐藏事件
const void *shouldMovedViewKey = &shouldMovedViewKey;
const void *shouldMovedViewOriginFrameKey = &shouldMovedViewOriginFrameKey;
const void *shouldMovedViewContentOffsetKey = &shouldMovedViewContentOffsetKey;

- (void)registerKeyboardChangeNotification:(UIView *)shouldMovedView {
    
    [[NSNotificationCenter defaultCenter]addObserver:self selector:@selector(keyboardWillChange:) name:UIKeyboardWillChangeFrameNotification object:nil];
    
    objc_setAssociatedObject(self, shouldMovedViewKey, shouldMovedView, OBJC_ASSOCIATION_ASSIGN);
    
}

#pragma mark 取消键盘变化监听事件
- (void)unregisterKeyboardChangeNotification {
    [[NSNotificationCenter defaultCenter] removeObserver:self name:UIKeyboardWillChangeFrameNotification object:nil];
    objc_setAssociatedObject(self, shouldMovedViewKey, nil, OBJC_ASSOCIATION_ASSIGN);
}

#pragma mark 键盘变化
- (void)keyboardWillChange:(NSNotification *)notification {
    if (!self.isFirstResponder) return;
    CGRect keyboardBeginFrame = [[notification.userInfo objectForKey:UIKeyboardFrameBeginUserInfoKey] CGRectValue];
    CGRect keyboardEndFrame = [[notification.userInfo objectForKey:UIKeyboardFrameEndUserInfoKey] CGRectValue];
    
    UIView *view = objc_getAssociatedObject(self, shouldMovedViewKey);
    if (view == nil) view = self;
    
    CGFloat viewBottom = [UIScreen mainScreen].bounds.size.height;
    
    BOOL isShow = keyboardBeginFrame.origin.y >= viewBottom;
    
    if (isShow) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            objc_setAssociatedObject(self, shouldMovedViewContentOffsetKey, @(scrollView.contentOffset), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }else {
            objc_setAssociatedObject(self, shouldMovedViewOriginFrameKey, @(view.frame), OBJC_ASSOCIATION_RETAIN_NONATOMIC);
        }
    }
    
    BOOL isHide = keyboardEndFrame.origin.y >= viewBottom;
    
    //键盘隐藏
    if (isHide) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            CGPoint point = [objc_getAssociatedObject(self, shouldMovedViewContentOffsetKey) CGPointValue];
            [scrollView setContentOffset:point animated:YES];
        }else {
            CGRect rect = [objc_getAssociatedObject(self, shouldMovedViewOriginFrameKey) CGRectValue];
            view.frame = rect;
        }
        return;
    }
    
    //键盘变化
    CGFloat offset;
    if ([self isCoveredByBoard:keyboardEndFrame offset:&offset]) {
        if ([view isKindOfClass:[UIScrollView class]]) {
            UIScrollView *scrollView = (UIScrollView *)view;
            offset = scrollView.contentOffset.y - offset + 10;
            [scrollView setContentOffset:CGPointMake(0, offset) animated:YES];
        }else {
            CGRect rect = view.frame;
            rect.origin.y += offset - 10;
            view.frame = rect;
        }
    }
}
```

可以[参见测试程序](https://github.com/hanxuejian/CategoriesTest)

类似的还有很多，总之学会找寻问题的相似点，并对比各个解决方案，进行归纳总结，抽象出通用的方案，那么才能更好的提升自己。