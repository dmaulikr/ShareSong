//
//  AppleMusicSearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//https://itunes.apple.com/ua/lookup?id=1245248621&entity=song

#import "AppleMusicSearch.h"

@implementation AppleMusicSearch

NSString *appleMusicURLWithTermFrontStoreID = @"https://itunes.apple.com/search?";



#pragma mark - download Data
+ (void)makeDataWithDictionary:(NSDictionary *)dict withFrontStoreID:(NSString *)frontstoreId withBlock:(void(^)(NSDictionary *dict,bool success))block {
    
    
    //////////////////////
    
    NSString *str1 = @"Funky'n Brussels (Deluxe Extended Mix)";
    NSString *str2 = @"Funky'n Brussels (Deluxe Mix)";
    NSString *p = @"Funky'n Brussels - Deluxe Mix";
    
    NSArray *arr = [NSArray arrayWithObjects:[NSDictionary dictionaryWithObject:str1 forKey:@"title"],[NSDictionary dictionaryWithObject:str2 forKey:@"title"], nil];
    NSLog(@"%@", [AppleMusicSearch filterByTitle:p in:arr]);
    
//    NSLog(@"%@", [AppleMusicSearch removeAllSymbols:str1]);
//    NSLog(@"%@", [AppleMusicSearch removeAllSymbols:str2]);
//    NSLog(@"%@", [AppleMusicSearch removeAllSymbols:p]);
//    
    
    
    
    //////////////////////
//    
//    NSString *title = [dict objectForKey:@"title"];
//    NSString *artist = [dict objectForKey:@"artist"];
//    NSString *albumName = [dict objectForKey:@"albumName"];
//    
//
//    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    NSString *encodeArtist = [artist stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
//    
//    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@+%@&entity=song&s=%@",appleMusicURLWithTermFrontStoreID,encodeTitle,encodeArtist, frontstoreId];
//    NSURL *url = [NSURL URLWithString:prepareForURL];
//    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
//    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
//        if (!error) {
//            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
//            
//            NSArray *filtred = [AppleMusicSearch filterBy:title by:albumName by:artist in:[AppleMusicSearch arrayWith:json]];
//            
//            if ([filtred count]) {
//                block([filtred firstObject],YES);
//            } else {
//                [AppleMusicSearch makeDataWithTitle:title withFrontStoreID:frontstoreId withBlock:^(NSDictionary *dict, bool success) {
//                    block(dict,success);
//                }];
//            }
//        } else {
//            @throw [NSException exceptionWithName:@"AppFromSpot" reason:error.localizedDescription userInfo:error.userInfo];
//        }
//    }] resume];
}
+ (void)makeDataWithTitle:(NSString *)songTitle withFrontStoreID:(NSString *)frontstoreId withBlock:(void(^)(NSDictionary *dict,bool success))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@&entity=song&s=%@",appleMusicURLWithTermFrontStoreID,encodeTitle, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *filtred = [AppleMusicSearch filterBy:title by:nil by:nil in:[AppleMusicSearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES);
            } else {
                [AppleMusicSearch makeDataWithShortTitle:[AppleMusicSearch removeScopesFromTitle:title] withFrontStoreID:frontstoreId withBlock:^(NSDictionary *dict, bool success) {
                    block(dict,success);
                }];
            }
        } else {
            @throw [NSException exceptionWithName:@"AppFromSpot" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}
+ (void)makeDataWithShortTitle:(NSString *)songTitle withFrontStoreID:(NSString *)frontstoreId withBlock:(void(^)(NSDictionary *dict,bool success))block {
    NSString *title = songTitle;
    NSString *encodeTitle = [title stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@&entity=song&s=%@",appleMusicURLWithTermFrontStoreID,encodeTitle, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            NSArray *filtred = [AppleMusicSearch filterBy:title by:nil by:nil in:[AppleMusicSearch arrayWith:json]];
            if ([filtred count]) {
                block([filtred firstObject],YES);
            } else {
                block(nil,NO);
            }
        } else {
            @throw [NSException exceptionWithName:@"AppFromSpot" reason:error.localizedDescription userInfo:error.userInfo];
        }
    }] resume];
}

#pragma mark - filter
+ (NSArray *)filterBy:(NSString *)predicate in:(NSArray *)src for:(NSString *)key {
    
    predicate = [predicate stringByReplacingOccurrencesOfString:@"+" withString:@" "];
    NSMutableArray *arr = [[NSMutableArray alloc] init];
    for (NSDictionary *obj in src) {
        if ([[obj objectForKey:key] isEqualToString:predicate]) {
            [arr addObject:obj];
        }
    }
    return arr;
}
+ (NSArray *)filterBy:(NSString *)title by:(NSString *)albumName by:(NSString *)artist in:(NSArray *)src {
    NSMutableArray *keys = [[NSMutableArray alloc] init];
    NSMutableArray *pred = [[NSMutableArray alloc] init];
    
    if (artist != nil) {
        [keys addObject:@"artist"];
        [pred addObject:artist];
    }
    if (albumName != nil) {
        [keys addObject:@"albumName"];
        [pred addObject:albumName];
    }

    [keys addObject:@"title"];
    [pred addObject:title];
    
    
    NSMutableArray *result = [[NSMutableArray alloc] initWithArray:src];
    
    for (int i = 0;  i < [keys count]; ++i) {
        NSArray *temp = [AppleMusicSearch filterBy:[pred objectAtIndex:i] in:result for:[keys objectAtIndex:i]];
        result = (NSMutableArray *)temp;
    }
    return (NSArray *)result;
}
+ (NSArray *)filterByTitle:(NSString *)pred in:(NSArray *)arr {
    
    NSMutableArray *result = [[NSMutableArray alloc] init];
    pred = [AppleMusicSearch removeAllSymbols:pred];
    for (NSDictionary *obj in arr) {
        NSString *title = [obj objectForKey:@"title"];
        BOOL flag = true;
        NSString *temp = [AppleMusicSearch removeAllSymbols:title];
        
        NSArray *components = [temp componentsSeparatedByString:@" "];
        for (NSString *comp in components) {
            if (![pred containsString:comp]) {
                flag = false;
            }
        }
        
        if (flag) {
            [result addObject:obj];
        }
    }
    
    if (![result count]) {
        
    }
    
    
    return result;
}

#pragma mark - check/parse JSON/Link
+ (NSArray *)arrayWith:(NSDictionary *)json {
    
    NSArray *arr = [json objectForKey:@"results"];
    NSMutableArray *result = [[NSMutableArray alloc] init];
    
    for (NSDictionary *dict in arr) {
//        NSLog(@"%@", dict);
        NSString *artwork = [dict objectForKey:@"artworkUrl100"];
        NSString *url = [[[dict objectForKey:@"trackViewUrl"] componentsSeparatedByString:@"&"] objectAtIndex:0];
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
    if ([link containsString:@"https://itun."]) {
        return YES;
    }
    return NO;
}
+ (NSString *)removeAllSymbols:(NSString *)str {
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
    NSLog(@"%@", trackID);
    NSLog(@"%@", identifier);
    NSString *base = @"https://itunes.apple.com/";
    NSString *result = [[[[base stringByAppendingString:identifier]
                          stringByAppendingString:@"/lookup?id="]
                         stringByAppendingString:trackID]
                        stringByAppendingString:@"&entity=song"];
    return [NSURL URLWithString:result];
}

#pragma mark - extend info from song
+ (void)trackInfoWithURL:(NSString *)link withBlock:(void(^)(NSDictionary* info, bool success, NSError* error))block {
    
    NSURL *url = [AppleMusicSearch configureLookupURLWithTrackID:[AppleMusicSearch trackIDWithURL:link] storefrontIdentifier:[self storefrontCountryWithURL:link]];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    NSURLRequest *request = [NSURLRequest requestWithURL:url];
    [[session dataTaskWithRequest:request completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
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
