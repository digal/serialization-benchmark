//
//  TestData.m
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import "TestData.h"
#import <MD5Digest/NSString+MD5.h>
@implementation TestData

+ (NSDictionary *)simpleTestData {
    return @{@"string": @"lorem ipsum", @"number": @42};
}

+ (NSDictionary *)testData {
    NSMutableDictionary* dict = [NSMutableDictionary dictionary];
    
    for (int d = 0; d<20; d++) {
        NSMutableDictionary* subdict = [NSMutableDictionary dictionary];
        
        for (int i = 0; i<20; i++) {
            NSString* key = [NSString stringWithFormat:@"string%d", i];
            NSString* value = [key MD5Digest];
            
            subdict[key] = value;
        }
        
        for (int i = 0; i<20; i++) {
            NSString* key = [NSString stringWithFormat:@"number%d", i];
            NSNumber* value = [NSNumber numberWithFloat:(0.3*i)];
            
            subdict[key] = value;
        }

        for (int i = 0; i<20; i++) {
            NSString* key = [NSString stringWithFormat:@"null%d", i];
            
            subdict[key] = [NSNull null];
        }
        
        for (int i = 0; i<20; i++) {
            NSString* key = [NSString stringWithFormat:@"array%d", i];
            NSMutableArray *valueArray = [NSMutableArray array];
            
            for (int j = 0; j<20; j++) {
                NSString* item = [NSString stringWithFormat:@"item_%d_%d", i, j];
                [valueArray addObject:item];
            }
            
            subdict[key] = [valueArray copy];
        }
        
        NSString* key = [NSString stringWithFormat:@"sub%d", d];
        dict[key] = [subdict copy];;
    }
    
    return [dict copy];
    
}

@end
