//
//  SMKHistoryData.h
//  ShareSong
//
//  Created by Vo1 on 13/05/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>
@class SMKSong;
@interface SMKHistoryData : NSObject

+ (instancetype)sharedData;

- (void)addSongWithDict:(NSDictionary *)data;
- (SMKSong*)songAtIndex:(NSUInteger)index;
- (NSInteger)countOfSongs;
- (BOOL)isMemberWith:(NSString *)link;
- (BOOL)saveChanges;

@end
