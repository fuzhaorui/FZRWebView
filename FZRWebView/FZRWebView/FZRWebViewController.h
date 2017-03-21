//
//  FZRWebViewController.h
//  FZRWebView
//
//  Created by IOS-开发机 on 15/12/8.
//  Copyright © 2015年 IOS-开发机. All rights reserved.
//

#import <UIKit/UIKit.h>

@interface FZRWebViewController : UIViewController

@property (strong, nonatomic) NSURL *homeUrl;

/** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title;


@end
