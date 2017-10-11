//
//  UIViewController+Swizzle.m
//  Weiyun
//
//  Created by saucym on 15/1/22.
//  Copyright (c) 2015年 tencent. All rights reserved.
//

#import "UIViewController+Swizzle.h"
#import <objc/runtime.h>
#import "JRSwizzle.h"

@interface UIViewController()


@end

@implementation UIViewController (Swizzle)

+ (void)load
{
    [self jr_swizzleMethod:@selector(viewDidAppear:) withMethod:@selector(sw_viewDidAppear:) error:NULL];
    [self jr_swizzleMethod:@selector(viewWillAppear:) withMethod:@selector(sw_viewWillAppear:) error:NULL];
    [self jr_swizzleMethod:@selector(viewDidLoad) withMethod:@selector(sw_viewDidLoad) error:NULL];
    [self jr_swizzleMethod:@selector(viewWillDisappear:) withMethod:@selector(sw_viewWillDisappear:) error:NULL];
}

- (void)sw_viewDidLoad
{
    [self sw_viewDidLoad];

}

- (void)sw_viewWillAppear:(BOOL)animated
{
    [self sw_viewWillAppear:animated];
}

- (void)sw_viewDidAppear:(BOOL)animated
{
    [self sw_viewDidAppear: animated];
    
}

- (void)sw_viewWillDisappear:(BOOL)animated {
    [self sw_viewWillDisappear:animated];

}



@end






















