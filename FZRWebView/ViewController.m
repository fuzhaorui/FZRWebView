//
//  ViewController.m
//  FZRWebView
//
//  Created by IOS-开发机 on 15/12/8.
//  Copyright © 2015年 IOS-开发机. All rights reserved.
//

#import "ViewController.h"
#import "FZRWebViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
}

-(IBAction)start:(UIButton *)sender
{
    [FZRWebViewController showWithContro:self withUrlStr:@"http://www.huodull.com/index.html" withTitle:@"货兜"];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

@end
