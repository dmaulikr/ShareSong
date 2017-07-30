//
//  SMKSong.h
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>
@import UIKit;

@interface SMKSong : NSObject

- (instancetype)initWithTitle:(NSString*)title artist:(NSString *)artist albumName:(NSString *)albumName
                   albumCover:(UIImage *)img spotifyLink:(NSString *)spotifyLink appleMusicLink:(NSString *)appleMusicLink;
- (UIImage *)albumCover;
- (NSString *)title;
- (NSString *)artist;
- (NSString *)spotifyLink;
- (NSString *)appleMusicLink;
- (NSString *)description;
@end
