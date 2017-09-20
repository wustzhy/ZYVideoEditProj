//
//  ZYVideoMainVC.m
//  ZYMovieEdit
//
//  Created by Ray on 2017/9/18.
//  Copyright © 2017年 Yestin. All rights reserved.
//

#import "ZYVideoMainVC.h"

#import <AVFoundation/AVFoundation.h>

#import <MediaPlayer/MediaPlayer.h> //MPMoviePlayerViewController

#import "SVProgressHUD.h"

typedef NS_ENUM(NSUInteger, ZBtnType) {
    ZBtnType_One = 1000,
    ZBtnType_Two,
    ZBtnType_Three,
    ZBtnType_Four,
    
    ZBtnType_End,
};

@interface ZYVideoMainVC ()

@property (nonatomic,   strong)     AVPlayer * player1;
@property (nonatomic,   strong)     AVPlayer * player2;
@property (nonatomic,   strong)     AVPlayer * player3;
@property (nonatomic,   strong)     AVPlayer * player4;


@end

@implementation ZYVideoMainVC

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view.
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    
    [self createUI];
}

- (void)createUI
{
    
    CGFloat x0 = 20 , y0 = 150 ;        // 首个视频位置
    CGFloat xx , yy , wh = 150 ;
    CGFloat gap_v = 40 , gap_h = 20;    // 垂直|水平
    
    for (int i = ZBtnType_One; i < ZBtnType_End; i++) {
        
        yy = y0 + (i-ZBtnType_One) /2 * (wh+gap_v) ;     // 行
        xx = x0 + (i-ZBtnType_One) %2 * (wh+gap_h) ;     // 列(共2列)
        
        CGRect rect = CGRectMake(xx, yy, wh, wh);
        
        CGRect btn_rect = CGRectMake(xx, yy-30, wh, 30);
        
        AVPlayer * player;
        
        switch (i) {
            case ZBtnType_One:
            {
                
                self.player1 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"test_horizontal_1.mp4"];
                player = self.player1;
            }
                break;
            case ZBtnType_Two:
            {
               
                self.player2 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"test_vertical_1.MOV"];
                player = self.player2;
            }
                break;
            case ZBtnType_Three:
            {
                
                self.player3 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"music.mp3"];
                player = self.player3;
            }
                break;
            case ZBtnType_Four:
            {
                self.player4 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"music.mp3"];
                player = self.player4;
            }
                break;
            default:
                break;
        }
        

        // 按钮

        CGFloat sec = [self getDurationOfVideo:player];
        [self createButtonWithTitle:[NSString stringWithFormat:@"播放 第%zd个 时长:%f",i+1 -ZBtnType_One, sec]
                                tag:i
                              frame:btn_rect];
    }
    
    // 选择"音频"?
    
    
    UIButton * composeMovie_btn = [self createButtonWithTitle:@"合并视频1、2" action:@selector(composeMovieAction)];
    composeMovie_btn.frame = CGRectMake(30, 70, 100, 30);
    
    UIButton * composeVideoAudio_btn = [self createButtonWithTitle:@"合并视频1、2 并更换背景音3 music" action:@selector(composeVideoAudioAction)];
    composeVideoAudio_btn.frame = CGRectMake(150, 70, 200, 30);
}

#pragma mark - touch
// 单击"播放"
- (void)tapButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event
{
    [self performSelector:@selector(playAVPlayerWith:) withObject:sender afterDelay:0.2];
}
// 双击"播放"
- (void)repeatBtnTapped:(UIButton *)sender forEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playAVPlayerWith:) object:sender];
    // 延长0.2 秒
    [self performSelector:@selector(playMovieVCWith:) withObject:sender afterDelay:0.2];
}
// 合并 两视频(背景音不变)
-(void)composeMovieAction
{
    [self composeVideosWithAVAssetArray:@[self.player1.currentItem.asset ,
                                          self.player2.currentItem.asset]
                 audiosWithAVAssetArray:@[]
     ];
     
}
// 合并 两视频 ,更换背景音
- (void)composeVideoAudioAction
{
    [self composeVideosWithAVAssetArray:@[self.player1.currentItem.asset ,
                                          self.player2.currentItem.asset]
                 audiosWithAVAssetArray:@[self.player3.currentItem.asset]
     ];
}

#pragma mark - player handle
// play AVPlayer
- (void)playAVPlayerWith:(UIButton *)sender
{
    NSArray <AVPlayer *>* array = @[self.player1 , self.player2 , self.player3 , self.player4];
    NSInteger index = sender.tag - ZBtnType_One;
    AVPlayer * player = array[index];
    
    [player seekToTime:CMTimeMake(0, 1)];
    [player play];
    
}
// play MPMoviePlayerViewController
- (void)playMovieVCWith:(UIButton *)sender
{
    NSArray <AVPlayer *>* array = @[self.player1 , self.player2 , self.player3 , self.player4];
    NSInteger index = sender.tag - ZBtnType_One;
    AVPlayer * player = array[index];
    
    AVURLAsset * avSet = (AVURLAsset *)player.currentItem.asset;
    
    MPMoviePlayerViewController * playerVC = [[MPMoviePlayerViewController alloc]initWithContentURL: avSet.URL];
    [self presentMoviePlayerViewControllerAnimated:playerVC];
    
    for (int i = 0; i < array.count; i++) {
        [array[i] pause];
    }
}

// compose

- (void)composeVideosWithAVAssetArray:(NSArray <AVAsset * >* )array audiosWithAVAssetArray:(NSArray <AVAsset * >* )array1
{
    [SVProgressHUD show];
    
    AVMutableComposition * mixComposition = [[AVMutableComposition alloc]init];
    
    // video track
    AVMutableCompositionTrack * firstTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeVideo preferredTrackID:kCMPersistentTrackID_Invalid];
    
    CGFloat sec_video = 0;  // 视频时长统计(累加) , 用于 音频时长过长比较 砍掉
    
    for (int i = 0; i < array.count; i++) {
        
        sec_video += [self getDurationSecOfVidioAsset:array[i]];
        
        NSError * error;
        [firstTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, array[i].duration)
                            ofTrack:[array[i] tracksWithMediaType:AVMediaTypeVideo].firstObject //video
                             atTime:i>0 ? array[i-1].duration : kCMTimeZero
                              error:&error];
        if (error) {
            NSLog(@"error = %@",error);
        }
    }
    
    // audio track
    AVMutableCompositionTrack * audioTrack = [mixComposition addMutableTrackWithMediaType:AVMediaTypeAudio preferredTrackID:kCMPersistentTrackID_Invalid];
    
    if (array1.count == 0) {
        
        for (int i = 0; i < array.count; i++) {
            NSError * error;
            [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, array[i].duration)
                                ofTrack:[array[i] tracksWithMediaType:AVMediaTypeAudio].firstObject //audio
                                 atTime:i>0 ? array[i-1].duration : kCMTimeZero
                                  error:&error];
            if (error) {
                NSLog(@"error = %@",error);
            }
        }
    
    }else{
        
        CGFloat sec_audio = 0;  // 音频时长统计(累加)
        
        for (int i = 0; i < array1.count; i++) {
            
            CMTime cmT_i = array1[i].duration;
            
            CGFloat sec_i = [self getDurationSecOfVidioAsset:array1[i]];
            
            if (sec_audio + sec_i > sec_video) {          // 本次duration 超出 总视轨 长度
                sec_i = sec_video - sec_audio;
                cmT_i.value = sec_i * cmT_i.timescale;
            }
            
            NSError * error;
            [audioTrack insertTimeRange:CMTimeRangeFromTimeToTime(kCMTimeZero, cmT_i)
                                ofTrack:[array1[i] tracksWithMediaType:AVMediaTypeAudio].firstObject //audio
                                 atTime:i>0 ? array1[i-1].duration : kCMTimeZero
                                  error:&error];
            if (error) {
                NSLog(@"error = %@",error);
            }
            
            sec_audio += sec_i;
        }
    }
    
    AVAssetExportSession *exporter = [[AVAssetExportSession alloc]initWithAsset:mixComposition presetName:AVAssetExportPresetHighestQuality];
    
    AVMutableAudioMix * audioMix = [AVMutableAudioMix audioMix];
    
    exporter.outputURL = [self getVideoPathUrlToSave];
    exporter.outputFileType = AVFileTypeQuickTimeMovie;
    exporter.audioMix = audioMix;
    exporter.shouldOptimizeForNetworkUse = YES;
    [exporter exportAsynchronouslyWithCompletionHandler:^{
       
        [SVProgressHUD dismiss];
        
        if (exporter.status == AVAssetExportSessionStatusCompleted) {
            
            [SVProgressHUD showSuccessWithStatus:@"视频合成完毕 , 请点击视频3 播放"];
            
            AVPlayerItem * item = [AVPlayerItem playerItemWithURL:exporter.outputURL];
            [self.player4 replaceCurrentItemWithPlayerItem:item];
            [self.player4 seekToTime:CMTimeMake(0, 1)];
            
            // 时长
            CGFloat sec = [self getDurationOfVideo:self.player4];
            UIButton * btn = [self.view viewWithTag:ZBtnType_End-1];
            [btn setTitle:[NSString stringWithFormat:@"播放 第%zd个 时长:%f",ZBtnType_End -ZBtnType_One, sec] forState:UIControlStateNormal];
        }
        
    }];
}

#pragma mark - private

- (CGFloat)getDurationOfVideo:(AVPlayer *)player
{
    
    return [self getDurationSecOfVidioAsset:player.currentItem.asset];
}

- (CGFloat)getDurationSecOfVidioAsset:(AVAsset *)asset;
{
    CGFloat sec = CMTimeGetSeconds(asset.duration);
    
    return sec;
}

- (NSURL *)getVideoPathUrlToSave{
    
    // 4 - Get path
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
//    NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
//                             [NSString stringWithFormat:@"mergeVideo-%d.mov",12345]];   // arc4random() % 1000
        NSString *myPathDocs =  [documentsDirectory stringByAppendingPathComponent:
                                 [NSString stringWithFormat:@"mergeVideo-%d.mov",arc4random() % 1000]];   //必须要变路径,否则第二次合成 输出到同一个url会失败

    NSURL * url = [NSURL fileURLWithPath:myPathDocs];
    return url;
}

- (AVPlayer *)createPlayerWithFrame:(CGRect)frame withBundleResource:(NSString *)name
{
    NSString * str = [[NSBundle mainBundle] resourcePath];
    NSString * filePath = [NSString stringWithFormat:@"%@/%@",str,name];
    NSURL * sourceMovieUrl = [NSURL fileURLWithPath:filePath];

    AVURLAsset * movieAsset = [AVURLAsset URLAssetWithURL:sourceMovieUrl options:nil];
    AVPlayerItem * playerItem = [AVPlayerItem playerItemWithAsset:movieAsset];

    
    AVPlayer * player = [AVPlayer playerWithPlayerItem:playerItem];
    AVPlayerLayer * playerLayer = [AVPlayerLayer playerLayerWithPlayer:player];
    playerLayer.backgroundColor = [UIColor whiteColor].CGColor;
    playerLayer.frame = frame;
    playerLayer.videoGravity = AVLayerVideoGravityResizeAspect;
    
    [self.view.layer addSublayer:playerLayer];
    
    
    return player;
}


- (UIButton *)createButtonWithTitle:(NSString *)title
                               tag:(int )tag
                              frame:(CGRect)frame
{
    UIButton *button = [[UIButton alloc] initWithFrame:frame];
    
    button.layer.borderColor = [UIColor orangeColor].CGColor;
    button.layer.borderWidth = 2;
    
    [button setTitle:title forState:UIControlStateNormal];
    
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    button.tag = tag;
    
    [button addTarget:self action:@selector(tapButtonTapped:forEvent:) forControlEvents:UIControlEventTouchDown];
    
    [button addTarget:self action:@selector(repeatBtnTapped:forEvent:) forControlEvents:UIControlEventTouchDownRepeat];
    
    [self.view addSubview:button];
    
    return button;
}

- (UIButton *)createButtonWithTitle:(NSString *)title
                       action:(SEL)action{
    UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
    
    button.layer.borderColor = [UIColor purpleColor].CGColor;
    button.layer.borderWidth = 2;
    
    [button setTitle:title forState:UIControlStateNormal];
    button.titleLabel.adjustsFontSizeToFitWidth = YES;
    
    [button setTitleColor:[UIColor grayColor] forState:UIControlStateHighlighted];
    
    [button.titleLabel sizeToFit];
    [button addTarget:self action:action forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:button];
    
    return button;
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end
