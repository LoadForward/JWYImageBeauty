//
//  JWYRootViewController.m
//  JWYImageBeautify
//
//  Created by SoSee_Tech_01 on 17/3/1.
//  Copyright © 2017年 SoSee_Tech_01. All rights reserved.
//

#import "JWYRootViewController.h"
#import "JWYImageViewController.h"

@interface JWYRootViewController ()

@end

@implementation JWYRootViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    UIButton *enterBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    enterBtn.frame = CGRectMake(0, kScreenHeight * 0.4, kScreenWidth, 40);
    enterBtn.backgroundColor = [UIColor orangeColor];
    [enterBtn setTitle:@"进入美颜相机" forState:UIControlStateNormal];
    [enterBtn addTarget:self action:@selector(enterBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:enterBtn];
}

- (void)enterBtnClick
{
    JWYImageViewController *imageVC = [[JWYImageViewController alloc] init];
    [self presentViewController:imageVC animated:YES completion:nil];
}

@end
