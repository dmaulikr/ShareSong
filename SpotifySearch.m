//
//  SpotifySearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SpotifySearch.h"
#import "SMKTransferingSong.h"
#import "Searcher.h"

@implementation SpotifySearch
NSString *spotifYURLSearchWithTrackID = @"https://api.spotify.com/v1/tracks/";
NSString *spotifYURLSearchWithTemp = @"https://api.spotify.com/v1/search?";
NSString *clientId = @"785d0dd3031a4594895b8e72ba83548a";
NSString *clientSecret = @"23ed8ea00a54403baabed39b408fcce8";

#pragma mark - download Data
+ (void)makeDataTaskWithTemp:(NSDictionary *)dict
                   withToken:(NSDictionary *)tokenData
                   withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    
    NSString *artist = [dict objectForKey:@"artist"];
    NSString *title = [dict objectForKey:@"title"];
    NSString *encodeArtist = [artist
                              stringByAddingPercentEncodingWithAllowedCharacters:
                              [NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *encodeTitle = [title
                             stringByAddingPercentEncodingWithAllowedCharacters:
                             [NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString
                                       stringWithFormat:@"%@q=%@+%@&type=track&limit=20",
                                       spotifYURLSearchWithTemp, encodeTitle, encodeArtist]];
    
    NSMutableURLRequest *request = [SpotifySearch configureRequestForDataTaskWith:url
                                                                        withToken:tokenData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                                    defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            if ([json objectForKey:@"error"]) {
                [SpotifySearch spotifyToken:^(NSDictionary *token) {
                    [SMKTransferingSong sharedTransfer].tokenData = token;
                    [SpotifySearch makeDataTaskWithTemp:dict
                                              withToken:[SMKTransferingSong sharedTransfer].tokenData
                                              withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                        block(dict,success,error);
                    }];
                }];
                return;
            }
            
            
            NSArray *filtred = [Searcher searchTheNeededOneWith:dict in:[SpotifySearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES, nil);
            
            } else {
                [SpotifySearch retryRequestWithTitle:title
                                           withToken:tokenData
                                           withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                    block(dict,success,error);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)retryRequestWithTitle:(NSString *)songTitle
                    withToken:(NSDictionary *)tokenData
                    withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track&limit=20",
                                       spotifYURLSearchWithTemp, encodeTitle]];
    
    NSMutableURLRequest *request = [SpotifySearch configureRequestForDataTaskWith:url withToken:tokenData];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!error) {
            
            NSArray *filtred = [Searcher searchTheNeededOneWith:@{songTitle:@"title"} in:[SpotifySearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES, nil);
            } else {
                [self retryRequestWithShortTitle:[SpotifySearch
                                                  removeScopesFromString:title]
                                       withToken:tokenData
                                       withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                    block(dict,success,error);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)retryRequestWithShortTitle:(NSString *)songTitle
                         withToken:(NSDictionary *)tokenData
                         withBlock:(void(^)(NSDictionary *dict, BOOL success, NSError *error))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSURL *url = [NSURL URLWithString:[NSString stringWithFormat:@"%@q=%@&type=track&limit=20"
                                       , spotifYURLSearchWithTemp, encodeTitle]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [SpotifySearch configureRequestForDataTaskWith:url withToken:tokenData];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
        if (!error) {
            NSArray *filtred = [Searcher searchTheNeededOneWith:@{songTitle:@"title"} in:[SpotifySearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES, nil);
            } else {
                block(nil,false,error);
            }
        } else {
            @throw [NSException exceptionWithName:@"SpotFromApp"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}

#pragma mark - Get song's info from track ID
+ (void)makeDataTaskWithTrackId:(NSString *)trackId withToken:(NSDictionary *)tokenData
                      withBlock:(void(^)(NSDictionary *terms, BOOL success, NSError *error))block {
    
    NSString *prepareForUrl = [NSString stringWithFormat:@"%@%@",spotifYURLSearchWithTrackID, trackId];
    NSURL *url = [NSURL URLWithString:prepareForUrl];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSMutableURLRequest *request = [SpotifySearch configureRequestForDataTaskWith:url withToken:tokenData];
    
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([json objectForKey:@"error"]) {
                
                NSString *message = [[json objectForKey:@"error"] objectForKey:@"message"];
                if ([message isEqualToString:@"invalid id"]) {
                    block(nil,NO,[NSError errorWithDomain:@"Wrong Link" code:0 userInfo:nil]);
                    return;
                }
                [SpotifySearch spotifyToken:^(NSDictionary *token) {
                    [SMKTransferingSong sharedTransfer].tokenData = token;
                    [SpotifySearch makeDataTaskWithTrackId:trackId
                                                 withToken:[SMKTransferingSong sharedTransfer].tokenData
                                                 withBlock:^(NSDictionary *terms, BOOL success, NSError *error) {
                        block(terms,success,error);
                    }];
                }];
                return;
            }
            
            NSDictionary *terms = [SpotifySearch getInfoFromSong:json];
            block(terms,YES,error);
        } else {
            @throw [NSException exceptionWithName:@"makeDataTaskWithTrackId"
                                           reason:error.localizedDescription userInfo:error.userInfo];
        }
        
    }] resume];
}

#pragma mark - Configure request
+ (NSMutableURLRequest *)configureRequestForDataTaskWith:(NSURL *)url withToken:(NSDictionary *)tokenData {
    
    NSString *token = [tokenData objectForKey:@"access_token"];
    NSString *tokenType = [tokenData objectForKey:@"token_type"];
    
    NSString *header = [NSString stringWithFormat:@"%@ %@", tokenType, token];
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc] init];
    
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    [request setURL:url];
    return request;
    
}

#pragma mark - Token
+ (void)spotifyToken:(void(^)(NSDictionary *token))block {
    NSString *body = @"grant_type=client_credentials";
    NSData *postData = [body dataUsingEncoding:NSASCIIStringEncoding allowLossyConversion:YES];
    
    NSString *prepareHeader = [NSString stringWithFormat:@"%@:%@",clientId, clientSecret];
    NSData *data = [prepareHeader dataUsingEncoding:NSUTF8StringEncoding];
    NSString *base64encoded = [data base64EncodedStringWithOptions:0];
    NSString *header = [NSString stringWithFormat:@"Basic %@", base64encoded];
    
    NSMutableURLRequest *request = [[NSMutableURLRequest alloc]init];
    [request setURL:[NSURL URLWithString:@"https://accounts.spotify.com/api/token"]];
    [request setHTTPBody:postData];
    [request setHTTPMethod:@"POST"];
    [request setValue:header forHTTPHeaderField:@"Authorization"];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLSessionDataTask *task = [session dataTaskWithRequest:request
                                            completionHandler:^(NSData * _Nullable data,
                                                                NSURLResponse * _Nullable response,
                                                                NSError * _Nullable error) {
        if (!error) {
            NSLog(@"%@", [NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            dispatch_async(dispatch_get_main_queue(), ^{
                block([NSJSONSerialization JSONObjectWithData:data options:0 error:nil]);
            });
            
        } else {
            @throw [NSException exceptionWithName:@"Token" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }];
    [task resume];
}

#pragma  mark - Parce methods
+ (NSDictionary *)parseJSON:(NSDictionary *)json {
    
    NSString *url = [[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0]
                      objectForKey:@"external_urls"] objectForKey:@"spotify"];
    NSString *title = [[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0]
                       objectForKey:@"name"];
    NSString *artist = [[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0]
                          objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    NSString *urlWithImg = [[[[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0]
                               objectForKey:@"album"] objectForKey:@"images"] objectAtIndex:0] objectForKey:@"url"];
    NSString *albumName = [[[[[json objectForKey:@"tracks"] objectForKey:@"items"] objectAtIndex:0]
                            objectForKey:@"album"] objectForKey:@"name"];
    
    NSDictionary *dict = [[NSDictionary alloc] initWithObjects:@[title,artist,url,urlWithImg,albumName]
                                                       forKeys:@[@"title",@"artist",@"url",@"imgLink",@"albumName"]];
    return dict;
}
+ (NSArray *)arrayWith:(NSDictionary *)json {
    NSMutableArray *result = [[NSMutableArray alloc] init];
    NSArray *arr = [[json objectForKey:@"tracks"] objectForKey:@"items"];
    for (NSDictionary *dict in arr) {
        
        NSString *artwork = [[[[dict objectForKey:@"album"] objectForKey:@"images"] objectAtIndex:0] objectForKey:@"url"];
        NSString *url = [[[dict objectForKey:@"album"] objectForKey:@"external_urls"] objectForKey:@"spotify"];
        NSDictionary *info = [NSDictionary
                              dictionaryWithObjects:@[ [[[[dict objectForKey:@"album"] objectForKey:@"artists"]
                                                         objectAtIndex:0] objectForKey:@"name"],
                                                      [[dict objectForKey:@"album"] objectForKey:@"name"],
                                                       [[dict objectForKey:@"album"] objectForKey:@"name"],
                                                       artwork,
                                                       url
                                                       ]
                                                         forKeys:@[@"artist",@"albumName",@"title",@"artwork",@"url"]];
        [result addObject:info];
    }
    return (NSArray *)result;
}
+ (NSDictionary *)getInfoFromSong:(NSDictionary *)dict {
    NSString *title = [dict objectForKey:@"name"];
    NSString *artist = [[[dict objectForKey:@"artists"] objectAtIndex:0] objectForKey:@"name"];
    NSString *albumName = [[dict objectForKey:@"album"] objectForKey:@"name"];
    
    title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    albumName = [albumName stringByReplacingOccurrencesOfString:@" " withString:@"+"];
    
    return [NSDictionary dictionaryWithObjects:@[title,artist,albumName] forKeys:@[@"title",@"artist",@"albumName"]];
}
+ (NSString *)parseURLToGetTrackId:(NSString *)str {
    NSString *url = @"https://open.spotify.com/track/";
    NSString *trackId = [str substringFromIndex:[url length]];
    return trackId;
}
+ (NSString *)removeScopesFromString:(NSString *)title {
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
    if ([link containsString:@"https://open.spotify.com/"]) { return YES; }
    return NO;
}








@end
