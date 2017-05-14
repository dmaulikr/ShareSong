//
//  SMKSong.m
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import "SMKSong.h"


@interface SMKSong()

@property (nonatomic) UIImage *img;
@property (nonatomic, copy) NSString *title;
@property (nonatomic, copy) NSString *artist;
@property (nonatomic, copy) NSString *spotifyLink;
@property (nonatomic, copy) NSString *appleMusicLink;

@end

@implementation SMKSong

- (instancetype)initWithTitle:(NSString*)title artist:(NSString *)artist
                   albumCover:(UIImage *)img spotifyLink:(NSString *)spotifyLink appleMusicLink:(NSString *)appleMusicLink {
    self = [super init];
    if (self) {
        self.title = title;
        self.artist = artist;
        self.spotifyLink = spotifyLink;
        self.appleMusicLink = appleMusicLink;
        self.img = img;
    }
    return self;
}

- (UIImage *)albumCover {
    return self.img;
}
- (NSString *)title {
    return _title;
}
- (NSString *)artist {
    return _artist;
}
- (NSString *)spotifyLink {
    return _spotifyLink;
}
- (NSString *)appleMusicLink {
    return _appleMusicLink;
}
- (NSString *)description {
    return [NSString stringWithFormat:@"Title: %@\nArtist: %@\nSpotLink: %@\nAppMLink: %@\nImg: %@", self.title, self.artist, self.spotifyLink, self.appleMusicLink, self.img];
}

@end
