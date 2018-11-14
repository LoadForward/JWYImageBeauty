//
//  JWYImageBeautifyFilter.h
//  JWYImageBeautify
//
//  Created by SoSee_Tech_01 on 17/3/1.
//  Copyright © 2017年 SoSee_Tech_01. All rights reserved.
//

#import <GPUImage/GPUImage.h>
@class GPUImageCombinationFilter;

@interface JWYImageBeautifyFilter : GPUImageFilterGroup
{
    GPUImageBilateralFilter *bilateralFilter;
    GPUImageCannyEdgeDetectionFilter *cannyEdgeFilter;
    GPUImageCombinationFilter *combinationFilter;
    GPUImageHSBFilter *hsbFilter;
}
@end
