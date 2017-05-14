//
//  AppleMusicSearch.h
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>
#import <MediaPlayer/MediaPlayer.h>

@interface AppleMusicSearch : NSObject

+ (void)makeDataWithRequestString:(NSString *)requestString withFrontStoreID:(NSString *)frontstoreId withBlock:(void(^)(NSDictionary *dict,bool success))block;
+ (void)getAttributesWithAppleMusicLink:(NSString *)link withBlock:(void(^)(NSString* info, bool success, NSError *error))block;
+ (BOOL)checkLinkWithString:(NSString *)link;
+ (NSString *)checkTheTitle:(NSString *)title;
@end
