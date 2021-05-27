//
//  ViewController.m
//  FenbiLiveSdkDemo
//
//  Created by Liu Jinjun on 2021/5/26.
//

#import "ViewController.h"
#import "MediaPlayerViewController.h"

@interface ViewController ()

@end

@implementation ViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"FenbiLiveSDK";
    
    UIButton *playerButton = [[UIButton alloc] initWithFrame:CGRectMake(100, 200, 100, 50)];
    playerButton.backgroundColor = [UIColor redColor];
    [playerButton setTitle:@"Player" forState:UIControlStateNormal];
    [playerButton addTarget:self action:@selector(showPlayer) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playerButton];
}

- (void)showPlayer {
    NSLog(@"showPlayer");
    MediaPlayerViewController *vc = [[MediaPlayerViewController alloc] init];
    [self.navigationController pushViewController:vc animated:YES];
}

@end
