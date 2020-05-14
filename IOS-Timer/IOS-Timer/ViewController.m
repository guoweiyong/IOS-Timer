//
//  ViewController.m
//  IOS-Timer
//
//  Created by yunyi on 2020/5/13.
//  Copyright © 2020 yunyi. All rights reserved.
//

#import "ViewController.h"
#import "TestFirstViewController.h"

@interface ViewController ()<UITableViewDelegate, UITableViewDataSource>
@property (weak, nonatomic) IBOutlet UITableView *tableView;

/// GCD定时器
@property (nonatomic, strong) dispatch_source_t gcdTimer;

/// 定时器
@property (nonatomic, strong) NSTimer *timer;
@end

static NSString *cellIdentifier = @"cellIdentifier";

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    [self.tableView registerClass:[UITableViewCell class] forCellReuseIdentifier:cellIdentifier];
    
    //[self creatTimerToSelector];
    //[self creatTiemrToInvocation];
    
    //[self creatTimerToSelector2];
    //[self asyncTimer];
    
    //[self GCDTiemr];
}

#pragma mark -- NSTimer 定时器
/**
 + (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti invocation:(NSInvocation *)invocation repeats:(BOOL)yesOrNo;
 + (NSTimer *)timerWithTimeInterval:(NSTimeInterval)ti target:(id)aTarget selector:(SEL)aSelector userInfo:(nullable id)userInfo repeats:(BOOL)yesOrNo;
 */

- (void)creatTimerToSelector {
    NSLog(@"----------------");
    //创建定时器
    self.timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerfunc:) userInfo:nil repeats:YES];
    
    //把定时器添加到当前的RunLoop中，如果不添加到RunLoop中 定时器不会启动
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    
    //该方法是让定时器，立刻启动，然后在根据时间间隔来执行，如果调用此方法，那么定时器创建之后并不会立刻启动，会延迟间隔时间后，在执行
    //[self.timer fire];
    
}

- (void)creatTiemrToInvocation {
    //1.首先获取方法签名
    SEL selector = @selector(invocationTest:num:);
    NSMethodSignature *signature = [[self class] instanceMethodSignatureForSelector:selector];
    
    NSInvocation *invocation = [NSInvocation invocationWithMethodSignature:signature];
    invocation.target = self;
    invocation.selector = selector;
    
    //设置invocation的参数 设置参数要冲第二个参数设置起  前面有两个参数是  self， _cmd
    NSString *str = @"guoweiyong";
    [invocation setArgument:&str atIndex:2];
    NSNumber *number = [NSNumber numberWithInt:20];
    [invocation setArgument:&number atIndex:3];
    
    //这里也可以设置返回值，但是我这里没有返回值就不设置了
    //    - (void)getReturnValue:(void *)retLoc;
    //    - (void)setReturnValue:(void *)retLoc;
    
    //执行方法 定时器不需要调用这个方法
    //[invocation invoke];
    
    self.timer = [NSTimer timerWithTimeInterval:1 invocation:invocation repeats:true];
    [[NSRunLoop currentRunLoop] addTimer:self.timer forMode:NSDefaultRunLoopMode];
    //[self.timer fire];
}
- (void)invocationTest:(NSString *)str num:(NSNumber *)number {
    NSLog(@"invocation 执行Timer test str=====%@  number====%@",str,number);
}

- (void)creatTimerToSelector2 {
    self.timer = [NSTimer scheduledTimerWithTimeInterval:1 target:self selector:@selector(timerfunc:) userInfo:nil repeats:YES];
}

- (void)timerfunc:(NSTimer *)timer{
    NSLog(@"timer  test======");
}

- (void)asyncTimer {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        NSTimer* timer = [NSTimer timerWithTimeInterval:1 target:self selector:@selector(timerfunc:) userInfo:nil repeats:YES];
        [[NSRunLoop currentRunLoop] addTimer:timer forMode:NSRunLoopCommonModes];
        [[NSRunLoop currentRunLoop] run];
    });
}


#pragma mark --  GCD定时器
- (void)GCDTiemr {
    //最后一个参数是队列，在那个队列中执行
    self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_main_queue());
    dispatch_source_set_timer(self.gcdTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.gcdTimer, ^{
        NSLog(@"GCD定时器执行");
    });
    //定时器的启动方法
    dispatch_resume(self.gcdTimer);
}

#pragma mark -- 表格代理

- (NSInteger)tableView:(UITableView *)tableView numberOfRowsInSection:(NSInteger)section {
    return 100;
}

- (UITableViewCell *)tableView:(UITableView *)tableView cellForRowAtIndexPath:(NSIndexPath *)indexPath {
    UITableViewCell *cell = [tableView dequeueReusableCellWithIdentifier:cellIdentifier];
    
    cell.textLabel.text = [NSString stringWithFormat:@"第---%ld--行 test timer",(long)indexPath.row];
    
    return cell;
    
}

- (void)tableView:(UITableView *)tableView didSelectRowAtIndexPath:(NSIndexPath *)indexPath {
    [tableView deselectRowAtIndexPath:indexPath animated:YES];
    TestFirstViewController *testVC = [self.storyboard instantiateViewControllerWithIdentifier:@"TestFirst"];
    [self.navigationController pushViewController:testVC animated:YES];
    
}

@end
