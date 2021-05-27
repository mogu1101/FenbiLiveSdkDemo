//
//  SdkBridge.m
//  Runner
//
//  Created by Liu Jinjun on 2021/5/21.
//

#import "SdkBridge.h"
#import <FenbiLiveSdk/tutor_live_sdk.h>
#import <FenbiLiveSdk/sdk_replay_engine.h>
#import <vector>

using namespace eagle_sdk;
using namespace player;

class MyLocalEnginCallback: public LocalEngineCallback {
    void OnAudioUnitReady(bool ready) {
        
    }
    
    void OnUpdateInterruptStatus(bool is_interrupted) {
        
    }
    
    void OnEngineCreated(bool success) {
        
    }
    
    void OnAudioRecordingStart() {
        
    }
    
    void OnAudioRecordingStop() {
        
    }
    
    void OnVideoFrameReceived(int32_t user_id, VideoTrackType type) {
        printf("MyReplayEnginCallBack: -------- user_id: %d, type: %d", user_id, type);
    }
    /*
     * 开始录屏后，Recorder启动成功，异步通知客户端
     */
    void OnRecordStarted() {
        
    }
    /*
     * 录屏恢复后，异步通知客户端
     */
    void OnRecordResumed() {
        
    }
    /*
     * 选择保存文件时，在文件处理完成后，异步通知客户端
     * @param file_path: 成品文件的路径
     */
    void OnRecordFileReady(std::string file_path) {
        
    }
    /*
     * 录制过程中错误回调，应根据level采取不同的处理
     * @param level: 错误等级
     * @param code: 错误码
     */
    void OnRecordError(RecordErrorLevel level, int code) {
        
    }
};

class MyMediaPlayerCallback: public MediaPlayerCallback {
    void OnError(int32_t player_id, int what, int extra) {
        
    }
    
    void OnInfo(int32_t player_id, int what, int extra) {
        
    }

    void OnPrepared(int32_t player_id) {
        
    }
    
    void OnSeekComplete(int32_t player_id, int32_t seek_id) {
        
    }
    
    void OnCompletion(int32_t player_id) {
        
    }
    
    void OnDecodingOneFrameElapsed(int id, int32_t time_ms) {
        
    }
    
    void OnOpenFileFailed(int id, char *file_name) {
        
    }

    void OnBellEnd(int32_t player_id) {
        
    }
};

@implementation SdkBridge

+ (instancetype)sharedInstance {
    static SdkBridge *instance = nil;
    static dispatch_once_t onceToken;
    dispatch_once(&onceToken, ^{
        instance = [[SdkBridge alloc] init];
    });
    return instance;
}

//- (instancetype)init
//{
//    self = [super init];
//    if (self) {
//        eagle_sdk::OnAppStart();
//    }
//    return self;
//}

- (void)setup {
    OnAppStart();
    MyLocalEnginCallback callback = MyLocalEnginCallback();
    CreateLocalEngine(&callback, 0);
}

- (void)setupPlayerWithFilePath:(NSString *)filePath
                    filePrefixs:(NSArray<NSString *> *)filePrefixs
                        mediaId:(NSString *)mediaId
                           view:(UIView *)view
                       playerId:(NSInteger)playerId {
    MyMediaPlayerCallback callback = MyMediaPlayerCallback();
    RegisterMediaPlayerCallback(&callback);
    std::vector<std::string> prefixs;
    for (NSString *prefix in filePrefixs) {
        prefixs.push_back(prefix.UTF8String);
    }
    VideoTrackInfo info = {kVideoTrackTypeScreen};
    int32_t player_id = (int32_t)playerId;
    PrepareAsync(filePath.UTF8String, prefixs, mediaId.UTF8String, view, &player_id, info);
//    PrepareAsync(filePath, filePrefixs, mediaId, view, playerId, info);
}

//- (void)test {
//    eagle_sdk::UserConfig userConfig = eagle_sdk::UserConfig();
//    userConfig.device_id = "123";
//    eagle_sdk::SetUserConfig(userConfig);
//}

@end
