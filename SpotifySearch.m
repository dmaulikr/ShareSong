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
+ (void)makeDataTaskWithTemp:(NSString *)temp withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    
    NSString *encodeTemp = [temp stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track&limit=1",spotifYURLSearchWithTemp, encodeTemp]];

    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([SpotifySearch checkIfValidJSON:json]) {
                NSDictionary *dict = [SpotifySearch parseJSON:json];
                block(dict,true, nil);
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
+ (NSDictionary *)parseJSON:(NSDictionary *)json {
    NSString *url = [[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"external_urls"] objectForKey:@"spotify"];
    NSString *title = [[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"name"];
    NSString *artist = [[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    NSString *urlWithImg = [[[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0] objectForKey:@"album"] objectForKey:@"images"] objectAtIndex:1] objectForKey:@"url"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[title,artist,url,urlWithImg] forKeys:@[@"title",@"artist",@"url",@"imgLink"]];
    return dict;
}
+ (NSString *)parseJSONAndGetTerms:(NSDictionary *)dict {
    NSString *title = [dict objectForKey:@"name"];
    NSString *artist = [[[dict objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    NSString *term = [NSString stringWithFormat:@"%@+%@", title,artist];
    return term;
}
+ (NSString *)parseURLToGetTrackId:(NSString *)str {
    NSString *url = @"https://open.spotify.com/track/";
    NSString *trackId = [str substringFromIndex:[url length]];
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
