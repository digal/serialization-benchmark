//
//  ViewController.m
//  serialization-benchmark
//
//  Created by Юрий Буянов on 05/02/15.
//  Copyright (c) 2015 odnoklassniki. All rights reserved.
//

#import "ViewController.h"

#import "TestData.h"
#import <MessagePack/MessagePack.h>
#import <MessagePackCoder/MsgPackArchiver.h>
#import <MessagePackCoder/MsgPackUnarchiver.h>
#import <MsgPackSerialization/MsgPackSerialization.h>
#import <MPMessagePack/MPMessagePack.h>
#import <JBChartView/JBBarChartView.h>
#import "BenchmarkCase.h"

#define RUNS 100

@interface ViewController ()<JBBarChartViewDelegate, JBBarChartViewDataSource>

@property (weak, nonatomic) IBOutlet UILabel *testNameLabel;
@property (weak, nonatomic) IBOutlet UILabel *iterationLabel;
@property (weak, nonatomic) IBOutlet JBBarChartView *barChart;
@property (nonatomic, strong) NSMutableArray *data;
@property (nonatomic, strong) NSArray *labels;
@property (nonatomic, strong) NSArray *colors;
@end

@implementation ViewController

- (IBAction)runTest:(UIButton*)sender {
    self.data   = [NSMutableArray arrayWithObjects:@0, @0, @0, @0, @0, nil];

    sender.enabled = NO;
    
    __block NSError* error = nil;
    
    BenchmarkCase* jsonCase = [[BenchmarkCase alloc] initWithName:@"JSON"];

    jsonCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [NSJSONSerialization dataWithJSONObject:dict options:0 error:&error];
    };

    jsonCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [NSJSONSerialization JSONObjectWithData:data options:0 error:&error];
    };
    
    BenchmarkCase *coderCase = [[BenchmarkCase alloc] initWithName:@"coder"];
    
    coderCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [MsgPackArchiver archivedDataWithRootObject:dict];
    };
    
    coderCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [MsgPackUnarchiver unarchiveObjectWithData:data];
    };

    BenchmarkCase *msgpackCase = [[BenchmarkCase alloc] initWithName:@"msgpack"];
    
    msgpackCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [dict messagePack];
    };
    
    msgpackCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [data messagePackParse];
    };
    
    BenchmarkCase *gabrielCase = [[BenchmarkCase alloc] initWithName:@"gabriel"];
    
    gabrielCase.serializeBlock = ^NSData*(NSDictionary *dict) {
      return [dict mp_messagePack];
    };
    
    gabrielCase.deserializeBlock = ^NSDictionary*(NSData *data) {
      return [MPMessagePackReader readData:data error:&error];
    };
    
    BenchmarkCase *matttCase = [[BenchmarkCase alloc] initWithName:@"mattt"];
    
    matttCase.serializeBlock = ^NSData*(NSDictionary *dict) {
        return [MsgPackSerialization dataWithMsgPackObject:dict options:0 error:&error];
    };
    
    matttCase.deserializeBlock = ^NSDictionary*(NSData *data) {
        return [MsgPackSerialization MsgPackObjectWithData:data options:0 error:&error];
    };
    
    NSArray* cases = @[jsonCase, coderCase, msgpackCase, gabrielCase, matttCase];
    NSDictionary* testData = [TestData testData];
    dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_HIGH, 0), ^{
        for (int caseIndex = 0; caseIndex<cases.count; caseIndex++) {
            BenchmarkCase *benchmarkCase = cases[caseIndex];
            dispatch_async(dispatch_get_main_queue(), ^{
                self.testNameLabel.text = self.labels[caseIndex];
                self.testNameLabel.textColor = self.colors[caseIndex];
                self.iterationLabel.text = [NSString stringWithFormat:@"%d/%d", 0, RUNS];
            });

            for (int run = 1; run <= RUNS; run++) {
                BenchmarkResult *result = [benchmarkCase runWithSample:testData];
                
                dispatch_async(dispatch_get_main_queue(), ^{
                    self.iterationLabel.text = [NSString stringWithFormat:@"%d/%d", run, RUNS];
                    double oldTotal = [self.data[caseIndex] doubleValue];
                    self.data[caseIndex] = @(oldTotal + result.serializeTime + result.deserializeTime);
                });
            }
            
            dispatch_async(dispatch_get_main_queue(), ^{
                [self.barChart reloadData];
            });
        }

        dispatch_async(dispatch_get_main_queue(), ^{
            sender.enabled = YES;
        });
    });
    

}

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.labels = @[@"JSON", @"coder", @"msgpack", @"gabriel", @"mattt"];
    self.data   = [NSMutableArray arrayWithObjects:@0.01, @0.01, @0.01, @0.01, @0.01, nil];
    self.colors = @[[UIColor blackColor], [UIColor redColor], [UIColor blueColor], [UIColor greenColor], [UIColor greenColor]];
    
    
    
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
    l.text = self.labels[index];
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
