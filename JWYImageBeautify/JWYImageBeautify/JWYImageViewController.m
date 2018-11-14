//
//  JWYImageViewController.m
//  JWYImageBeautify
//
//  Created by SoSee_Tech_01 on 17/3/1.
//  Copyright © 2017年 SoSee_Tech_01. All rights reserved.
//

#import "JWYImageViewController.h"
#import "JWYImageBeautifyFilter.h"
#import "JWYResultView.h"

typedef void(^PropertyChangeBlock)(AVCaptureDevice *captureDevice);

@interface JWYImageViewController ()
{
    UIView *_topCtrlView;
    UIView *_bottomCtrlView;
    JWYResultView *_resultView;
    
    int state;
    
    JWYImageBeautifyFilter *beautifyFilter;
    GPUImageOutput<GPUImageInput> *secondFilter;
}

@property (strong,nonatomic) AVCaptureDeviceInput *captureDeviceInput;//负责从AVCaptureDevice获得输入数据

//GPUImage
@property(nonatomic,strong)GPUImageStillCamera *videoCamera;
@property(nonatomic,strong)GPUImageView *filterView;
@property(nonatomic,strong)UIButton *beautiBtn;
@property(readwrite) AVCaptureDevice *device;


@end

@implementation JWYImageViewController

- (void)viewDidLoad {
    [super viewDidLoad];

    [[NSNotificationCenter defaultCenter] addObserver:self selector:@selector(getRetakeNoti) name:@"retake" object:nil];

    [self _initCtrlView];
}

#pragma mark -重新拍摄通知接收
- (void)getRetakeNoti
{
    _resultView.hidden = YES;
    [_resultView removeFromSuperview];
    _resultView = nil;
}


#pragma mark -GPUImage
//创建GPU相机
- (void)initGPUImageCameraWithPosition:(AVCaptureDevicePosition)position
{
    self.videoCamera = [[GPUImageStillCamera alloc]initWithSessionPreset:AVCaptureSessionPreset1280x720 cameraPosition:position];
    self.videoCamera.outputImageOrientation =  UIDeviceOrientationPortrait;
    self.videoCamera.horizontallyMirrorFrontFacingCamera = YES;
    self.filterView = [[GPUImageView alloc]initWithFrame:self.view.frame];
    self.filterView.center = self.view.center;
    
    [self.view insertSubview:self.filterView belowSubview:_topCtrlView];
    
    //添加美颜滤镜
    beautifyFilter = [[JWYImageBeautifyFilter alloc]init];
    [self.videoCamera addTarget:beautifyFilter];
    [beautifyFilter addTarget:self.filterView];
    
    [self.videoCamera startCameraCapture];
}


- (void)_initCtrlView {
    
    _topCtrlView = [[UIView alloc] initWithFrame:CGRectMake(0, 0, kScreenWidth, 64)];
    UIColor *color = [UIColor blackColor];
    color = [color colorWithAlphaComponent:0.5];
    _topCtrlView.backgroundColor = color;
    [self.view addSubview:_topCtrlView];
    
    UIButton *_returnBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_returnBtn setImage:[UIImage imageNamed:@"hh-fanhui"] forState:UIControlStateNormal];
    _returnBtn.frame = CGRectMake(0, 20, 60, 44);
    [_returnBtn addTarget:self action:@selector(returnBtnClick) forControlEvents:UIControlEventTouchUpInside];
    [_topCtrlView addSubview:_returnBtn];
    
    UIButton *_flashStateBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    _flashStateBtn.tag = 249;
    [_flashStateBtn setImage:[UIImage imageNamed:@"z_zidong"] forState:UIControlStateNormal];
    _flashStateBtn.frame = CGRectMake(kScreenWidth / 3, 20, kScreenWidth / 3, 44);
    [_flashStateBtn addTarget:self action:@selector(flashStateBtnClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topCtrlView addSubview:_flashStateBtn];
    
    UIButton *_changeBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_changeBtn setImage:[UIImage imageNamed:@"zhuanhuan"] forState:UIControlStateNormal];
    _changeBtn.frame = CGRectMake(kScreenWidth - 60, 20, 60, 44);
    [_changeBtn addTarget:self action:@selector(changeClick:) forControlEvents:UIControlEventTouchUpInside];
    [_topCtrlView addSubview:_changeBtn];
    
    _bottomCtrlView = [[UIView alloc] initWithFrame:CGRectMake(0, kScreenHeight - 64, kScreenWidth, 64)];
    _bottomCtrlView.backgroundColor = color;
    [self.view addSubview:_bottomCtrlView];
    
    UIButton *_takePhotoBtn = [UIButton buttonWithType:UIButtonTypeCustom];
    [_takePhotoBtn setImage:[UIImage imageNamed:@"e_phone"] forState:UIControlStateNormal];
    _takePhotoBtn.frame = CGRectMake((kScreenWidth - 60) / 2, 2, 60, 60);
    [_takePhotoBtn addTarget:self action:@selector(takePhoto) forControlEvents:UIControlEventTouchUpInside];
    [_bottomCtrlView addSubview:_takePhotoBtn];
    
    [self initGPUImageCameraWithPosition:AVCaptureDevicePositionFront];
}

#pragma mark -点击事件
- (void)returnBtnClick
{
    [self dismissViewControllerAnimated:YES completion:nil];
}

//闪光灯
- (void)flashStateBtnClick:(UIButton *)btn
{
    NSString *tips = nil;
    
    if (self.videoCamera.inputCamera.position != AVCaptureDevicePositionBack) {
        tips = @"前置摄像头无法开启闪光灯";
//        [self flashStateTipsWithTitle:tips];
        return;
    }
    
    state++;
    
    int flashState = state % 3;
    NSLog(@"%d", state);
    
    
    switch (flashState) {
        case 0:
            [btn setImage:[UIImage imageNamed:@"z_zidong"] forState:UIControlStateNormal];
            [self setFlashMode:AVCaptureFlashModeAuto];
            tips = @"闪光灯自动";
            break;
        case 1:
            [btn setImage:[UIImage imageNamed:@"z_dakai"] forState:UIControlStateNormal];
            [self.videoCamera.inputCamera lockForConfiguration:nil];
            [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOn];
            [self.videoCamera.inputCamera unlockForConfiguration];
            tips = @"闪光灯已打开";
            
            break;
        case 2:
            [btn setImage:[UIImage imageNamed:@"z_guanbi"] forState:UIControlStateNormal];
            [self.videoCamera.inputCamera lockForConfiguration:nil];
            [self.videoCamera.inputCamera setTorchMode:AVCaptureTorchModeOff];
            [self.videoCamera.inputCamera unlockForConfiguration];
            tips = @"闪光灯已关闭";
            break;
        default:
            break;
    }
}
//闪光灯状态
-(void)setFlashMode:(AVCaptureFlashMode )flashMode{
    [self changeDeviceProperty:^(AVCaptureDevice *captureDevice) {
        if ([captureDevice isFlashModeSupported:flashMode]) {
            [captureDevice setFlashMode:flashMode];
        }
    }];
}



//切换摄像头
- (void)changeClick:(UIButton *)btn
{
    [self.videoCamera stopCameraCapture];
    if (btn.tag == 0) {
        
        [self initGPUImageCameraWithPosition:AVCaptureDevicePositionBack];
        
        btn.tag = 1;
        //前摄像头需要镜像。。
    }else{
        
        [self initGPUImageCameraWithPosition:AVCaptureDevicePositionFront];
        
        btn.tag = 0;
        //后摄像头不需要镜像
    }
}

- (void)takePhoto
{
    GPUImageFilterGroup *filterGroup;
    
    filterGroup = beautifyFilter;
    
    //获取图片源
    [self.videoCamera capturePhotoAsJPEGProcessedUpToFilter:filterGroup withCompletionHandler:^(NSData *processedJPEG, NSError *error){
        
        
        UIImage *inputImage = [UIImage imageWithData:processedJPEG];
        
        if (_resultView == nil) {
            _resultView = [[JWYResultView alloc] initWithFrame:self.view.bounds];
            _resultView.selectedImage = inputImage;
            [self.view addSubview:_resultView];
        }
        
        UIImageWriteToSavedPhotosAlbum(inputImage, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        
    }];
    
}

//保存图片到本地相册
- (void)image: (UIImage *) image didFinishSavingWithError: (NSError *) error contextInfo: (void *) contextInfo
{
    NSString *msg = nil ;
    if(error != NULL){
        msg = @"保存图片失败" ;
        NSLog(@"%@", msg);
    }else{
        msg = @"照片已保存" ;
        NSLog(@"%@", msg);
    }
}


#pragma mark - 私有方法

/**
 *  取得指定位置的摄像头
 *
 *  @param position 摄像头位置
 *
 *  @return 摄像头设备
 */


/**
 *  改变设备属性的统一操作方法
 *
 *  @param propertyChange 属性改变操作
 */
-(void)changeDeviceProperty:(PropertyChangeBlock)propertyChange{
    AVCaptureDevice *captureDevice= [self.captureDeviceInput device];
    NSError *error;
    //注意改变设备属性前一定要首先调用lockForConfiguration:调用完之后使用unlockForConfiguration方法解锁
    if ([captureDevice lockForConfiguration:&error]) {
        propertyChange(captureDevice);
        [captureDevice unlockForConfiguration];
    }else{
        //        NSLog(@"设置设备属性过程发生错误，错误信息：%@",error.localizedDescription);
    }
}



@end
