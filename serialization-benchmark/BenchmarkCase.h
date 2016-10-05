//
//  OKMBenchmarkCase.h
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import <Foundation/Foundation.h>
@class UIColor;

typedef NSData*(^SerializeBlock)(NSDictionary* dict);
typedef NSDictionary*(^DeserializeBlock)(NSData* data);

@interface BenchmarkResult : NSObject

@property (nonatomic, assign) NSUInteger dataSize;
@property (nonatomic, assign) CFAbsoluteTime serializeTime;
@property (nonatomic, assign) CFAbsoluteTime deserializeTime;

@end

@interface BenchmarkCase : NSObject

- (instancetype)initWithName:(NSString*)name color:(UIColor*)color;

@property (nonatomic, readonly) NSString* name;
@property (nonatomic, readonly) UIColor* color;
@property (nonatomic, copy) SerializeBlock serializeBlock;
@property (nonatomic, copy) DeserializeBlock deserializeBlock;

- (BenchmarkResult*)runWithSample:(NSDictionary*)sample;

@end
