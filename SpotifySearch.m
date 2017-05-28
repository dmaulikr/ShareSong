//
//  SpotifySearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SpotifySearch.h"

@implementation SpotifySearch
NSString *spotifYURLSearchWithTrackID = @"https://api.spotify.com/v1/tracks/";
NSString *spotifYURLSearchWithTemp = @"https://api.spotify.com/v1/search?";

#pragma mark - download Data
+ (void)makeDataTaskWithTemp:(NSDictionary *)temp withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    
    NSString *artist = [temp objectForKey:@"artist"];
    NSString *title = [temp objectForKey:@"title"];
    
    NSString *encodeArtist = [artist stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@+%@&type=track&limit=20",spotifYURLSearchWithTemp, encodeTitle, encodeArtist]];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([SpotifySearch checkIfValidJSON:json]) {
                NSDictionary *dict = [SpotifySearch parseJSON:json];
                
                block(dict,true, nil);
            } else {
                [SpotifySearch retryRequestWithTitle:title withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                    block(dict,success,error);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)retryRequestWithTitle:(NSString *)songTitle withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track&limit=20",spotifYURLSearchWithTemp, encodeTitle]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!error) {
            if ([SpotifySearch checkIfValidJSON:json]) {
                NSDictionary *dict = [SpotifySearch parseJSON:json];
                block(dict,true, nil);
            } else {
                [self retryRequestWithShortTitle:[SpotifySearch removeScopesFromTitle:title] withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                    block(dict,success,error);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)retryRequestWithShortTitle:(NSString *)songTitle withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track&limit=20",spotifYURLSearchWithTemp, encodeTitle]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!error) {
            if ([SpotifySearch checkIfValidJSON:json]) {
                NSDictionary *dict = [SpotifySearch parseJSON:json];
                block(dict,true, error);
            } else {
                block(nil,false,error);
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}

#pragma mark - Get song's info from track ID
+ (void)makeDataTaskWithTrackId:(NSString *)trackId withBlock:(void(^)(NSDictionary *terms, bool success, NSError *error))block {
    NSString *prepareForUrl = [NSString stringWithFormat:@"%@%@",spotifYURLSearchWithTrackID, trackId];
    NSURL *url = [NSURL URLWithString:prepareForUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSDictionary *terms = [SpotifySearch parseJSONAndGetTerms:json];
            block(terms,1,nil);
        } else {
            @throw [NSException exceptionWithName:@"makeDataTaskWithTrackId" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}

#pragma  mark - Parce methods
+ (NSDictionary *)parseJSON:(NSDictionary *)json {
    
    NSString *url = [[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"external_urls"] objectForKey:@"spotify"];
    NSString *title = [[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"name"];
    NSString *artist = [[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    NSString *urlWithImg = [[[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"album"] objectForKey:@"images"] objectAtIndex:0] objectForKey:@"url"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[title,artist,url,urlWithImg] forKeys:@[@"title",@"artist",@"url",@"imgLink"]];
    return dict;
}
+ (NSDictionary *)parseJSONAndGetTerms:(NSDictionary *)dict {
    NSString *title = [dict objectForKey:@"name"];
    NSString *artist = [[[dict objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    return [NSDictionary dictionaryWithObjects:@[title,artist] forKeys:@[@"title",@"artist"]];
}
+ (NSString *)parseURLToGetTrackId:(NSString *)str {
    NSString *url = @"https://open.spotify.com/track/";
    NSString *trackId = [str substringFromIndex:[url length]];
    return trackId;
}
+ (NSString *)removeScopesFromTitle:(NSString *)title {
    NSArray *components = [title componentsSeparatedByString:@"("];
    if ([components count]) {
        title = [components firstObject];
    }
    return title;
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
