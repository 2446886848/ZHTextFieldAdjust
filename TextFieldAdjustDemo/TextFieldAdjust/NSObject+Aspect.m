//
//  NSObject+Aspect.m
//  RACCommandExample
//
//  Created by 吴志和 on 15/10/20.
//  Copyright © 2015年 SHAPE. All rights reserved.
//

#import "NSObject+Aspect.h"
#import "Aspects.h"
#import "ReactiveCocoa.h"

@class TempClass;

static TempClass *tempObject = nil;

//内部用来设置钩子的子类
@interface TempClass : NSObject

@property (nonatomic, weak) UIView *firstResponser;
@property (nonatomic, strong) NSMutableArray *controllerViews;

@end

@implementation TempClass

- (instancetype)init
{
    self = [super init];
    if (self) {
        self.controllerViews = @[].mutableCopy;
        [self setupHook];
    }
    return self;
}

- (void)setupHook
{
    //管理所有控制器的view
    [self setControllerHook];
    //设置输入框的钩子
    [self setHookForViewType:[UITextField class]];
    
    //监听键盘弹出通知
    @weakify(self)
    [[[NSNotificationCenter defaultCenter] rac_addObserverForName:UIKeyboardDidChangeFrameNotification object:nil] subscribeNext:^(NSNotification *no) {
        @strongify(self)
        CGRect keyBoardFrame = [[no userInfo][@"UIKeyboardFrameEndUserInfoKey"] CGRectValue];
        UIView *textField = self.firstResponser;
        UIView *rootView = [self rootViewOfView:textField];
        CGRect textFieldRect = [textField.superview convertRect:textField.frame toView:textField.window];
        CGRect interRect = CGRectIntersection(textFieldRect, keyBoardFrame);
        if (CGRectGetHeight(interRect) != 0) {
            CGFloat offset = CGRectGetMinY(keyBoardFrame) - CGRectGetMaxY(textFieldRect) - 10;
            [UIView animateWithDuration:0.1 animations:^{
                rootView.transform = CGAffineTransformMakeTranslation(0, offset);
            }];
        }
    }];
}

/**
 *  勾取viewController的viewDidAppear:和viewWillDisappear:函数
 */
- (void)setControllerHook
{
    @weakify(self)
    [UIViewController aspect_hookSelector:@selector(viewDidAppear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        @strongify(self)
        
        UIViewController *vc = [aspectInfo instance];
        if ([vc isKindOfClass:[UINavigationController class]] ||
            [vc isKindOfClass:[UITabBarController class]]) {
            return ;
        }
        if (vc.view && [vc.view isKindOfClass:[UIView class]]) {
            [self.controllerViews addObject:vc.view];
        }
    } error:nil];
    
    [UIViewController aspect_hookSelector:@selector(viewWillDisappear:) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        @strongify(self)
        UIViewController *vc = [aspectInfo instance];
        if (vc.view) {
            [self.controllerViews removeObject:vc.view];
        }
    } error:nil];
}

/**
 *  勾取控件类型
 *
 *  @param viewClass 要勾取的类型
 */
- (void)setHookForViewType:(Class) viewClass
{
    @weakify(self)
    [viewClass aspect_hookSelector:@selector(becomeFirstResponder) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        @strongify(self)
        UITextField *textField = [aspectInfo instance];
        self.firstResponser = textField;
    } error:nil];
    
    [viewClass aspect_hookSelector:@selector(resignFirstResponder) withOptions:AspectPositionAfter usingBlock:^(id<AspectInfo> aspectInfo){
        @strongify(self)
        UITextField *textField = [aspectInfo instance];
        self.firstResponser = nil;
        [UIView animateWithDuration:0.1 animations:^{
            [self rootViewOfView:textField].transform = CGAffineTransformIdentity;
        }];
    } error:nil];
}
- (UIView *)rootViewOfView:(UIView *)inputView
{
    __block UIView *rootView = nil;
    
    [self.controllerViews enumerateObjectsWithOptions:NSEnumerationReverse usingBlock:^(id  _Nonnull obj, NSUInteger idx, BOOL * _Nonnull stop) {
        if ([obj isKindOfClass:[UIView class]]) {
            if ([inputView isDescendantOfView:obj]) {
                rootView = (UIView *)obj;
                *stop = YES;
            }
        }
    }];
    return rootView;
}
@end


#pragma mark - 调用load方法执行钩子类初始化
@implementation NSObject (Aspect)

+ (void)load
{
    if (!tempObject) {
        tempObject = [[TempClass alloc] init];
    }
}

@end
