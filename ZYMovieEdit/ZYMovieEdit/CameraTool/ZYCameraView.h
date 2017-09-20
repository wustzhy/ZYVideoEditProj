//
//  ZYCameraView.h
//  test_Photo
//
//  Created by 赵洋 on 2017/3/26.
//  Copyright © 2017年 赵洋. All rights reserved.
//

#import "TZImagePickerController.h"

@interface ZYCameraView : UIView


/** 最大选择数 default is 10 */
@property (nonatomic, assign) NSInteger maxSelectCount;

@property (nonatomic, weak) UIViewController *sender;

/*
 *  --------------- 挑选照片 -----------------
 */
- (void)zySelectPicturesFromLibraryWithSender:(UIViewController *)sender maxImagesCount:(NSInteger)count callBack: (void (^)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto)) cbBlock;


/*
 *  ----------------- 拍照 -----------------
 */
- (void)showPhotoTakeWithSender:(UIViewController *)sender
                        completion:(void (^)(UIImage *takenPhoto))completion;

/*
 *  ----------------- 录像 -----------------
 */
- (void)showVideoTakeWithSender:(UIViewController *)sender
                     completion:(void (^)(UIImage *thumbImage, NSURL *videoUrl))completion;


@end
