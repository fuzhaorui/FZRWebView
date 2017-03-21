//
//  FZRWebViewController.m
//  FZRWebView
//
//  Created by IOS-开发机 on 15/12/8.
//  Copyright © 2015年 IOS-开发机. All rights reserved.
//

#import "FZRWebViewController.h"
#import <WebKit/WebKit.h>

#define IOS8x ([[UIDevice currentDevice].systemVersion floatValue] >= 8.0)
#define WebViewNav_TintColor [UIColor whiteColor]
#define WebViewNavBackgroundColor [UIColor colorWithRed:70.0/255 green:96./255 blue:253./255 alpha:1]
#define WebViewProgressColor [UIColor blueColor]
@interface FZRWebViewController ()<UIWebViewDelegate,UIActionSheetDelegate,WKNavigationDelegate>
@property (assign, nonatomic) NSUInteger loadCount;
@property (strong, nonatomic) UIProgressView *progressView;
@property (strong, nonatomic) UIWebView *webView;
@property (strong, nonatomic) WKWebView *wkWebView;
@end

@implementation FZRWebViewController

/** 传入控制器、url、标题 */
+ (void)showWithContro:(UIViewController *)contro withUrlStr:(NSString *)urlStr withTitle:(NSString *)title {
    urlStr = [urlStr stringByAddingPercentEscapesUsingEncoding:NSUTF8StringEncoding];
    FZRWebViewController *webContro = [FZRWebViewController new];
    webContro.homeUrl = [NSURL URLWithString:urlStr];
    webContro.title = title;
    UINavigationController *nvc = [[UINavigationController alloc]initWithRootViewController:webContro];
    [contro presentViewController:nvc animated:YES completion:nil];
    
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    self.edgesForExtendedLayout = UIRectEdgeNone;
    self.view.backgroundColor = [UIColor whiteColor];
    [self.navigationController.navigationBar setBarTintColor: WebViewNavBackgroundColor];
    [[UINavigationBar appearance]setTitleTextAttributes:[NSDictionary dictionaryWithObjectsAndKeys:[UIColor whiteColor],NSForegroundColorAttributeName,                                             [UIFont fontWithName:@"HelveticaNeue" size:19.0], NSFontAttributeName, nil ]];
    [[UINavigationBar appearance]setTintColor:WebViewNav_TintColor];
    [self configUI];
    [self configBackItem];
    [self configMenuItem];
    
    
}

- (void)configUI {
    
    // 进度条
    UIProgressView *progressView = [[UIProgressView alloc] initWithFrame:CGRectMake(0, 0, self.view.frame.size.width, 1)];
    progressView.tintColor = WebViewProgressColor;
    progressView.trackTintColor = [UIColor whiteColor];
    [self.view addSubview:progressView];
    self.progressView = progressView;
    
    // 网页
    if (IOS8x) {
        WKWebView *wkWebView = [[WKWebView alloc] initWithFrame:self.view.bounds];
        wkWebView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        wkWebView.backgroundColor = [UIColor whiteColor];
        wkWebView.navigationDelegate = self;
        [self.view insertSubview:wkWebView belowSubview:progressView];
        
        [wkWebView addObserver:self forKeyPath:@"estimatedProgress" options:NSKeyValueObservingOptionNew context:nil];
        NSURLRequest *request = [NSURLRequest requestWithURL:_homeUrl];
        [wkWebView loadRequest:request];
        self.wkWebView = wkWebView;
    }else {
        UIWebView *webView = [[UIWebView alloc] initWithFrame:self.view.bounds];
        webView.autoresizingMask = UIViewAutoresizingFlexibleWidth|UIViewAutoresizingFlexibleHeight;
        webView.scalesPageToFit = YES;
        webView.backgroundColor = [UIColor whiteColor];
        webView.delegate = self;
        [self.view insertSubview:webView belowSubview:progressView];
        
        NSURLRequest *request = [NSURLRequest requestWithURL:_homeUrl];
        [webView loadRequest:request];
        self.webView = webView;
    }
}

- (void)configBackItem{
    
    // 导航栏的返回按钮
    UIImage *backImage = [UIImage imageNamed:@"fzr_webview_back"];
    backImage = [backImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *backBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 22)];
    [backBtn setTintColor:WebViewNav_TintColor];
    [backBtn setBackgroundImage:backImage forState:UIControlStateNormal];
    [backBtn addTarget:self action:@selector(backBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    UIBarButtonItem *backBarButtonItem = [[UIBarButtonItem alloc] initWithCustomView:backBtn];

    self.navigationItem.leftBarButtonItem = backBarButtonItem;
    

}

- (void)configMenuItem {
    
    // 导航栏的菜单按钮
    UIImage *menuImage = [UIImage imageNamed:@"fzr_webview_menu"];
    menuImage = [menuImage imageWithRenderingMode:UIImageRenderingModeAlwaysTemplate];
    UIButton *menuBtn = [[UIButton alloc] initWithFrame:CGRectMake(0, 0, 25, 40)];
    menuBtn.imageEdgeInsets = UIEdgeInsetsMake(10, 10, 10, 10);
    [menuBtn setTintColor:WebViewNav_TintColor];
    [menuBtn setImage:menuImage forState:UIControlStateNormal];
    [menuBtn addTarget:self action:@selector(menuBtnPressed:) forControlEvents:UIControlEventTouchUpInside];
    
    UIBarButtonItem *menuItem = [[UIBarButtonItem alloc] initWithCustomView:menuBtn];
    self.navigationItem.rightBarButtonItem = menuItem;
}


#pragma mark - 普通按钮事件

// 返回按钮点击
- (void)backBtnPressed:(id)sender {
    if (IOS8x) {
        if (self.wkWebView.canGoBack) {
            [self.wkWebView goBack];
        }else {
            [self dismissViewControllerAnimated:YES completion:nil];
        }
    }else {
        if (self.webView.canGoBack) {
            [self.webView goBack];
        }else {
             [self dismissViewControllerAnimated:YES completion:nil];
        }
    }
}

// 菜单按钮点击
- (void)menuBtnPressed:(id)sender {
    UIActionSheet *actionSheet = [[UIActionSheet alloc] initWithTitle:nil delegate:self cancelButtonTitle:@"取消" destructiveButtonTitle:nil otherButtonTitles:@"关闭浏览器",@"safari打开",@"复制链接",@"刷新", nil];
    [actionSheet showInView:self.view];
}

// 关闭按钮点击
- (void)colseBtnPressed:(id)sender {
     [self dismissViewControllerAnimated:YES completion:nil];
}

#pragma mark - 菜单按钮事件

- (void)actionSheet:(UIActionSheet *)actionSheet didDismissWithButtonIndex:(NSInteger)buttonIndex {
    
    NSString *urlStr = _homeUrl.absoluteString;
    if (IOS8x) urlStr = self.wkWebView.URL.absoluteString;
    else urlStr = self.webView.request.URL.absoluteString;
    if (buttonIndex == 0) {
        
        [self colseBtnPressed:nil];
    }
    if (buttonIndex == 1) {
        
        // safari打开
        [[UIApplication sharedApplication] openURL:[NSURL URLWithString:urlStr]];
    }else if (buttonIndex == 2) {
        
        // 复制链接
        if (urlStr.length > 0) {
            [[UIPasteboard generalPasteboard] setString:urlStr];
            UIAlertView *alertView = [[UIAlertView alloc] initWithTitle:@"已复制链接到黏贴板" message:nil delegate:nil cancelButtonTitle:nil otherButtonTitles:@"知道了", nil];
            [alertView show];
        }
    }else if (buttonIndex == 3) {
        
        // 刷新
        if (IOS8x) [self.wkWebView reload];
        else [self.webView reload];
        
    }
}

#pragma mark - wkWebView代理

// 如果不添加这个，那么wkwebview跳转不了AppStore
- (void)webView:(WKWebView *)webView decidePolicyForNavigationAction:(WKNavigationAction *)navigationAction decisionHandler:(void (^)(WKNavigationActionPolicy))decisionHandler {
    
   
    if ([webView.URL.absoluteString hasPrefix:@"https://itunes.apple.com"]) {
        [[UIApplication sharedApplication] openURL:navigationAction.request.URL];
        decisionHandler(WKNavigationActionPolicyCancel);
    }else {
        decisionHandler(WKNavigationActionPolicyAllow);
    }
}


// 计算wkWebView进度条
- (void)observeValueForKeyPath:(NSString *)keyPath ofObject:(id)object change:(NSDictionary *)change context:(void *)context {
    
    
    if (object == self.wkWebView && [keyPath isEqualToString:@"estimatedProgress"]) {
        CGFloat newprogress = [[change objectForKey:NSKeyValueChangeNewKey] doubleValue];
        if (newprogress == 1) {
            self.progressView.hidden = YES;
            [self.progressView setProgress:0 animated:NO];
        }else {
            self.progressView.hidden = NO;
            [self.progressView setProgress:newprogress animated:YES];
        }
    }
}

// 记得取消监听
- (void)dealloc {
    if (IOS8x) {
        [self.wkWebView removeObserver:self forKeyPath:@"estimatedProgress"];
    }
}

#pragma mark - webView代理

// 计算webView进度条
- (void)setLoadCount:(NSUInteger)loadCount {
    _loadCount = loadCount;
    if (loadCount == 0) {
        self.progressView.hidden = YES;
        [self.progressView setProgress:0 animated:NO];
    }else {
        self.progressView.hidden = NO;
        CGFloat oldP = self.progressView.progress;
        CGFloat newP = (1.0 - oldP) / (loadCount + 1) + oldP;
        if (newP > 0.95) {
            newP = 0.95;
        }
        [self.progressView setProgress:newP animated:YES];
    }
}

- (void)webViewDidStartLoad:(UIWebView *)webView {
    self.loadCount ++;
}

- (void)webViewDidFinishLoad:(UIWebView *)webView {
    self.loadCount --;
}

- (void)webView:(UIWebView *)webView didFailLoadWithError:(NSError *)error {
    self.loadCount --;
}


/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

@end
