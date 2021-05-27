//
//  MediaPlayerViewController.m
//  FenbiLiveSdkDemo
//
//  Created by Liu Jinjun on 2021/5/27.
//

#import "MediaPlayerViewController.h"
#import <FenbiLiveSdk/tutor_live_sdk.h>
#import <FenbiLiveSdk/VideoRenderViewFactory.h>
#import <vector>

class SCILocalEngineCallBack: public eagle_sdk::LocalEngineCallback {
public:
    void OnAudioUnitReady(bool ready) override {}
    void OnUpdateInterruptStatus(bool is_interrupted) override {}
    void OnEngineCreated(bool success) override {}
    void OnAudioRecordingStart() override {}
    void OnAudioRecordingStop() override {}
    void OnVideoFrameReceived(int32_t user_id, eagle_sdk::VideoTrackType type) override {}
    void OnRecordStarted() override {}
    void OnRecordResumed() override {}
    void OnRecordFileReady(std::string file_path) override {}
    void OnRecordError(eagle_sdk::RecordErrorLevel level, int code) override {}
};

class SCIMediaPlayerCallback : public eagle_sdk::MediaPlayerCallback {
public:
    void OnError(int32_t player_id, int what, int extra) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnError: %@, %@, %@", @(player_id), @(what), @(extra));
    }
    void OnInfo(int32_t player_id, int what, int extra) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnInfo: %@, %@, %@", @(player_id), @(what), @(extra));
    }
    void OnPrepared(int32_t player_id) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnPrepared: %@", @(player_id));
    }
    void OnSeekComplete(int32_t player_id, int32_t seek_id) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnSeekComplete: %@, %@", @(player_id), @(seek_id));
    }
    void OnCompletion(int32_t player_id) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnCompletion: %@", @(player_id));
    }
    void OnBellEnd(int32_t player_id) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnBellEnd: %@", @(player_id));
    }
    void OnDecodingOneFrameElapsed(int id, int32_t time_ms) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnDecodingOneFrameElapsed: %@, %@", @(id), @(time_ms));
    }
    void OnOpenFileFailed(int id, char *file_name) override {
        NSLog(@"SCIMediaPlayerCallback: --------- OnOpenFileFailed: %@, %s", @(id), file_name);
    }
};

class SCIPlayerCallback: public eagle_sdk::GeneralPlayerCallback {
public:
    void OnError(int32_t player_id, int what, int extra) override {}
    void OnInfo(int32_t player_id, int what, int extra) override {
        NSLog(@"SCIPlayerCallback: --------- OnInfo: %@, %@, %@", @(player_id), @(what), @(extra));
    }
    void OnVideoFrameReceived(int32_t player_id, int64_t position) override {
        NSLog(@"SCIPlayerCallback: --------- OnVideoFrameReceived: %@, %@", @(player_id), @(position));
    }
    void OnPrepared(int32_t player_id) override {
        NSLog(@"SCIPlayerCallback: --------- OnPrepared: %@", @(player_id));
    }
    void OnSeekComplete(int32_t player_id, int32_t seek_id) override {
        NSLog(@"SCIPlayerCallback: --------- OnSeekComplete: %@, %@", @(player_id), @(seek_id));
    }
    void OnCompletion(int32_t player_id) override {
        NSLog(@"SCIPlayerCallback: --------- OnCompletion: %@", @(player_id));
    }
    void OnDecodingOneFrameElapsed(int32_t player_id, int32_t time_ms) override {
        NSLog(@"SCIPlayerCallback: --------- OnDecodingOneFrameElapsed: %@, %@", @(player_id), @(time_ms));
    }
    void OnOpenFileFailed(int32_t player_id, char *file_name) override {}
};

eagle_sdk::VideoTrackInfo createVideoTrackInfo(int userId, eagle_sdk::VideoTrackType vtype, long roomId, int groupId) {
  int ssrcType = vtype;
  if (vtype == eagle_sdk::kVideoTrackTypeSupervising
      || vtype == eagle_sdk::kVideoTrackTypeGroup
      || vtype == eagle_sdk::kVideoTrackTypeCommunication
      || vtype == eagle_sdk::kVideoTrackTypeMentorQA) {
    ssrcType = 6;// 对应transport中shared类型
  }
  long seed = roomId;
  seed = 31 * seed + userId;
  seed = 31 * seed + 31 * ssrcType;
  seed = 0xFFFFFFFFL & seed;

  if (vtype != eagle_sdk::kVideoTrackTypeCamera
      && vtype != eagle_sdk::kVideoTrackTypeCameraHD
      && vtype != eagle_sdk::kVideoTrackTypeMultiClient
      && vtype != eagle_sdk::kVideoTrackTypeMultiClientHD) {
    seed = 0x3FFFFFFFL & seed;
  }

  // 2. 根据seed生成ssrc, fec_ssrc, nack_ssrc
  long ssrc = 0xFFFFFFFFL & (seed + 1);
  if (vtype == eagle_sdk::kVideoTrackTypeCamera
    || vtype == eagle_sdk::kVideoTrackTypeCameraHD
      || vtype == eagle_sdk::kVideoTrackTypeMultiClient
        || vtype == eagle_sdk::kVideoTrackTypeMultiClientHD) {
    ssrc = userId;
  }
  long FecSsrc = 0xFFFFFFFFL & (seed + 2);
  long NackSsrc = 0xFFFFFFFFL & (seed + 3);

  eagle_sdk::VideoTrackInfo vInfo;
  vInfo.type = vtype;
  vInfo.user_id = userId;
  vInfo.ssrc = ssrc;
  vInfo.ssrc_fec = FecSsrc;
  vInfo.ssrc_nack = NackSsrc;
  vInfo.group_id = groupId;

  return vInfo;
}

@interface MediaPlayerViewController ()

@property (nonatomic, strong) UIView *videoRenderView;
@property (nonatomic) SCIMediaPlayerCallback *mediaPlayerCallback;
@property (nonatomic, assign) int playerId;

@end

@implementation MediaPlayerViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.title = @"MediaPlayer";
    self.view.backgroundColor = [UIColor whiteColor];
    
    CGFloat buttonWidth = 45;
    CGFloat buttonHeight = 40;
    
    UIButton *playButton = [[UIButton alloc] initWithFrame:CGRectMake(10, 500, buttonWidth, buttonHeight)];
    [playButton setTitle:@"播放" forState:UIControlStateNormal];
    playButton.backgroundColor = [UIColor lightGrayColor];
    [playButton addTarget:self action:@selector(resume) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:playButton];
    
    UIButton *pauseButton = [[UIButton alloc] initWithFrame:CGRectMake(70, 500, buttonWidth, buttonHeight)];
    [pauseButton setTitle:@"暂停" forState:UIControlStateNormal];
    pauseButton.backgroundColor = [UIColor lightGrayColor];
    [pauseButton addTarget:self action:@selector(pause) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:pauseButton];
    
    UIButton *lowSpeedButton = [[UIButton alloc] initWithFrame:CGRectMake(130, 500, buttonWidth, buttonHeight)];
    [lowSpeedButton setTitle:@"x0.5" forState:UIControlStateNormal];
    lowSpeedButton.backgroundColor = [UIColor lightGrayColor];
    [lowSpeedButton addTarget:self action:@selector(settSpeed0_5) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:lowSpeedButton];
    
    UIButton *normalSpeedButton = [[UIButton alloc] initWithFrame:CGRectMake(190, 500, buttonWidth, buttonHeight)];
    [normalSpeedButton setTitle:@"x1.0" forState:UIControlStateNormal];
    normalSpeedButton.backgroundColor = [UIColor lightGrayColor];
    [normalSpeedButton addTarget:self action:@selector(settSpeed1) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:normalSpeedButton];
    
    UIButton *highSpeedButton = [[UIButton alloc] initWithFrame:CGRectMake(250, 500, buttonWidth, buttonHeight)];
    [highSpeedButton setTitle:@"x2.0" forState:UIControlStateNormal];
    highSpeedButton.backgroundColor = [UIColor lightGrayColor];
    [highSpeedButton addTarget:self action:@selector(settSpeed2) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:highSpeedButton];
    
    UIButton *backButton = [[UIButton alloc] initWithFrame:CGRectMake(310, 500, buttonWidth, buttonHeight)];
    [backButton setTitle:@"<<10" forState:UIControlStateNormal];
    backButton.backgroundColor = [UIColor lightGrayColor];
    [backButton addTarget:self action:@selector(seekBack) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:backButton];
    
    UIButton *forwordButton = [[UIButton alloc] initWithFrame:CGRectMake(370, 500, buttonWidth, buttonHeight)];
    [forwordButton setTitle:@"10>>" forState:UIControlStateNormal];
    forwordButton.backgroundColor = [UIColor lightGrayColor];
    [forwordButton addTarget:self action:@selector(seekForword) forControlEvents:UIControlEventTouchUpInside];
    [self.view addSubview:forwordButton];
}

- (void)viewDidAppear:(BOOL)animated {
    eagle_sdk::OnAppStart();
    
    SCILocalEngineCallBack *callback = new SCILocalEngineCallBack();
    eagle_sdk::CreateLocalEngine(callback, 0);
    
    [self playUrl];
}

- (void)viewDidDisappear:(BOOL)animated {
    eagle_sdk::DestroyLocalEngine();
}

- (void)playUrl {
    if (self.mediaPlayerCallback == nil) {
        self.mediaPlayerCallback = new SCIMediaPlayerCallback();
    }
    std::string media = [@"https://solar-online.fbcontent.cn/pumpkin/admin/segment/1616144481995.mp4" UTF8String];
    if (self.videoRenderView == nil) {
        self.videoRenderView = [VideoRenderViewFactory create];
    }
    CGFloat width = [UIScreen.mainScreen bounds].size.width;
    CGFloat height = width * 9 / 17;
    self.videoRenderView.frame = CGRectMake(0, 200, width, height);
    [self.view addSubview:self.videoRenderView];
    self.playerId = 123;
//    NSArray<NSString *> *arr = @[];
//    std::vector<std::string> prefixs;
//    for (NSString *s in arr) {
//        prefixs.push_back(s.UTF8String);
//    }
    
    SCIPlayerCallback *callback = new SCIPlayerCallback();
    eagle_sdk::player::RegisterMediaPlayerCallback(self.mediaPlayerCallback);
    eagle_sdk::player::PrepareAsync(media.c_str(),
                                    self.videoRenderView,
                                    &_playerId,
                                    false,
                                    true,
                                    createVideoTrackInfo(0, eagle_sdk::kVideoTrackTypeLivePlayer, 0, 0),
                                    callback);
//    eagle_sdk::player::PrepareAsync(media.c_str(),
//                                    prefixs,
//                                    media.c_str(),
//                                    self.videoRenderView,
//                                    &playerId,
//                                    createVideoTrackInfo(0, eagle_sdk::kVideoTrackTypeLivePlayer, 0, 0));
    eagle_sdk::player::Start(self.playerId);
//    eagle_sdk::player::SetVolume(playerId, 5.0);
//    eagle_sdk::player::SetSpeed(playerId, 2.0);
}

- (void)pause {
    eagle_sdk::player::Pause(self.playerId);
}

- (void)resume {
    eagle_sdk::player::Start(self.playerId);
}

- (void)setSpeed:(CGFloat)speed {
    eagle_sdk::player::SetSpeed(self.playerId, speed);
}

- (void)settSpeed0_5 {
    [self setSpeed:0.5];
}

- (void)settSpeed1 {
    [self setSpeed:1.0];
}

- (void)settSpeed2 {
    [self setSpeed:2.0];
}

- (NSInteger)getCurrentPosition {
    int64_t position = 0;
    eagle_sdk::player::GetCurrentPositionMs(self.playerId, &position);
    return position;
}

- (NSInteger)getDuration {
    int64_t duration = 0;
    eagle_sdk::player::GetDurationMs(self.playerId, &duration);
    return duration;
}

- (void)seekTo:(CGFloat)millseconds {
    eagle_sdk::player::SeekTo(self.playerId, millseconds, millseconds);
}

- (void)seekBack {
    [self seekTo:[self getCurrentPosition] - 10000];
}

- (void)seekForword {
    [self seekTo:[self getCurrentPosition] + 10000];
}

@end
