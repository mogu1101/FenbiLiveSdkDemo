//
//  SdkBridge.h
//  Runner
//
//  Created by Liu Jinjun on 2021/5/21.
//

#import <Foundation/Foundation.h>
#import <UIKit/UIKit.h>

NS_ASSUME_NONNULL_BEGIN

@interface SdkBridge : NSObject

+ (instancetype)sharedInstance;
- (void)setup;
- (void)setupPlayerWithFilePath:(NSString *)filePath
                    filePrefixs:(NSArray<NSString *> *)filePrefixs
                        mediaId:(NSString *)mediaId
                           view:(UIView *)view
                       playerId:(NSInteger)playerId;

@end

NS_ASSUME_NONNULL_END
