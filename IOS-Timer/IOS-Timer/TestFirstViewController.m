//
//  TestFirstViewController.m
//  IOS-Timer
//
//  Created by yunyi on 2020/5/14.
//  Copyright © 2020 yunyi. All rights reserved.
//

#import "TestFirstViewController.h"


@interface TestFirstViewController ()
/// GCD定时器
@property (nonatomic, strong) dispatch_source_t gcdTimer;

@property (nonatomic, strong) NSString *mark;


/// dispatch_block
@property (nonatomic, strong) dispatch_block_t delayBlcok;

@end
@implementation TestFirstViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    self.mark = @"dsadsadsa";
    //[self TestTimer];
    //[self TestBlockTimer];
    
    //[self GCDTiemr];
    //[self gcdTiemrAsync];
    
    //[self afterExecture];
    //[self afterExecture2];
    //[self ansycAfterExecture];
    [self cancelAfterExecture];
}

- (void)dealloc {
    NSLog(@"TestFirstViewController========dealloc");
}

- (void)viewDidDisappear:(BOOL)animated{
    [super viewDidDisappear:animated];
    NSLog(@"控制器消失时间========");
}
- (void)TestTimer {
    
    NSTimer *timer = [NSTimer timerWithTimeInterval:2 target:self selector:@selector(timerFunc:) userInfo:nil repeats:NO];
    [[NSRunLoop currentRunLoop]addTimer:timer forMode:NSDefaultRunLoopMode];
}

- (void)TestBlockTimer {
    [NSTimer scheduledTimerWithTimeInterval:1 repeats:YES block:^(NSTimer * _Nonnull timer) {
        NSLog(@"blcok timer 有没有强引用self");
    }];
}

- (void)timerFunc:(NSTimer *)timer {
    NSLog(@"测试非repeats 定时器是不是不会强引用self");
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

- (void)gcdTiemrAsync {
    self.gcdTimer = dispatch_source_create(DISPATCH_SOURCE_TYPE_TIMER, 0, 0, dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0));
    dispatch_source_set_timer(self.gcdTimer, DISPATCH_TIME_NOW, 1 * NSEC_PER_SEC, 0 * NSEC_PER_SEC);
    dispatch_source_set_event_handler(self.gcdTimer, ^{
        NSLog(@"GCD定时器在子线程中执行====%@",[NSThread currentThread]);
    });
    dispatch_resume(self.gcdTimer);
}

- (void)afterExecture {
    __weak typeof(self) weakSelf = self;
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(10 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
        //对当前控制器强引用
        NSLog(@"延迟10秒执行操作===%@",weakSelf.mark);
    });
}

- (void)cancelAfterExecture {

    self.delayBlcok = dispatch_block_create(0, ^{
        NSLog(@"测试dispatch_after的取消操作");
    });
    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(5 * NSEC_PER_SEC)), dispatch_get_main_queue(), self.delayBlcok);
    
    //去下dispatch_after的操作
    dispatch_block_cancel(self.delayBlcok);
}

- (void)afterExecture2 {
    __weak typeof(self) weakSelf = self;
    //使用perform 的方式来执行 延时操作
    [self performSelector:@selector(afterExectureTest) withObject:nil afterDelay:5];
}

- (void)ansycAfterExecture {
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), ^{
        [self performSelector:@selector(afterExectureTest) withObject:nil afterDelay:5];
    });
}
- (void)afterExectureTest {
    NSLog(@"延迟5秒执行操作=========%@",[NSThread currentThread]);
}
@end
