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
@property (nonatomic) NSString *title;
@property (nonatomic) NSString *artist;
@property (nonatomic) NSString *spotifyLink;
@property (nonatomic) NSString *appleMusicLink;

@end

@implementation SMKSong

- (instancetype)initWithTitle:(NSString*)title artist:(NSString *)artist
                   albumCover:(UIImage *)img spotifyLink:(NSString *)spotifylink appleMusicLink:(NSString *)appleMusicLink {
    if (self = [super init]) {
        self.title = title;
        self.artist = artist;
        self.img = img;
        self.spotifyLink = spotifylink;
        self.appleMusicLink = appleMusicLink;
    }
    return self;
}

- (UIImage *)albumCover {
    return self.img;
}
- (NSString *)title {
    return self.title;
}
- (NSString *)artist {
    return self.artist;
}
- (NSString *)spotifyLink {
    return self.spotifyLink;
}
- (NSString *)appleMusicLink {
    return self.appleMusicLink;
}

@end
