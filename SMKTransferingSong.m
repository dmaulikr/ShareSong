//
//  SMKTransferingSong.m
//  constrains
//
//  Created by Vo1 on 30/04/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKTransferingSong.h"
#import "AppleMusicSearch.h"
#import "SpotifySearch.h"
@import StoreKit;

/*
 Make connection between ViewCntroller and Spotify/AppleMusic transefr classes.
 For appleMusic needed request, that will be done in -appleMusicFetchStorefrontRegion
 
 */

@interface SMKTransferingSong() <MPMediaPickerControllerDelegate>
@property (nonatomic) NSString *appleMusicFrontStoreId;
@end

@implementation SMKTransferingSong

- (instancetype)init {
    if (self = [super init]) {
        self.appleMusicFrontStoreId = [[NSString alloc] init];
        [self appleMusicFetchStorefrontRegion];
        
    }
    return self;
}

+ (bool)isSuitableLink:(NSString *)link {
    if ([AppleMusicSearch checkLinkWithString:link] || [SpotifySearch checkLinkWithString:link]) {
        return YES;
    }
    return NO;
}

- (void)transferSongWithLink:(NSString *)link withSuccessBlock:(void(^)(NSString *str))successBlock withFailureBlock:(void(^)())failureBlock {
    if ([SpotifySearch checkLinkWithString:link]) {
        [self fromSpotifyToAppleMusic:link withSuccessBlock:successBlock withFailureBlock:failureBlock];
    } else if ([AppleMusicSearch checkLinkWithString:link]) {
        [self fromAppleMusicToSpotify:link withSuccessBlock:successBlock withFailureBlock:failureBlock];
    }
}

- (void)fromSpotifyToAppleMusic:(NSString *)link withSuccessBlock:(void(^)(NSString *str))successBlock withFailureBlock:(void(^)())failureBlock {
    NSString *trackId = [SpotifySearch parseURLToGetTrackId:link];
    [SpotifySearch makeDataTaskWithTrackId:trackId withBlock:^(NSString *terms, bool success, NSError *error) {
        if (success) {
            [AppleMusicSearch makeDataWithRequestString:terms withFrontStoreID:self.appleMusicFrontStoreId withBlock:^(NSString *url, bool success) {
                if (success) {
                    successBlock(url);
                } else {
                    failureBlock();
                }
            }];
        } else {
            NSLog(@"%@", error);
        }
    }];
}
- (void)fromAppleMusicToSpotify:(NSString *)link withSuccessBlock:(void(^)(NSString *str))successBlock withFailureBlock:(void(^)())failureBlock {
    [AppleMusicSearch getAttributesWithAppleMusicLink:link withBlock:^(NSString *info, bool success, NSError *error) {
        if (success) {
            [SpotifySearch makeDataTaskWithTemp:info withBlock:^(NSString *url, bool success, NSError *error) {
                if (success) {
                    successBlock(url);
                } else {
                    NSLog(@"%@", error);
                    failureBlock();
                }
            }];
        } else {
            NSLog(@"%@", error);
        }
    }];
    
    
}

- (void)appleMusicFetchStorefrontRegion {
    SKCloudServiceController *serviceController = [[SKCloudServiceController alloc] init];
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        if (status) {
            [serviceController requestStorefrontIdentifierWithCompletionHandler:^(NSString * _Nullable storefrontIdentifier, NSError * _Nullable error) {
                if (error) {
                    NSLog(@"%@",error);
                }
                self.appleMusicFrontStoreId = [storefrontIdentifier substringToIndex:6];
            }];
        }
    }];
}



@end
