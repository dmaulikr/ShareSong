//
//  Searcher.h
//  ShareSong
//
//  Created by Vo1 on 31/07/2017.
//  Copyright © 2017 Samoilenko Volodymyr. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface Searcher : NSObject
+ (NSArray *)searchTheNeededOneWith:(NSDictionary *)pred in:(NSArray *)src;
+ (NSDictionary *)decodeData:(NSDictionary *)src;
@end
