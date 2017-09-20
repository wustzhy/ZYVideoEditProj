//
//  ViewController.m
//  ZYMovieEdit
//
//  Created by Ray on 2017/9/18.
//  Copyright © 2017年 Yestin. All rights reserved.
//


#import "ViewController.h"

#import "ZYVideoMainVC.h"

typedef NS_ENUM(NSUInteger, ZCellType) {
    ZCellType0_VideoCompose,         // 视频-合并
    ZCellType1_AudioVideoMerge,      // 音视频-合并
    ZCellType2_VideoCut,             // 视频裁剪
    
    ZCellType_End                   // 结束
};

@interface ViewController ()<UITableViewDelegate , UITableViewDataSource>

@property (nonatomic,   strong)     UITableView * tableview;
@property (nonatomic,   strong)     NSMutableArray * dataArray;


@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.view.backgroundColor = [UIColor lightGrayColor];
    self.title = @"main";
    
    [self.view addSubview:self.tableview];
}


#pragma mark - <UITableViewDataSource, UITableViewDelegate>

-(NSInteger)numberOfSectionsInTableView:(UITableView *)tableView{
    return 1;
}

-(NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section{
    return ZCellType_End;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath
{
    static NSString * main_cell_ID = @"main_cell_ID";
    UITableViewCell * cell = [tableView dequeueReusableCellWithIdentifier:main_cell_ID];
    if (cell == nil) {
        cell = [[UITableViewCell alloc]initWithStyle:UITableViewCellStyleDefault reuseIdentifier:main_cell_ID];
    }
    
    cell.textLabel.text = self.dataArray[indexPath.row];
    
    cell.accessoryType = UITableViewCellAccessoryDisclosureIndicator;
    
    return cell;
}


-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath
{
    return 50;
}


-(void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath
{
    switch (indexPath.row) {
        case ZCellType0_VideoCompose:
        {
            ZYVideoMainVC * vc = [[ZYVideoMainVC alloc]init];
            vc.title = self.dataArray[indexPath.row];
            [self.navigationController pushViewController:vc animated:YES];
        }
            break;
        case ZCellType1_AudioVideoMerge:
            break;
        case ZCellType2_VideoCut:
            break;
            
        default:
            break;
    }
}

#pragma mark - getter

-(UITableView *)tableview{
    if(_tableview == nil){
        _tableview = [[UITableView alloc]initWithFrame:self.view.bounds];
        _tableview.delegate = self;
        _tableview.dataSource = self;
    }
    return _tableview;
}

-(NSMutableArray *)dataArray{
    if(_dataArray == nil){
        _dataArray = [NSMutableArray array];
        
        [_dataArray insertObject:@"视频·合并" atIndex:ZCellType0_VideoCompose];
        [_dataArray insertObject:@"视频、音频·合并" atIndex:ZCellType1_AudioVideoMerge];
        [_dataArray insertObject:@"视频·剪切" atIndex:ZCellType2_VideoCut];
    }
    return _dataArray;
}

@end

