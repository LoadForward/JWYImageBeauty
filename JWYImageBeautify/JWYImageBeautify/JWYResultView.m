//
//  JWYResultView.m
//  JWYImageBeautify
//
//  Created by SoSee_Tech_01 on 17/3/1.
//  Copyright © 2017年 SoSee_Tech_01. All rights reserved.
//

#import "JWYResultView.h"

@implementation JWYResultView
{
    UIImageView *_centerResultView;
    UIButton *_retakeBtn;
}

- (instancetype)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        [self createView];
        self.backgroundColor = [UIColor orangeColor];
    }
    return self;
}

- (void)setSelectedImage:(UIImage *)selectedImage
{
    if (_selectedImage != selectedImage) {
        _selectedImage = selectedImage;
    }
    _centerResultView.image = self.selectedImage;
}

- (void)createView
{
    _centerResultView = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, kScreenHeight)];
    _centerResultView.contentMode = UIViewContentModeScaleAspectFit;
    [self addSubview:_centerResultView];
    
    _retakeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _retakeBtn.frame = CGRectMake((kScreenWidth - 80) / 2, kScreenHeight - 80, 80, 80);
    [_retakeBtn setImage:[UIImage imageNamed:@"zipai-chongpai"] forState:UIControlStateNormal];
    [_retakeBtn addTarget:self action:@selector(retakeBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [self addSubview:_retakeBtn];
    
}

//重拍
- (void)retakeBtnClick
{
    [[NSNotificationCenter defaultCenter] postNotificationName:@"retake" object:nil];
}

@end
