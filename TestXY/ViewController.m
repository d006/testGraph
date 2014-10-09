//
//  ViewController.m
//  TestXY
//
//  Created by CCWu on 2014/10/8.
//  Copyright (c) 2014年 CCWu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()

@end

@implementation ViewController
            
- (void) viewDidAppear:(BOOL)animated {
    
    //初始化数组，并放入十个 0 － 20 间的随机数
    dataArray = [[NSMutableArray alloc] init];
    dataArray = [[NSMutableArray alloc] init];
    srand(time(NULL));
    srand(time(NULL));
    for(int i=0; i< 10; i++){
        NSNumber *value = [NSNumber numberWithInt:rand()%20];
        [dataArray addObject:value];
        NSLog(@"value=%@",value);
    }
    //srand(time(NULL));
    for(int i=0; i< 10; i++){
        NSNumber *value = [NSNumber numberWithInt:rand()%20];
        [dataArray2 addObject:value];
        NSLog(@"value2=%@",value);
    }
    CGRect frame = CGRectMake(10,10, 300,100);
    
    //图形要放在一个 CPTGraphHostingView 中，CPTGraphHostingView 继承自 UIView
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:frame];
    
    //把 CPTGraphHostingView 加到你自己的 View 中
    self.view.backgroundColor = [UIColor whiteColor];
    [self.view addSubview:hostView];
    //hostView.backgroundColor = [UIColor blueColor];
    
    //在 CPTGraph 中画图，这里的 CPTXYGraph 是个曲线图
    //要指定 CPTGraphHostingView 的 hostedGraph 属性来关联
    CPTXYGraph *graph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
    hostView.hostedGraph = graph;

    
    //CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] initWithFrame:graph.frame];
    CPTScatterPlot *scatterPlot = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    scatterPlot.identifier = @"id1";
    [graph addPlot:scatterPlot];
    CPTScatterPlot *scatterPlot2 = [[CPTScatterPlot alloc] initWithFrame:graph.bounds];
    scatterPlot2.identifier = @"id2";
    [graph addPlot:scatterPlot2];
    scatterPlot.dataSource = self;
    scatterPlot2.dataSource = self; //设定数据源，需应用 CPTPlotDataSource 协议
        //设置 PlotSpace，这里的 xRange 和 yRange 要理解好，它决定了点是否落在图形的可见区域
    //location 值表示坐标起始值，一般可以设置元素中的最小值
    //length 值表示从起始值上浮多少，一般可以用最大值减去最小值的结果
    //其实我倒觉得，CPTPlotRange:(NSRange) range 好理解些，可以表示值从 0 到 20
    CPTXYPlotSpace *plotSpace = (CPTXYPlotSpace *) scatterPlot.plotSpace;
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat([dataArray count]-1)];
    NSLog(@"[dataArray count]-1=%u",[dataArray count]-1);
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(0)
                                                    length:CPTDecimalFromFloat(20)];
}

//询问有多少个数据，在 CPTPlotDataSource 中声明的
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return [dataArray count];
}

//询问一个个数据值，在 CPTPlotDataSource 中声明的
- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    if(fieldEnum == CPTScatterPlotFieldY){    //询问 Y 值时
        return [dataArray objectAtIndex:index];
    }else{                                    //询问 X 值时
        return [NSNumber numberWithInt:index];
    }
}

@end
