//
//  SpotifySearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//
// Use -stringByAddingPercentEncodingWithAllowedCharacters: instead, which always uses the recommended UTF-8 encoding, and which encodes for a specific URL component or subcomponent since each URL component or subcomponent has different rules for what characters are valid.
#import "SpotifySearch.h"

@implementation SpotifySearch
NSString *spotifYURLSearchWithTrackID = @"https://api.spotify.com/v1/tracks/";
NSString *spotifYURLSearchWithTemp = @"https://api.spotify.com/v1/search?";

#pragma mark - download Data
+ (void)makeDataTaskWithTemp:(NSString *)temp withBlock:(void(^)(NSString *url, BOOL success, NSError *error))block {
    
    NSString *encodeTemp = [temp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track,artist&limit=1",spotifYURLSearchWithTemp, encodeTemp]];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([SpotifySearch checkIfValidJSON:json]) {
                NSString *url = [SpotifySearch parseJSONAndGetURL:json];
                block(url,true, nil);
            } else {
                block(nil,false, error);
            }
        } else {
            NSLog(@"%@", error);
            block(nil,false, error);
        }
    }] resume];
}
+ (void)makeDataTaskWithTrackId:(NSString *)trackId withBlock:(void(^)(NSString *terms, bool success, NSError *error))block {
    NSString *prepareForUrl = [NSString stringWithFormat:@"%@%@",spotifYURLSearchWithTrackID, trackId];
    NSURL *url = [NSURL URLWithString:prepareForUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSString *terms = [SpotifySearch parseJSONAndGetTerms:json];
            block(terms,1,nil);
        } else {
            block(nil,0,error);
        }
    }] resume];
}
#pragma  mark - Parce methods
+ (NSString *)parseJSONAndGetTerms:(NSDictionary *)dict {
    NSString *title = [dict objectForKey:@"name"];
    NSString *artist = [[[dict objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *term = [NSString stringWithFormat:@"%@+%@", title,artist];
    return term;
}
+ (NSString *)parseJSONAndGetURL:(NSDictionary *)dict {
    NSString *url = [[[[[dict objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"external_urls"] objectForKey:@"spotify"];
    return url;
}
+ (NSString *)parseURLToGetTrackId:(NSString *)str {
    NSString *qwe = @"https://open.spotify.com/track/";
    NSString *trackId = [str substringFromIndex:[qwe length]];
    return trackId;
}
#pragma  mark - Check JSON/Link methods
+ (BOOL)checkIfValidJSON:(NSDictionary *)dict {
    NSNumber *counterOfTracks = [[dict objectForKey:@"tracks"] objectForKey:@"total"];
    if ([counterOfTracks integerValue] > 0) {
        return true;
    }
    return false;
}
+ (BOOL)checkLinkWithString:(NSString *)link {
    if ([link containsString:@"https://open.spotify.com/"]) {return YES;}
    return NO;
}

@end
