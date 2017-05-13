//
//  SMKTransferingSong.h
//  constrains
//
//  Created by Vo1 on 30/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SMKTransferingSong : NSObject
- (instancetype)init;
- (void)transferSongWithLink:(NSString *)link withSuccessBlock:(void(^)(NSString *str))successBlock withFailureBlock:(void(^)())failureBlock;
+ (bool)isSuitableLink:(NSString *)link;


@end
