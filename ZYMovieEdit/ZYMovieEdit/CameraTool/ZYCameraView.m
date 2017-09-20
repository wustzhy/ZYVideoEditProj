//
//  ZYCameraView.m
//  test_Photo
//
//  Created by 赵洋 on 2017/3/26.
//  Copyright © 2017年 赵洋. All rights reserved.
//

#import "ZYCameraView.h"

#import <AVFoundation/AVFoundation.h>   //解决获取第一帧warning

#import <MobileCoreServices/MobileCoreServices.h>
#import <MediaPlayer/MediaPlayer.h>

#import <AssetsLibrary/AssetsLibrary.h>  // 取视频
// 视频URL路径
#define KVideoUrlPath   \
[[NSSearchPathForDirectoriesInDomains(NSCachesDirectory, NSUserDomainMask, YES) objectAtIndex:0] stringByAppendingPathComponent:@"VideoURL"]


#define ScreenF [[UIScreen mainScreen] bounds]

// 拍照回调
typedef void (^ZYTakePhotoCBBlock)(UIImage *takenPhoto);
// 录像回调
typedef void(^ZYTakeVideoCBblock)(UIImage *thumbImage, NSURL *videoUrl);

@interface ZYCameraView()<UIImagePickerControllerDelegate, UINavigationControllerDelegate,TZImagePickerControllerDelegate>

@property(nonatomic,copy) ZYTakePhotoCBBlock takePhotoCBBlock;
@property(nonatomic,copy) ZYTakeVideoCBblock takeVideoCBBlock;

@property(nonatomic,strong) UIImage * photoTaken;

@property(nonatomic,strong) UIImage * thumbImage;
@property(nonatomic,strong) NSURL * videoUrl;

@property(nonatomic,strong) TZImagePickerController * imgSelVC;


@end

@implementation ZYCameraView

-(void)dealloc{
    
    NSLog(@" --- --- %s --- --- ",__func__);
}

//-(instancetype)init{        // 必须有，否则走父类的
//    if(self =[super init]){
//        self.frame = ScreenF;
//        
//        self.zlView = [[ZLPhotoActionSheet alloc]init];
//        self.zlView.frame = self.frame;
//        [self addSubview:self.imgSelVC];
//    }
//    return (ZYCameraView *)self;
//}


- (void)zySelectPicturesFromLibraryWithSender:(UIViewController *)sender maxImagesCount:(NSInteger)count callBack: (void (^)(NSArray<UIImage *> *photos,NSArray *assets,BOOL isSelectOriginalPhoto)) cbBlock;
{
    self.sender = sender;
    TZImagePickerController *imagePickerVc = [[TZImagePickerController alloc] initWithMaxImagesCount:count delegate:self];
    imagePickerVc.sortAscendingByModificationDate = NO; //时间升序？NO
    
    imagePickerVc.allowTakePicture = YES; // 在内部显示拍照按钮
    imagePickerVc.allowPickingOriginalPhoto = NO; //允许原图
    imagePickerVc.sortAscendingByModificationDate = NO; //拍照按钮是否显示在第一个, 照片升序排列
    imagePickerVc.maxImagesCount = 4;
    imagePickerVc.showSelectBtn = NO;
    imagePickerVc.allowCrop = NO;
    imagePickerVc.allowPickingVideo = NO;
    
    // You can get the photos by block, the same as by delegate.
    // 你可以通过block或者代理，来得到用户选择的照片.
    [imagePickerVc setDidFinishPickingPhotosHandle:cbBlock];
    [self.sender presentViewController:imagePickerVc animated:YES completion:nil];
}



- (void)showPhotoTakeWithSender:(UIViewController *)sender
                     completion:(void (^)(UIImage *takenPhoto))completion;
{
    self.takePhotoCBBlock = completion;
    self.sender = sender;
    
    if (![self judgeIsHaveCameraAuthority]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"拍照" message:@"在“设置-隐私-相机”中开启口即可使用拍照功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的，马上去设置" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self.sender presentViewController:alert animated:YES completion:nil];
        return;
    }
    //拍照
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.mediaTypes = @[(NSString *)kUTTypeImage,(NSString *)kUTTypeMovie];
        picker.videoQuality = UIImagePickerControllerQualityTypeLow;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        [self.sender presentViewController:picker animated:YES completion:nil];
    }
    
}


- (void)showVideoTakeWithSender:(UIViewController *)sender
                     completion:(void (^)(UIImage *thumbImage, NSURL *videoUrl))completion;
{
    self.takeVideoCBBlock = completion;
    self.sender = sender;
    
    if (![self judgeIsHaveCameraAuthority]) {
        
        UIAlertController *alert = [UIAlertController alertControllerWithTitle:@"摄像" message:@"在“设置-隐私-相机”中开启口即可使用摄像功能" preferredStyle:UIAlertControllerStyleAlert];
        UIAlertAction *action = [UIAlertAction actionWithTitle:@"好的，马上去设置" style:UIAlertActionStyleDefault handler:nil];
        [alert addAction:action];
        [self.sender presentViewController:alert animated:YES completion:nil];
        return;
    }
    //录像
    if ([UIImagePickerController isSourceTypeAvailable:
         UIImagePickerControllerSourceTypeCamera])
    {
        UIImagePickerController *picker = [[UIImagePickerController alloc] init];
        picker.delegate = self;
        picker.allowsEditing = NO;
        picker.mediaTypes = @[(NSString *)kUTTypeMovie/*,(NSString *)kUTTypeImage*/];
        picker.videoQuality = UIImagePickerControllerQualityTypeHigh;
        picker.sourceType = UIImagePickerControllerSourceTypeCamera;
        picker.cameraCaptureMode = UIImagePickerControllerCameraCaptureModeVideo;//video
        [self.sender presentViewController:picker animated:YES completion:nil];
    }

    
}

#pragma mark - UIImagePickerControllerDelegate
//适用获取所有媒体资源，只需判断资源类型
- (void)imagePickerController:(UIImagePickerController *)picker didFinishPickingMediaWithInfo:(NSDictionary<NSString *,id> *)info{
    NSString *mediaType=[info objectForKey:UIImagePickerControllerMediaType];
    //判断资源类型
    if ([mediaType isEqualToString:(NSString *)kUTTypeImage]){
        //如果是图片
        UIImage * image = info[UIImagePickerControllerOriginalImage];
        if(image == nil){
            return;
        }

        //回调传值
        self.photoTaken = image;
        
        //压缩图片
        //NSData *fileData = UIImageJPEGRepresentation(image, 1.0);
        //保存图片至相册
        UIImageWriteToSavedPhotosAlbum(image, self, @selector(image:didFinishSavingWithError:contextInfo:), NULL);
        //上传图片
        //[self uploadImageWithData:fileData];
        
    }else{
        //如果是视频
        NSURL *url = info[UIImagePickerControllerMediaURL];
        
        //获取第一帧 图片
        //MPMoviePlayerController *player = [[MPMoviePlayerController alloc]initWithContentURL:url] ;
        //UIImage  *thumbnail = [player thumbnailImageAtTime:1.0 timeOption:MPMovieTimeOptionNearestKeyFrame];                  //ios7过期warning
        //player = nil;//释放player
        UIImage  *thumbnail = [self getVideoPreViewImage:url];
        
        //回调传值
        self.thumbImage = thumbnail;
        self.videoUrl = url;
        
        //保存视频至相册（异步线程）
        NSString *urlStr = [url path];
        
        dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
            if (UIVideoAtPathIsCompatibleWithSavedPhotosAlbum(urlStr)) {
                
                UISaveVideoAtPathToSavedPhotosAlbum(urlStr, self, @selector(video:didFinishSavingWithError:contextInfo:), nil);
                
            }
        });
        //NSData *videoData = [NSData dataWithContentsOfURL:url];
        //视频上传
        //[self uploadVideoWithData:videoData];
    }
    [picker dismissViewControllerAnimated:YES completion:nil];
}



#pragma mark 图片保存完毕的回调
- (void) image: (UIImage *) image didFinishSavingWithError:(NSError *) error contextInfo: (void *)contextInf{
    if (error) {
        NSLog(@"保存图片过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"图片保存成功.");
        NSLog(@"%@",[NSThread currentThread]);  //
        if(self.takePhotoCBBlock){
            self.takePhotoCBBlock(self.photoTaken);
        }
        
    }
}
#pragma mark 视频保存完毕的回调
- (void)video:(NSString *)videoPath didFinishSavingWithError:(NSError *)error contextInfo:(void *)contextInf{
    if (error) {
        NSLog(@"保存视频过程中发生错误，错误信息:%@",error.localizedDescription);
    }else{
        NSLog(@"视频保存成功.");
        NSLog(@"%@",[NSThread currentThread]);  // main thread
        if(self.takeVideoCBBlock){
            self.takeVideoCBBlock(self.thumbImage,self.videoUrl);
        }
    }
}




- (UIImage*) getVideoPreViewImage:(NSURL *)path
{
    AVURLAsset *asset = [[AVURLAsset alloc] initWithURL:path options:nil];
    AVAssetImageGenerator *assetGen = [[AVAssetImageGenerator alloc] initWithAsset:asset];
    
    assetGen.appliesPreferredTrackTransform = YES;
    CMTime time = CMTimeMakeWithSeconds(0.0, 600);
    NSError *error = nil;
    CMTime actualTime;
    CGImageRef image = [assetGen copyCGImageAtTime:time actualTime:&actualTime error:&error];
    UIImage *videoImage = [[UIImage alloc] initWithCGImage:image];
    CGImageRelease(image);
    return videoImage;
}

- (BOOL)judgeIsHaveCameraAuthority
{
    AVAuthorizationStatus status = [AVCaptureDevice authorizationStatusForMediaType:AVMediaTypeVideo];
    if (status == AVAuthorizationStatusRestricted ||
        status == AVAuthorizationStatusDenied) {
        return NO;
    }
    return YES;
}

// -------------------------------

// 将原始视频的URL转化为NSData数据,写入沙盒
//- (void)videoWithUrl:(NSURL *)url withFileName:(NSString *)fileName;
//{
//    // 解析一下,为什么视频不像图片一样一次性开辟本身大小的内存写入?
//    // 想想,如果1个视频有1G多,难道直接开辟1G多的空间大小来写?
//    ALAssetsLibrary *assetLibrary = [[ALAssetsLibrary alloc] init];
//    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
//        if (url) {
//            [assetLibrary assetForURL:url resultBlock:^(ALAsset *asset) {
//                ALAssetRepresentation *rep = [asset defaultRepresentation];
//                NSString * videoPath = [KCachesPath stringByAppendingPathComponent:fileName];
//                char const *cvideoPath = [videoPath UTF8String];
//                FILE *file = fopen(cvideoPath, a+);
//                if (file) {
//                    const int bufferSize = 1024 * 1024;
//                    // 初始化一个1M的buffer
//                    Byte *buffer = (Byte*)malloc(bufferSize);
//                    NSUInteger read = 0, offset = 0, written = 0;
//                    NSError* err = nil;
//                    if (rep.size != 0)
//                    {
//                        do {
//                            read = [rep getBytes:buffer fromOffset:offset length:bufferSize error:&err];
//                            written = fwrite(buffer, sizeof(char), read, file);
//                            offset += read;
//                        } while (read != 0 && !err);//没到结尾，没出错，ok继续
//                    }
//                    // 释放缓冲区，关闭文件
//                    free(buffer);
//                    buffer = NULL;
//                    fclose(file);
//                    file = NULL;
//                }
//            } failureBlock:nil];
//        }
//    });
//}

@end





