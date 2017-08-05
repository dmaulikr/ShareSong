
//  AppleMusicSearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//https://itunes.apple.com/ua/lookup?id=1245248621&entity=song

#import "AppleMusicSearch.h"
#import "Searcher.h"

@implementation AppleMusicSearch

NSString *appleMusicURLWithTermFrontStoreID = @"https://itunes.apple.com/search?";


#pragma mark - download Data
+ (void)makeDataWithDictionary:(NSDictionary *)dict
              withFrontStoreID:(NSString *)frontstoreId
                     withBlock:(void(^)(NSDictionary *dict,bool success))block {

    
    NSString *title = [dict objectForKey:@"title"];
    NSString *artist = [dict objectForKey:@"artist"];
    dict = [Searcher decodeData:dict];
    NSString *encodeTitle = [title
                             stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                 URLHostAllowedCharacterSet]];
    NSString *encodeArtist = [artist
                              stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                  URLHostAllowedCharacterSet]];
    
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@+%@&entity=song&s=%@",
                               appleMusicURLWithTermFrontStoreID, encodeTitle, encodeArtist, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    NSURLSession *session = [NSURLSession
                             sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        
                
                if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            
            NSArray *filtred = [Searcher searchTheNeededOneWith:dict in:[AppleMusicSearch arrayWith:json]];
            if ([filtred count]) {
                
                block([filtred firstObject],YES);
            } else {
                [AppleMusicSearch makeDataWithTitle:title
                                   withFrontStoreID:frontstoreId
                                          withBlock:^(NSDictionary *dict, bool success) {
                                              
                    block(dict,success);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"AppFromSpot"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)makeDataWithTitle:(NSString *)songTitle
         withFrontStoreID:(NSString *)frontstoreId
                withBlock:(void(^)(NSDictionary *dict,bool success))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title
                             stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                 URLHostAllowedCharacterSet]];
    
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@&entity=song&s=%@",
                            appleMusicURLWithTermFrontStoreID, encodeTitle, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    
    NSURLSession *session = [NSURLSession
                             sessionWithConfiguration:[NSURLSessionConfiguration
                                                       defaultSessionConfiguration]];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *filtred = [Searcher searchTheNeededOneWith:@{songTitle:@"title"} in:[AppleMusicSearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES);
            } else {
                [AppleMusicSearch makeDataWithShortTitle:[AppleMusicSearch removeScopesFromTitle:title]
                                        withFrontStoreID:frontstoreId
                                               withBlock:^(NSDictionary *dict, bool success) {
                    block(dict,success);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"AppFromSpot"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)makeDataWithShortTitle:(NSString *)songTitle withFrontStoreID:(NSString *)frontstoreId
                     withBlock:(void(^)(NSDictionary *dict,bool success))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title
                             stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet
                                                                                 URLHostAllowedCharacterSet]];
    
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@&entity=song&s=%@",
                               appleMusicURLWithTermFrontStoreID, encodeTitle, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    
    NSURLSession *session = [NSURLSession
                             sessionWithConfiguration:[NSURLSessionConfiguration
                                                       defaultSessionConfiguration]];
    [[session dataTaskWithURL:url
            completionHandler:^(NSData * _Nullable data,
                                NSURLResponse * _Nullable response,
                                NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *filtred = [Searcher searchTheNeededOneWith:@{songTitle:@"title"}
                                                             in:[AppleMusicSearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES);
            } else {
                block(nil,NO);
            }
        } else {
            @throw [NSException exceptionWithName:@"AppFromSpot"
                                           reason:error.localizedDescription
                                         userInfo:error.userInfo];
        }
    }] resume];
}

#pragma mark - filter

#pragma mark - check/parse JSON/Link
+ (NSArray *)arrayWith:(NSDictionary *)json {
    
    NSArray *arr = [json objectForKey:@"results"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arr) {
        NSString *artwork = [dict objectForKey:@"artworkUrl100"];
        NSString *url = [[[dict objectForKey:@"trackViewUrl"]
                          componentsSeparatedByString:@"&"]
                         objectAtIndex:0];
        artwork = [artwork stringByReplacingOccurrencesOfString:@"100x100bb" withString:@"600x600bb"];
        NSDictionary *info = [NSDictionary dictionaryWithObjects:@[
                                                                   [dict objectForKey:@"artistName"],
                                                                   [dict objectForKey:@"collectionName"],
                                                                   [dict objectForKey:@"trackName"],
                                                                   artwork,
                                                                   url
                                                                   ]
                                                         forKeys:@[@"artist",@"albumName",@"title",@"artwork",@"url"]];
        [result addObject:info];
    }
    return (NSArray *)result;
}
+ (NSString *)removeScopesFromTitle:(NSString *)title {
    NSArray *components = [title componentsSeparatedByString:@"("];
    if ([components count]) {
        title = [components firstObject];
    }
    return title;
}
+ (BOOL)isJSONvalid:(NSDictionary *)dict {
    NSNumber *value = [dict objectForKey:@"resultCount"];
    if ([value integerValue] > 0) {
        return true;
    }
    return false;
}
+ (BOOL)checkLinkWithString:(NSString *)link {
    if ([link containsString:@"https://itun."] || [link containsString:@"https://itunes."]) {
        return YES;
    }
    return NO;
}
+ (NSString *)removeAllSymbols:(NSString *)str {
    str = [str stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSMutableArray *arr = (NSMutableArray *)[str componentsSeparatedByString:@" "];
    for (int i = 0; i < [arr count]; ++i) {
        arr[i] = [arr[i] stringByTrimmingCharactersInSet:[NSCharacterSet punctuationCharacterSet]];
        arr[i] = [arr[i] stringByTrimmingCharactersInSet:[NSCharacterSet whitespaceCharacterSet]];
        if ([arr[i] length] == 0) {
            [arr removeObjectAtIndex:i];
        }
    }
    str = [arr componentsJoinedByString:@" "];
    return str;
}

#pragma mark - parse
+ (NSString *)storefrontCountryWithURL:(NSString *)url {
    NSArray *compon = [url componentsSeparatedByString:@"/"];
//    return [compon[3] uppercaseString];
    return compon[3];
}
+ (NSString *)trackIDWithURL:(NSString *)url {
    
    NSArray *compon = [url componentsSeparatedByString:@"="];
    NSString *productId;
    for (int i = 0; i < [compon count];++i) {
        if ([[compon objectAtIndex:i] containsString:@"?i"]) {
            productId = [compon objectAtIndex:i+1];
        }
    }
    if ([productId containsString:@"&"]) {
        NSArray *componLast = [productId componentsSeparatedByString:@"&"];
        productId = [componLast firstObject];
    }
    return productId;
}
+ (NSURL *)configureLookupURLWithTrackID:(NSString *)trackID storefrontIdentifier:(NSString *)identifier {
    NSString *base = @"https://itunes.apple.com/";
    NSString *result = [[[[base stringByAppendingString:identifier]
                          stringByAppendingString:@"/lookup?id="]
                         stringByAppendingString:trackID]
                        stringByAppendingString:@"&entity=song"];
    return [NSURL URLWithString:result];
}

#pragma mark - extend info from song
+ (void)trackInfoWithURL:(NSString *)link withBlock:(void(^)(NSDictionary* info,
                                                             bool success,
                                                             NSError* error))block {
    
    NSURL *url = [AppleMusicSearch configureLookupURLWithTrackID:[AppleMusicSearch trackIDWithURL:link]
                                            storefrontIdentifier:[self storefrontCountryWithURL:link]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration
                                                                    defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[session dataTaskWithRequest:request
                completionHandler:^(NSData * _Nullable data,
                                    NSURLResponse * _Nullable response,
                                    NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];

            NSDictionary *data = [[json objectForKey:@"results"] objectAtIndex:0];
            NSString *title = [data objectForKey:@"trackName"];
            NSString *artist = [data objectForKey:@"artistName"];
            title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
            NSDictionary *info = @{@"title" : title, @"artist" : artist};
            block(info, YES, nil);
        } else {
            block(nil, NO, error);
        }
    }] resume];
}




@end
