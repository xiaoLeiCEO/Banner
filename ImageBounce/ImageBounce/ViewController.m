//
//  ViewController.m
//  ImageBounce
//
//  Created by 章丘研发 on 2018/4/13.
//  Copyright © 2018年 WCL. All rights reserved.
//

#import "ViewController.h"
#import "ViewMacro.h"

@interface ViewController ()<UITableViewDelegate,UITableViewDataSource>{
    NSMutableArray *imageArr;
}

@property (nonatomic, strong) UIImageView * headerView;

@property (nonatomic, strong) UITableView * settingView;

@property (nonatomic,strong) UIScrollView *scrollView;

@property (nonatomic,strong) UIPageControl *pageControl;

@property (nonatomic,weak) NSTimer *timer;

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    // Do any additional setup after loading the view, typically from a nib.
    
    //    self.automaticallyAdjustsScrollViewInsets = NO;
    
    self.view.backgroundColor = [UIColor whiteColor];
    imageArr = [[NSMutableArray alloc]init];
    [imageArr addObject:@"erha6"];
    for (int i = 0; i<7; i++) {
        [imageArr addObject:[NSString stringWithFormat:@"erha%d",i]];
    }
    [imageArr addObject:@"erha0"];

    [self createSettingView];
    [self createScrollView];
    [self createPageControl];
    _timer = [NSTimer scheduledTimerWithTimeInterval:2.0 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop] addTimer:self.timer forMode:NSRunLoopCommonModes];
}
- (void)createSettingView {
    
    self.settingView = [[UITableView alloc] initWithFrame:[UIScreen mainScreen].bounds style:UITableViewStylePlain];
    self.settingView.backgroundColor = [UIColor clearColor];
    self.settingView.delegate = self;
    self.settingView.dataSource = self;
    self.settingView.contentInsetAdjustmentBehavior = UIScrollViewContentInsetAdjustmentNever;
    self.settingView.backgroundColor = [UIColor greenColor];
    self.settingView.contentInset = UIEdgeInsetsMake(250, 0, 0, 0);
    [self.settingView registerClass:[UITableViewCell class] forCellReuseIdentifier:@"cellID"];
    [self.view addSubview:self.settingView];
}

-(void)createScrollView{
    _scrollView = [[UIScrollView alloc]initWithFrame:CGRectMake(0, 0, screen_width, 250)];
    _scrollView.contentSize = CGSizeMake(screen_width*imageArr.count, 250);
    _scrollView.pagingEnabled = YES;
    _scrollView.delegate = self;
    _scrollView.contentOffset = CGPointMake(screen_width, 0);
    for (int i=0;i<imageArr.count;i++){
        UIImageView *imageView = [[UIImageView alloc]initWithFrame:CGRectMake(i*screen_width, 0, screen_width, 250)];
        imageView.image = [UIImage imageNamed:imageArr[i]];
        imageView.contentMode = UIViewContentModeScaleAspectFill;
        imageView.layer.masksToBounds = YES;
        imageView.tag = i + 100;
        [_scrollView addSubview:imageView];
    }
    [self.view addSubview:_scrollView];
}

-(void)createPageControl{
    _pageControl = [[UIPageControl alloc]initWithFrame:CGRectMake(screen_width/2-10, 250-20, 20, 20)];
    _pageControl.pageIndicatorTintColor = [UIColor lightGrayColor];
    _pageControl.currentPageIndicatorTintColor = ThemeColor;
    _pageControl.numberOfPages = imageArr.count-2;
    [self.view addSubview:_pageControl];
}

-(void)changeImage{
    
    [UIView animateWithDuration:1.0 animations:^{
        _scrollView.contentOffset = CGPointMake(_scrollView.contentOffset.x + screen_width, 0);
    } completion:^(BOOL finished) {
        if (_scrollView.contentOffset.x > screen_width*(imageArr.count-2)){
            [_scrollView setContentOffset:CGPointMake(screen_width, 0)];
        }
    }];
}


-(void)scrollViewWillBeginDragging:(UIScrollView *)scrollView{
    [_timer invalidate];
}

- (void)scrollViewDidEndDragging:(UIScrollView *)scrollView willDecelerate:(BOOL)decelerate {
        self.timer = [NSTimer scheduledTimerWithTimeInterval:2 target:self selector:@selector(changeImage) userInfo:nil repeats:YES];
    [[NSRunLoop mainRunLoop]addTimer:self.timer forMode:NSRunLoopCommonModes];

    
}

#pragma mark - < UITableViewDatasource >
- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    
    return 10;
}

-(CGFloat)tableView:(UITableView *)tableView heightForRowAtIndexPath:(NSIndexPath *)indexPath{
    return 200;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    
    UITableViewCell * settingCell = [tableView dequeueReusableCellWithIdentifier:@"cellID" forIndexPath:indexPath];
    settingCell.textLabel.text = [NSString stringWithFormat:@"测试%ld",(long)indexPath.row];
    return settingCell;
}


static int count = 0;

#pragma mark - < UITableViewDelegate >
- (void)scrollViewDidScroll:(UIScrollView *)scrollView {
    
    if (![scrollView isKindOfClass:[UITableView class]]) {
        
        NSInteger page = scrollView.contentOffset.x/screen_width;


      _pageControl.currentPage =  page > imageArr.count-2?0:page-1;
        NSLog(@"%ld",page);

        return;
    }
    
    if (count<3){
        count += 1;

    }
    else{
        CGRect newFrame = self.scrollView.frame;
        CGFloat settingViewOffsetY =  - scrollView.contentOffset.y;
        if (settingViewOffsetY < 0){
            settingViewOffsetY = 0;
        }
        newFrame.size.height = settingViewOffsetY;
        _scrollView.frame = newFrame;
        _scrollView.contentSize = CGSizeMake(_scrollView.contentSize.width, newFrame.size.height);
        for (int i =0;i<imageArr.count;i++){
            UIImageView *imageView = [_scrollView viewWithTag:i+100];
            CGRect imageViewFrame = imageView.frame;
            imageViewFrame.size.height = settingViewOffsetY;
            imageView.frame = imageViewFrame;
        }
        _pageControl.frame = CGRectMake(screen_width/2-10, settingViewOffsetY-20, 20, 20);
    }
    
}



-(void)scrollViewDidEndDecelerating:(UIScrollView *)scrollView{
    if ([scrollView isKindOfClass:[UITableView class]]) return;
    
    CGFloat page = scrollView.contentOffset.x/screen_width;
    NSInteger currentPage = page;
    if (page<1){
        [scrollView setContentOffset:CGPointMake(screen_width*(imageArr.count-2), 0)];
        
        _pageControl.currentPage = imageArr.count-2;
    }
    else if (page>imageArr.count-2){
        [scrollView setContentOffset:CGPointMake(screen_width, 0)];
        
        _pageControl.currentPage = 0;
    }
    
    else {
        _pageControl.currentPage = currentPage - 1;
    }
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}


@end

