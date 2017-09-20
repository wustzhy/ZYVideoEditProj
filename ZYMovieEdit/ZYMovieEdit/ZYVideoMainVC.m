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

typedef NS_ENUM(NSUInteger, ZBtnType) {
    ZBtnType_One = 1000,
    ZBtnType_Two,
    ZBtnType_Three,
};

@interface ZYVideoMainVC ()

@property (nonatomic,   strong)     AVPlayer * player1;
@property (nonatomic,   strong)     AVPlayer * player2;
@property (nonatomic,   strong)     AVPlayer * player3;

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
    
    CGFloat x0 = 20 , y0 = 150 ;        // 首个位置
    CGFloat xx , yy , wh = 150 ;
    CGFloat gap_v = 40 , gap_h = 20;    // 垂直|水平
    
    for (int i = ZBtnType_One; i <= ZBtnType_Three; i++) {
        
        yy = y0 + (i-ZBtnType_One) /2 * (wh+gap_v) ;     // 行
        xx = x0 + (i-ZBtnType_One) %2 * (wh+gap_h) ;     // 列(共2列)
        
        CGRect rect = CGRectMake(xx, yy, wh, wh);
        
        CGRect btn_rect = CGRectMake(xx, yy-30, wh, 30);
        
        switch (i) {
            case ZBtnType_One:
            {
                UIButton * btn = [self createButtonWithTitle:@"播放"
                                                         tag:i
                                                       frame:btn_rect];
                [self.view addSubview:btn];
                
                self.player1 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"test_horizontal_1.mp4"];
            }
                break;
            case ZBtnType_Two:
            {
                UIButton * btn = [self createButtonWithTitle:@"播放"
                                                         tag:i
                                                       frame:btn_rect];
                [self.view addSubview:btn];
                
                self.player2 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"test_vertical_1.MOV"];
                
            }
                break;
            case ZBtnType_Three:
            {
                UIButton * btn = [self createButtonWithTitle:@"播放"
                                                         tag:i
                                                       frame:btn_rect];
                [self.view addSubview:btn];
                
                self.player3 = [self createPlayerWithFrame:rect
                                        withBundleResource:@"test_vertical_1.MOV"];
            }
                break;
            default:
                break;
        }
        
        
    }
}

#pragma mark - touch
// 单击
- (void)tapButtonTapped:(UIButton *)sender forEvent:(UIEvent *)event
{
    [self performSelector:@selector(playAVPlayerWith:) withObject:sender afterDelay:0.2];
}
// 双击
- (void)repeatBtnTapped:(UIButton *)sender forEvent:(UIEvent *)event {
    [NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(playAVPlayerWith:) object:sender];
    // 延长0.2 秒
    [self performSelector:@selector(playMovieVCWith:) withObject:sender afterDelay:0.2];
}


- (void)playAVPlayerWith:(UIButton *)sender
{
    NSArray <AVPlayer *>* array = @[self.player1 , self.player2 , self.player3];
    NSInteger index = sender.tag - ZBtnType_One;
    AVPlayer * player = array[index];
    
    [player seekToTime:CMTimeMake(0, 1)];
    [player play];
    
}

- (void)playMovieVCWith:(UIButton *)sender
{
    NSArray <AVPlayer *>* array = @[self.player1 , self.player2 , self.player3];
    NSInteger index = sender.tag - ZBtnType_One;
    AVPlayer * player = array[index];
    
    AVURLAsset * avSet = (AVURLAsset *)player.currentItem.asset;
    
    MPMoviePlayerViewController * playerVC = [[MPMoviePlayerViewController alloc]initWithContentURL: avSet.URL];
    [self presentMoviePlayerViewControllerAnimated:playerVC];
}

#pragma mark - private

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
    [button setTitle:title forState:UIControlStateNormal];
    
    button.tag = tag;
    
    [button addTarget:self action:@selector(tapButtonTapped:forEvent:) forControlEvents:UIControlEventTouchDown];
    
    [button addTarget:self action:@selector(repeatBtnTapped:forEvent:) forControlEvents:UIControlEventTouchDownRepeat];
    
    return button;
}



- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
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
