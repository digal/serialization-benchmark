//
//  OKMBenchmarkCase.m
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import "BenchmarkCase.h"

@implementation BenchmarkResult

@end

@implementation BenchmarkCase

- (instancetype)initWithName:(NSString*)name
{
    self = [super init];
    if (self) {
        _name = name;
    }
    return self;
}

- (BenchmarkResult*)runWithSample:(NSDictionary *)sample {
    NSParameterAssert(self.serializeBlock);
    NSParameterAssert(self.deserializeBlock);
    NSParameterAssert(sample);
    
    BenchmarkResult *result = [[BenchmarkResult alloc] init];
    
    CFAbsoluteTime t0 = CFAbsoluteTimeGetCurrent();
    
    NSData *data = self.serializeBlock(sample);
    
    result.serializeTime = CFAbsoluteTimeGetCurrent() - t0;
    
    if (data) {
        CFAbsoluteTime t1 = CFAbsoluteTimeGetCurrent();
        NSDictionary* dict = self.deserializeBlock(data);
        result.deserializeTime = CFAbsoluteTimeGetCurrent() - t1;
    }
    
    return result;
}

@end
