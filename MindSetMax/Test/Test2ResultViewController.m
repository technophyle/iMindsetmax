//
//  TestResultViewController.m
//  MindSetMax
//
//  Created by Ethan Hendriks on 2/6/15.
//  Copyright (c) 2015 Borum Data. All rights reserved.
//

#import "Test2ResultViewController.h"
#import "UUChart.h"

@interface Test2ResultViewController () <UUChartDataSource>

@end

@implementation Test2ResultViewController

- (void)viewDidLoad {
    [super viewDidLoad];
    
    self.navigationItem.title = @"Result";
    
    [self switchView:nil];
}

- (void)switchView:(id)sender {
    UUChart *chartView = [[UUChart alloc]initwithUUChartDataFrame:self.graphView.frame
                                                       withSource:self
                                                        withStyle:UUChartBarStyle];
    [chartView showInView:self.view];
}

- (void)didReceiveMemoryWarning {
    [super didReceiveMemoryWarning];
    // Dispose of any resources that can be recreated.
}

- (NSInteger)truncatedMaxScore {
    NSInteger maxScore = 0;
    for (NSInteger i = 0; i < self.scores.count; i++) {
        if (maxScore < [self.scores[i] integerValue]) maxScore = [self.scores[i] integerValue];
    }
    if (maxScore % 5 != 0) {
        maxScore = (maxScore / 5 + 1) * 5;
    }
    
    return maxScore;
}

/*
#pragma mark - Navigation

// In a storyboard-based application, you will often want to do a little preparation before navigation
- (void)prepareForSegue:(UIStoryboardSegue *)segue sender:(id)sender {
    // Get the new view controller using [segue destinationViewController].
    // Pass the selected object to the new view controller.
}
*/

#pragma mark - UUChart DataSource
#pragma mark @required
//横坐标标题数组
- (NSArray *)UUChart_xLableArray:(UUChart *)chart
{
//    return @[@"Visual",@"Auditive",@"Kinesthetic",@"Auditive Digital"];
    return self.keys;
}
//数值多重数组
- (NSArray *)UUChart_yValueArray:(UUChart *)chart
{
//    NSArray *ary = @[@"34",@"12",@"32",@"7"];
//    return @[ary];
    return @[self.scores];
}
- (double)UUChart_yLabelGap {
    return [self truncatedMaxScore]/5;
}

#pragma mark @optional
//颜色数组
- (NSArray *)UUChart_ColorArray:(UUChart *)chart
{
    return @[UUGreen,UURed,UUBrown];
}
//显示数值范围
- (CGRange)UUChartChooseRangeInLineChart:(UUChart *)chart
{
    NSInteger maxScore = [self truncatedMaxScore];
    return CGRangeMake(maxScore, 0);
}

#pragma mark 折线图专享功能

//标记数值区域
- (CGRange)UUChartMarkRangeInLineChart:(UUChart *)chart
{
    return CGRangeZero;
}

//判断显示横线条
- (BOOL)UUChart:(UUChart *)chart ShowHorizonLineAtIndex:(NSInteger)index
{
    return YES;
}

//判断显示最大最小值
- (BOOL)UUChart:(UUChart *)chart ShowMaxMinAtIndex:(NSInteger)index
{
    return YES;
}

@end
