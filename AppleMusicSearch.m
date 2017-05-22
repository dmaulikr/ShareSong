//
//  AppleMusicSearch.m
//  constrains
//
//  Created by Vo1 on 18/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "AppleMusicSearch.h"

@implementation AppleMusicSearch

NSString *appleMusicURLWithTermFrontStoreID = @"https://itunes.apple.com/search?";

#pragma mark - download Data
+ (void)makeDataWithRequestString:(NSString *)requestString withFrontStoreID:(NSString *)frontstoreId withBlock:(void(^)(NSDictionary *dict,bool success))block {
    if (!requestString) {return;}
    NSString *encodeTemp = [requestString stringByAddingPercentEncodingWithAllowedCharacters:[NSCharacterSet URLHostAllowedCharacterSet]];
    NSString *prepareForURL = [NSString stringWithFormat:@"%@term=%@&entity=song&s=%@",appleMusicURLWithTermFrontStoreID,encodeTemp, frontstoreId];
    NSURL *url = [NSURL URLWithString:prepareForURL];
    NSURLSession *session = [NSURLSession sessionWithConfiguration:[NSURLSessionConfiguration defaultSessionConfiguration]];
    [[session dataTaskWithURL:url completionHandler:^(NSData * _Nullable data, NSURLResponse * _Nullable response, NSError * _Nullable error) {
        if (!error) {
            NSDictionary *json = [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
            if ([AppleMusicSearch isJSONvalid:json]) {
                NSDictionary *dict = [AppleMusicSearch parseJSON:json];
                block(dict,YES);
            } else {
                block(nil,NO);
            }
        } else {
            NSLog(@"%@\n%s", error, __FUNCTION__);
            block(nil,NO);
        }
    }] resume];
}
#pragma mark - check/parse JSON/Link
+ (NSString *)checkTheTitle:(NSString *)title {
    NSArray *components = [title componentsSeparatedByString:@"("];
    if ([components count]) {
        title = [components firstObject];
    }
    return title;
}
+ (NSDictionary *)parseJSON:(NSDictionary *)json {
    NSString *title = [[[json objectForKey:@"results"] objectAtIndex:0]objectForKey:@"trackCensoredName"];
    NSString *artist = [[[json objectForKey:@"results"] objectAtIndex:0]objectForKey:@"artistName"];
    NSString *url = [[[json objectForKey:@"results"] objectAtIndex:0] objectForKey:@"trackViewUrl"];
    NSString *urlWithImg = [[[json objectForKey:@"results"] objectAtIndex:0]objectForKey:@"artworkUrl100"];
    NSDictionary *dict = [[NSDictionary alloc] initWithObjectsAndKeys:url,@"url",title,@"title",artist,@"artist",urlWithImg,@"imgLink", nil];
    return dict;
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
#pragma marl - parse
+ (NSString *)parseURLforProductId:(NSString *)url {
    
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
#pragma mark - extend info from song
+ (void)getAttributesWithAppleMusicLink:(NSString *)link withBlock:(void(^)(NSString* info, bool success, NSError* error))block {
    MPMediaLibrary *library = [MPMediaLibrary defaultMediaLibrary];
    
    [library addItemWithProductID:[AppleMusicSearch parseURLforProductId:link] completionHandler:^(NSArray<__kindof MPMediaEntity *> * _Nonnull entities, NSError * _Nullable error) {
        if (error) {
            NSLog(@"%@\n%s", error, __FUNCTION__);
        } else {
            if ([entities count]) {
                MPMediaItem *item = [entities lastObject];
                NSString *title = item.title;
                NSString *artist = item.artist;
                title = [AppleMusicSearch checkTheTitle:title];
                title = [title stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                artist = [artist stringByReplacingOccurrencesOfString:@" " withString:@"+"];
                NSString *info = [NSString stringWithFormat:@"%@+%@", title,artist];
                block(info, YES, nil);
            } else {
                block(nil, NO, error);
            }
        }
    }];
}

@end
