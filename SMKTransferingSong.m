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



#pragma mark - Initializer
+ (instancetype)sharedTransfer {
    static SMKTransferingSong *sharedTransfer = nil;
    if (!sharedTransfer) {
        sharedTransfer = [[self alloc] initPrivate];
    }
    return sharedTransfer;
}
- (instancetype)init {
    @throw [NSException exceptionWithName:@"Singleton" reason:@"Use +[SMKTransferingSong sharedTransfer]" userInfo:nil];
    return nil;
}
- (instancetype)initPrivate {
    if (self = [super init]) {
        self.appleMusicFrontStoreId = [[NSString alloc] init];
        self.tokenData = [[NSDictionary alloc] init];
        [self appleMusicFetchStorefrontRegion];
    }
    return self;
}

#pragma mark - check Links
+ (bool)isSuitableLink:(NSString *)link {
    if ([AppleMusicSearch checkLinkWithString:link] || [SpotifySearch checkLinkWithString:link]) {
        return YES;
    }
    return NO;
}
+ (bool)isAppleMusicLink:(NSString *)link {
    return [AppleMusicSearch checkLinkWithString:link];
}

#pragma mark - Start transfer Links
- (void)transferSongWithLink:(NSString *)link withSuccessBlock:(void(^)(NSDictionary *dict))successBlock withFailureBlock:(void(^)())failureBlock {
    if ([SpotifySearch checkLinkWithString:link]) {
        
        [self fromSpotifyToAppleMusic:link withSuccessBlock:successBlock withFailureBlock:failureBlock];
    } else if ([AppleMusicSearch checkLinkWithString:link]) {
        
        [self fromAppleMusicToSpotify:link withSuccessBlock:successBlock withFailureBlock:failureBlock];
    }
}
- (void)fromSpotifyToAppleMusic:(NSString *)link withSuccessBlock:(void(^)(NSDictionary *dict))successBlock withFailureBlock:(void(^)())failureBlock {
    NSString *trackId = [SpotifySearch parseURLToGetTrackId:link];
    [SpotifySearch makeDataTaskWithTrackId:trackId withToken:self.tokenData withBlock:^(NSDictionary *terms, BOOL success, NSError *error) {
        if (success) {
            [AppleMusicSearch makeDataWithDictionary:terms withFrontStoreID:self.appleMusicFrontStoreId withBlock:^(NSDictionary* dict, bool success) {
                if (success) {
                    successBlock(dict);
                } else {
                    failureBlock();
                }
            }];
        } else {
            failureBlock();
        }
    }];
}
- (void)fromAppleMusicToSpotify:(NSString *)link withSuccessBlock:(void(^)(NSDictionary *dict))successBlock withFailureBlock:(void(^)())failureBlock {
    [AppleMusicSearch getAttributesWithAppleMusicLink:link withBlock:^(NSDictionary *info, bool success, NSError *error) {
        if (success) {
            [SpotifySearch makeDataTaskWithTemp:info withToken:self.tokenData withBlock:^(NSDictionary *dict, BOOL success, NSError *error) {
                if (success) {
                    successBlock(dict);
                } else {
                    failureBlock();
                }
            }];
        } else {
            @throw [NSException exceptionWithName:error.localizedDescription reason:error.domain userInfo:error.userInfo];
        }
    }];
    
    
}

#pragma mark - get AppleStore id
- (void)appleMusicFetchStorefrontRegion {
    SKCloudServiceController *serviceController = [[SKCloudServiceController alloc] init];
    [MPMediaLibrary requestAuthorization:^(MPMediaLibraryAuthorizationStatus status) {
        
        if (status) {
        
            [serviceController requestStorefrontIdentifierWithCompletionHandler:^(NSString * _Nullable storefrontIdentifier, NSError * _Nullable error) {
                if (error) {
                    @throw [NSException exceptionWithName:error.localizedDescription reason:error.domain userInfo:error.userInfo];
                }
                self.appleMusicFrontStoreId = [storefrontIdentifier substringToIndex:6];
            }];
        }
    }];
}


@end
