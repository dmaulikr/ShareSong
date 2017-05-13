//
//  SpotifySearch.h
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface SpotifySearch : NSObject
+ (void)makeDataTaskWithTrackId:(NSString *)trackId withBlock:(void(^)(NSString *terms, bool success, NSError *error))block;
+ (void)makeDataTaskWithTemp:(NSString *)temp withBlock:(void(^)(NSString *url, bool success, NSError *error))block;
+ (NSString *)parseURLToGetTrackId:(NSString *)str;
+ (NSString *)parseJSONAndGetURL:(NSDictionary *)dict;
+ (BOOL)checkLinkWithString:(NSString *)link;
@end
