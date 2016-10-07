//
//  ViewController.m
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import "ViewController.h"

#import "TestData.h"
//#import <MessagePack/MessagePackPacker.h>
//#import <MessagePack/MessagePackParser.h>

#import <MessagePackCoder/MsgPackArchiver.h>
#import <MessagePackCoder/MsgPackUnarchiver.h>
//#import <MsgPackSerialization/MsgPackSerialization.h>
#import <MPMessagePack/MPMessagePack.h>
#import <MPackObjc/MPackObjc.h>
#import <JBChartView/JBBarChartView.h>
#import "BenchmarkCase.h"

#import <msgpack/MessagePack.h>

@interface ViewController ()<JBBarChartViewDelegate, JBBarChartViewDataSource>

@property (weak, nonatomic) IBOutlet UIButton *runBigTestBtn;
@property (weak, nonatomic) IBOutlet UIButton *runSmallTestBtn;
@property (weak, nonatomic) IBOutlet UILabel *testNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *iterationLabel;
@property (weak, nonatomic) IBOutlet UILabel *titleLabel;
@property (weak, nonatomic) IBOutlet JBBarChartView *barChart;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSMutableArray *labels;
@property (nonatomic, strong) NSMutableArray *colors;
@end

@implementation ViewController

- (NSArray*)cases {
    BenchmarkCase* jsonCase = [[BenchmarkCase alloc] initWithName:@"JSON" color:[UIColor blackColor]];
    
    jsonCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [NSJSONSerialization dataWithJSONObject:dict options:0 error:nil];
    };
    
    jsonCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:nil];
    };

    BenchmarkCase *coderCase = [[BenchmarkCase alloc] initWithName:@"coder" color:[UIColor redColor]];
    
    coderCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [MsgPackArchiver archivedDataWithRootObject:dict];
    };
    
    coderCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [MsgPackUnarchiver unarchiveObjectWithData:data];
    };
    
    BenchmarkCase *msgpackCase = [[BenchmarkCase alloc] initWithName:@"msgpack" color:[UIColor blueColor]];
    
    msgpackCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [dict messagePack];
    };
    
    msgpackCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [data messagePackParse];
    };
    
    BenchmarkCase *gabrielCase = [[BenchmarkCase alloc] initWithName:@"gabriel" color:[UIColor greenColor]];
    
    gabrielCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [dict mp_messagePack];
    };
    
    gabrielCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [MPMessagePackReader readData:data error:nil];
    };

    BenchmarkCase *mpackCase = [[BenchmarkCase alloc] initWithName:@"mpack" color:[UIColor purpleColor]];
    
    mpackCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [dict mpo_messagePackData];
    };
    
    mpackCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [data mpo_parseMessagePackData];
    };

//    BenchmarkCase *matttCase = [[BenchmarkCase alloc] initWithName:@"mattt" color:[UIColor orangeColor]];
//    
//    matttCase.serializeBlock = ^NSData*(NSDictionary *dict) {
//        return [MsgPackSerialization dataWithMsgPackObject:dict options:0 error:nil];
//    };
//    
//    matttCase.deserializeBlock = ^NSDictionary*(NSData *data) {
//        return [MsgPackSerialization MsgPackObjectWithData:data options:0 error:nil];
//    };
//    
//    return @[jsonCase, coderCase, msgpackCase, gabrielCase, matttCase];
    return @[jsonCase, coderCase, msgpackCase, gabrielCase, mpackCase];
}

- (IBAction)runTest:(UIButton*)sender {
    self.titleLabel.text = sender.titleLabel.text;
    NSArray* cases = [self cases];
    self.data   = [NSMutableArray array];
    self.labels = [NSMutableArray array];
    self.colors = [NSMutableArray array];
    
    for (BenchmarkCase *bCase in cases) {
        [self.data addObject:@0];
        [self.labels addObject:bCase.name];
        [self.colors addObject:bCase.color];
    }
    
    int runs = (sender == self.runSmallTestBtn) ? 10000 : 100;

    sender.enabled = NO;

    NSDictionary* testData = (sender == self.runSmallTestBtn) ? [TestData simpleTestData] : [TestData testData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int caseIndex = 0; caseIndex<cases.count; caseIndex++) {
            BenchmarkCase *benchmarkCase = cases[caseIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.testNameLabel.text = self.labels[caseIndex];
                self.testNameLabel.textColor = self.colors[caseIndex];
                self.iterationLabel.text = [NSString stringWithFormat:@"%d/%d", 0, runs];
            });

                for (int run = 1; run <= runs; run++) {
                    @autoreleasepool {
                        BenchmarkResult *result = [benchmarkCase runWithSample:testData];
                        double resultTime = result.serializeTime + result.deserializeTime;
                        
                        dispatch_async(dispatch_get_main_queue(), ^{
                            self.iterationLabel.text = [NSString stringWithFormat:@"%d/%d", run, runs];
                            double oldTotal = [self.data[caseIndex] doubleValue];
                            self.data[caseIndex] = @(oldTotal + resultTime);
                        });
                    }
                }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.barChart reloadData];
            });
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
            self.testNameLabel.text = nil;
            self.iterationLabel.text = nil;
        });
    });
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labels = [NSMutableArray array];
    self.data   = [NSMutableArray array];
    self.colors = [NSMutableArray array];
    
    
    
    self.barChart.dataSource = self;
    self.barChart.delegate = self;
    self.barChart.minimumValue = 0;
    self.barChart.clipsToBounds = NO;
    // Do any additional setup after loading the view, typically from a nib.
}


- (void)viewDidLayoutSubviews {
    [self.barChart reloadData];
}
- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

#pragma mark - JBBarChartViewDataSource

- (UIView *)barChartView:(JBBarChartView *)barChartView barViewAtIndex:(NSUInteger)index {
    UIView *view = [[UIView alloc] init];
    view.backgroundColor = [self barChartView:barChartView colorForBarViewAtIndex:index];
    view.clipsToBounds = NO;
    UILabel *l = [[UILabel alloc] init];
    l.autoresizingMask = UIViewAutoresizingFlexibleWidth | UIViewAutoresizingFlexibleTopMargin;
    l.text = [NSString stringWithFormat:@"%@\n %.4f", self.labels[index], [self.data[index] floatValue]];
    l.numberOfLines = 2;
    l.backgroundColor = [UIColor whiteColor];
    l.textColor = [UIColor blackColor];
    l.font = [UIFont systemFontOfSize:12];
    [l sizeToFit];
    [view addSubview:l];
    
    return view;
}

- (NSUInteger)numberOfBarsInBarChartView:(JBBarChartView *)barChartView {
    return self.data.count;
}

- (CGFloat)barChartView:(JBBarChartView *)barChartView heightForBarViewAtIndex:(NSUInteger)index {
    return [self.data[index] doubleValue];
}

- (UIColor *)barChartView:(JBBarChartView *)barChartView colorForBarViewAtIndex:(NSUInteger)index {
    return self.colors[index];
}

@end
