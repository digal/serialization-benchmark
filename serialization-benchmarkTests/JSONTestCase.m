//
//  JSONTestCase.m
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import <XCTest/XCTest.h>
#import "TestData.h"
#import <MGBenchmark/MGBenchmark.h>
#import <MGBenchmark/MGBenchmarkSession.h>
#import <msgpack/MessagePack.h>
#import <MessagePackCoder/MsgPackArchiver.h>
#import <MessagePackCoder/MsgPackUnarchiver.h>
#import <MsgPackSerialization/MsgPackSerialization.h>
#import <MPMessagePack/MPMessagePack.h>
@interface JSONTestCase : XCTestCase

@property (nonatomic, strong) NSDictionary* testData;

@end

@implementation JSONTestCase

- (void)setUp {
    [super setUp];
    self.testData = [TestData testData];

}

- (void)tearDown {
    [super tearDown];
}

- (void)testMGMsgPackSerializing {
    NSError* error = nil;
    
    NSString* sessionName = @"mp(gabriel)";
    
    MGBenchStart(sessionName);
    
    NSData *data = [self.testData mp_messagePack];
    
    XCTAssertNotNil(data);
    
    NSLog(@"%@ data length: %lu", sessionName, (unsigned long)data.length);
    
    MGBenchStep(sessionName, @"serialized");
    
    NSDictionary* deserialized = [MPMessagePackReader readData:data error:&error];
    
    MGBenchStep(sessionName, @"deserialized");
    
    MGBenchEnd(sessionName);
}

- (void)testMattMsgPackSerializing {
    NSError* error = nil;
    
    NSString* sessionName = @"matt";
    
    MGBenchStart(sessionName);
    
    NSData *data = [MsgPackSerialization dataWithMsgPackObject:self.testData options:0 error:&error];
    
    XCTAssertNotNil(data);
    
    NSLog(@"%@ data length: %lu", sessionName, (unsigned long)data.length);
    
    MGBenchStep(sessionName, @"serialized");
    
    NSDictionary* deserialized = [MsgPackSerialization MsgPackObjectWithData:data options:0 error:&error];
    
    MGBenchStep(sessionName, @"deserialized");
    
    MGBenchEnd(sessionName);
}

- (void)testJSONSerializing {
    __block NSError* error = nil;
    
    NSString* sessionName = @"JSON";

    MGBenchStart(sessionName);

    NSData *data = [NSJSONSerialization dataWithJSONObject:self.testData options:NSJSONWritingPrettyPrinted error:&error];
    
    XCTAssertNil(error);
    
    XCTAssertNotNil(data);
    
    NSLog(@"%@ data length: %lu", sessionName, (unsigned long)data.length);
    
    MGBenchStep(sessionName, @"serialized");
    
    NSDictionary* deserialized = [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    
    MGBenchStep(sessionName, @"deserialized");
    
    MGBenchEnd(sessionName);
}

- (void)testMsgPackSerializing {
    __block NSError* error = nil;
    
    NSString* sessionName = @"msgPack";
    
    MGBenchStart(sessionName);
    
    NSData *data = [self.testData messagePack];
    
    XCTAssertNil(error);
    
    XCTAssertNotNil(data);
    
    NSLog(@"%@ data length: %lu", sessionName, (unsigned long)data.length);
    
    MGBenchStep(sessionName, @"serialized");
    
    NSDictionary* deserialized = [data messagePackParse];
    
    MGBenchStep(sessionName, @"deserialized");
    
    MGBenchEnd(sessionName);
    
    //    XCTAssertEqual(self.testData, deserialized);
}

- (void)testMessagePackCoder {
    __block NSError* error = nil;
    
    NSString* sessionName = @"msgPackCoder";
    
    MGBenchStart(sessionName);
    
    NSData *data = [MsgPackArchiver archivedDataWithRootObject:self.testData];
    
    XCTAssertNil(error);
    
    XCTAssertNotNil(data);
    
    NSLog(@"%@ data length: %lu", sessionName, (unsigned long)data.length);
    
    MGBenchStep(sessionName, @"serialized");
    
    NSDictionary* deserialized = [MsgPackUnarchiver unarchiveObjectWithData:data];
    
    MGBenchStep(sessionName, @"deserialized");
    
    MGBenchEnd(sessionName);
}

@end
