//
//  SMKTransferingSong.h
//  constrains
//
//  Created by Vo1 on 30/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>


@interface SMKTransferingSong : NSObject 

@property (nonatomic) NSDictionary *tokenData;

+ (instancetype)sharedTransfer;
- (void)transferSongWithLink:(NSString *)link withSuccessBlock:(void(^)(NSDictionary *dict))successBlock withFailureBlock:(void(^)())failureBlock;
+ (bool)isSuitableLink:(NSString *)link;
+ (bool)isAppleMusicLink:(NSString *)link;




@end
