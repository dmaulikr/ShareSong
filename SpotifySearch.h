//
//  SpotifySearch.h
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifySearch : NSObject
+ (void)makeDataTaskWithTrackId:(NSString *)trackId withToken:(NSDictionary *)tokenData withBlock:(void(^)(NSDictionary *terms, BOOL success, NSError *error))block;
+ (void)makeDataTaskWithTemp:(NSDictionary *)temp withToken:(NSDictionary *)tokenData withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block;
+ (NSString *)parseURLToGetTrackId:(NSString *)str;
+ (BOOL)checkLinkWithString:(NSString *)link;
+ (void)spotifyToken:(void(^)(NSDictionary *token))block;


@end
