//
//  Searcher.h
//  ShareSong
//
//  Created by Vo1 on 31/07/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Searcher : NSObject
+ (void)test;
+ (NSArray *)searchTheNeededOneWith:(NSDictionary *)pred in:(NSArray *)src;
+ (NSArray *)filterBy:(NSString *)pred forKey:(NSString *)key in:(NSArray *)src;
@end
