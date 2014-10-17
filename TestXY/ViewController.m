//
//  ViewController.m
//  TestXY
//
//  Created by CCWu on 2014/10/8.
//  Copyright (c) 2014年 CCWu. All rights reserved.
//

#import "ViewController.h"

@interface ViewController ()
@property (strong, nonatomic) NSDictionary *dictVitalSignXYData;
@end

int vitalLineCount;
int linePosition;
CPTXYGraph *xyGraph;
CPTXYPlotSpace *plotSpace;
CPTPlotSpaceAnnotation *annotation;
CPTScatterPlot *scatterPlot;
CPTScatterPlot *linePlot;
NSTimeInterval oneDay;
NSDate *refDate;
NSMutableData *webData;

@implementation ViewController

- (void) viewDidAppear:(BOOL)animated {
    [self Conn];
    vitalLineCount = 0;
    linePosition = 0;
    self.dictVitalSignXYData= [[NSMutableDictionary alloc]init];
    //初始化数组，并放入十个 0 － 20 间的随机数
    NSMutableArray *dataArray = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray2 = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray3 = [[NSMutableArray alloc] init];
    NSMutableArray *dataArray4 = [[NSMutableArray alloc] init];
    srand(time(NULL));
    //array1
    for(int i=0; i< 6; i++){
        NSNumber *value = [NSNumber numberWithInt:rand()%7+35];//從35開始+7所以range=35~42
        [dataArray addObject:value];
    }
    NSLog(@"array1=%@",dataArray);
    //array2
    for(int i=0; i< 6; i++){
        NSNumber *value2 = [NSNumber numberWithInt:rand()%100];
        [dataArray2 addObject:value2];
    }
    //array3
    for(int i=0; i< 6; i++){
        NSNumber *value = [NSNumber numberWithInt:rand()%50];
        [dataArray3 addObject:value];
    }
    //array4
    for(int i=0; i< 6; i++){
        NSNumber *value = [NSNumber numberWithInt:rand()%14-8];//從-8開始+14所以range=-8~6
        [dataArray4 addObject:value];
    }
    NSLog(@"arr4=%@",dataArray4);
    [self BuildDataDictLineId:@"id1" DataArray:dataArray];
    [self BuildDataDictLineId:@"id2" DataArray:dataArray2];
    [self BuildDataDictLineId:@"id3" DataArray:dataArray3];
    [self BuildDataDictLineId:@"id4" DataArray:dataArray4];
    vitalLineCount = self.dictVitalSignXYData.count;
    self.view.backgroundColor = [UIColor whiteColor];
    
    //定義座標點的代表圖形
    CPTPlotSymbol *ellipseSymbol = [CPTPlotSymbol ellipsePlotSymbol];//圓形
    CPTPlotSymbol *starSymbol = [CPTPlotSymbol starPlotSymbol];//星形
    CPTPlotSymbol *snowSymbol = [CPTPlotSymbol snowPlotSymbol];//雪形
    CPTPlotSymbol *crossSymbol = [CPTPlotSymbol crossPlotSymbol];//“X”形
    CPTPlotSymbol *dimondSymbol = [CPTPlotSymbol diamondPlotSymbol];//菱形
    CPTPlotSymbol *hexagonSymbol = [CPTPlotSymbol hexagonPlotSymbol];//六角形
    CPTPlotSymbol *pentagonSymbol = [CPTPlotSymbol pentagonPlotSymbol];//五角形
    CPTPlotSymbol *plusSymbol = [CPTPlotSymbol plusPlotSymbol];//“＋”形
    CPTPlotSymbol *rectangleSymbol = [CPTPlotSymbol rectanglePlotSymbol];//四方形
    CPTPlotSymbol *triangleSymbol = [CPTPlotSymbol trianglePlotSymbol];//三角形
    
    //draw
    [self drawVitalSignTopValue:42 BottomValue:35 DataSourceArray:dataArray lineColorRed:1 lineColorGreen:0 lineColorBlue:0 lineSymbol:pentagonSymbol identify:@"id1"];
    [self drawVitalSignTopValue:140 BottomValue:0 DataSourceArray:dataArray2 lineColorRed:0 lineColorGreen:1 lineColorBlue:0 lineSymbol:plusSymbol identify:@"id2"];
    [self drawVitalSignTopValue:56 BottomValue:0 DataSourceArray:dataArray3 lineColorRed:0 lineColorGreen:0 lineColorBlue:1 lineSymbol:rectangleSymbol identify:@"id3"];
    [self drawVitalSignTopValue:6 BottomValue:-8 DataSourceArray:dataArray4 lineColorRed:.9 lineColorGreen:.5 lineColorBlue:0 lineSymbol:triangleSymbol identify:@"id4"];
}

//询问有多少个数据，在 CPTPlotDataSource 中声明的
- (NSUInteger) numberOfRecordsForPlot:(CPTPlot *)plot {
    return 6;
}

- (NSNumber *) numberForPlot:(CPTPlot *)plot field:(NSUInteger)fieldEnum recordIndex:(NSUInteger)index {
    NSLog(@"putXY");
    NSEnumerator *enumeratorKey = [self.dictVitalSignXYData keyEnumerator];
    NSNumber *num = nil;
    for (NSString *keyLineId in enumeratorKey) {
        NSArray *valueArray = [self.dictVitalSignXYData objectForKey:keyLineId];
        //NSLog(@"plot.identifier %@, self.lineId %@",plot.identifier, keyLineId);
        switch ( fieldEnum ) {
            case CPTScatterPlotFieldX:
                
                
                
                //num = [NSNumber numberWithUnsignedInteger:index];
                num = [NSNumber numberWithUnsignedInteger:index * oneDay];
                
                
                
                
                break;
            case CPTScatterPlotFieldY:
                if ( [(NSString *)plot.identifier isEqualToString:keyLineId] ) {
                    num = [valueArray objectAtIndex:index];
                }
                break;
        }
    }
    return num;
}

-(CPTLayer *)dataLabelForPlot:(CPTPlot *)plot recordIndex:(NSUInteger)idx{
    NSEnumerator *enumeratorKey = [self.dictVitalSignXYData keyEnumerator];
    CPTTextLayer *label;
    for (NSString *keyLineId in enumeratorKey)
    {
        if ( [(NSString *)plot.identifier isEqualToString:keyLineId] ) {
            NSArray *dataArray = [self.dictVitalSignXYData objectForKey:keyLineId];
            label = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"%@",[dataArray objectAtIndex:idx]]];
            CPTMutableTextStyle *textStyle = [label.textStyle mutableCopy];
            textStyle.fontSize = 7;
            textStyle.color = [CPTColor lightGrayColor];
            label.textStyle = textStyle;
            break;
        }
    }
    return label;
}

-(BOOL)plotSpace:(CPTXYPlotSpace *)space shouldHandlePointingDeviceUpEvent:(id)event atPoint:(CGPoint)point{
    NSLog(@"UpEvent x=%lf, y=%lf",point.x,point.y);
    [xyGraph removeAnnotation:annotation];
    [xyGraph removePlot:linePlot];
    return YES;
}

-(BOOL)plotSpace:(CPTXYPlotSpace *)space shouldHandlePointingDeviceCancelledEvent:(id)event{
    //NSLog(@"CancelledEvent x=%lf, y=%lf",point.x,point.y);
    return YES;
}

-(BOOL)plotSpace:(CPTXYPlotSpace *)space shouldHandlePointingDeviceDraggedEvent:(id)event atPoint:(CGPoint)point{
    NSLog(@"DraggedEvent x=%lf, y=%lf",point.x,point.y);
    return YES;
}

-(BOOL)plotSpace:(CPTPlotSpace *)space shouldHandlePointingDeviceDownEvent:(id)event atPoint:(CGPoint)point

{
    NSLog(@"touchDown");
    NSDecimal ppdecimal[2];
    CGPoint ptAtPlotArea =
    CGPointMake(point.x - (xyGraph.plotAreaFrame.frame.origin.x
                           + xyGraph.plotAreaFrame.plotArea.frame.origin.x),
                point.y - (xyGraph.plotAreaFrame.frame.origin.y
                           + xyGraph.plotAreaFrame.plotArea.frame.origin.y));
    
    [plotSpace plotPoint:ppdecimal numberOfCoordinates:2 forPlotAreaViewPoint:ptAtPlotArea];
    NSDecimal xxxx = ppdecimal[0];
    NSDecimal yyyy = ppdecimal[1];
    NSDecimalNumber *xDecimalNum = [NSDecimalNumber decimalNumberWithDecimal:xxxx];
    NSDecimalNumber *yDecimalNum = [NSDecimalNumber decimalNumberWithDecimal:yyyy];
    double xDouble = [xDecimalNum doubleValue];
    xDouble = xDouble/oneDay + 0.5;
    NSInteger intX = (int) xDouble;
    NSInteger intY = [yDecimalNum intValue];
    NSLog(@"the place clicek is (%i,%i)", intX,
          intY);
    
    //取出array
    NSEnumerator *enumeratorKey = [self.dictVitalSignXYData keyEnumerator];
    CPTTextLayer *tagLayer;
    NSString *tagString = @"";
    for (NSString *keyLineId in enumeratorKey)
    {
        NSArray *dataArray = [self.dictVitalSignXYData objectForKey:keyLineId];
        
        
        
        
        //NSObject *yContent = [dataArray objectAtIndex:intX];
        NSObject *yContent = [dataArray objectAtIndex:intX];
        NSLog(@"intX=%ld",(long)intX);
        
        
        
        
        
        tagString = [NSString stringWithFormat:@"%@\r%@: %@", tagString, keyLineId, yContent];//\r是換行符號
    }
    
    
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor blackColor];
    textStyle.fontSize = 7;
    tagLayer = [[CPTTextLayer alloc] initWithText:[NSString stringWithFormat:@"x=%ld%@", (long)intX, tagString]style:textStyle];
    annotation = [CPTPlotSpaceAnnotation alloc];
    
    annotation.contentLayer = tagLayer;
    annotation.contentLayer.backgroundColor =[UIColor redColor].CGColor;
    annotation.contentLayer.position = CGPointMake(self.view.frame.size.width-tagLayer.frame.size.width, point.y);
    //annotation.contentLayer.position = CGPointMake(point.x, point.y);
    [xyGraph addAnnotation:annotation];
//    xyGraph.backgroundColor = [UIColor yellowColor].CGColor;
//    scatterPlot.backgroundColor = [UIColor whiteColor].CGColor;
    
    //add line
    //CGRect lineFrame = CGRectMake(point.x, xyGraph.frame.origin.y, 1, xyGraph.frame.size.height);
    CGRect lineFrame = CGRectMake(0,0,0,0);
    linePlot = [[CPTScatterPlot alloc] initWithFrame:lineFrame];
    CALayer *line = [CALayer layer];
    float xUnitCount = vitalLineCount * 1.2 + 6.5;
    float xUnitLength = scatterPlot.frame.size.width / xUnitCount;
    //原點位置
    double xStart = scatterPlot.frame.origin.x - self.view.frame.origin.x + vitalLineCount * 1.2 * xUnitLength + xUnitLength * intX;
    
    float yUnitCount = 19;
    float yUnitLength = scatterPlot.frame.size.height/ yUnitCount;
    

    
    line.frame = CGRectMake(xStart, scatterPlot.frame.origin.y + yUnitLength * 10, 1, yUnitLength * 7);
    line.backgroundColor = [UIColor grayColor].CGColor;
    [linePlot addSublayer:line];
    //linePlot.backgroundColor = [UIColor grayColor].CGColor;
    [xyGraph addPlot:linePlot];
    return YES;
    
}

//用於直接產生VitalSign圖表
-(void)drawVitalSignTopValue:(float)topValue BottomValue:(float)botValue DataSourceArray:(NSMutableArray *)dataArray lineColorRed:(float)r lineColorGreen:(float)g lineColorBlue:(float)b lineSymbol:(CPTPlotSymbol *)plotSymbol identify:(NSString *)identify{
    NSDateComponents *dateComponents = [[NSDateComponents alloc] init];
    
    [dateComponents setMonth:10];
    [dateComponents setDay:10];
    [dateComponents setYear:2014];
//    [dateComponents setHour:12];
//    [dateComponents setMinute:0];
//    [dateComponents setSecond:0];
    
    NSCalendar *gregorian = [[NSCalendar alloc]
                             initWithCalendarIdentifier:NSCalendarIdentifierGregorian];
    refDate = [gregorian dateFromComponents:dateComponents];
    oneDay = 24 * 60 * 60;
    
    
    
    NSLog(@"draw1");
    //線格式設定：讓plot/xy軸用
    CPTMutableLineStyle *lineStyle = [CPTMutableLineStyle lineStyle];
    lineStyle.lineColor = [CPTColor colorWithComponentRed:r green:g blue:b alpha:1];
    //符號格式設定：讓plot用
    //CPTPlotSymbol *plotSymbol = [CPTPlotSymbol ellipsePlotSymbol];
    plotSymbol.fill = [CPTFill fillWithColor:[CPTColor colorWithComponentRed:r green:g blue:b alpha:1]];
    //符號是圓形
    plotSymbol.size = CGSizeMake(4.0, 4.0);
    plotSymbol.lineStyle = lineStyle;
    //字型設定：包含顯示字體大小、字體等
    CPTMutableTextStyle *textStyle = [CPTMutableTextStyle textStyle];
    textStyle.color = [CPTColor blackColor];
    textStyle.fontSize = 7;
    
    //建造hostView(用來裝xy圖的，是corePlot的class)
    //frame 告訴大家這個hostView多大
    CGRect hostFrame = CGRectMake(0,30, self.view.frame.size.width,100);
    CPTGraphHostingView *hostView = [[CPTGraphHostingView alloc] initWithFrame:hostFrame];
    
    //定義xy圖xyGraph
    xyGraph = [[CPTXYGraph alloc] initWithFrame:hostView.frame];
    //定義xyGraph與hostView之間的留白
    xyGraph.paddingLeft = 0;
    xyGraph.paddingTop = 0;
    xyGraph.paddingRight = 0;
    xyGraph.paddingBottom = 0;
    //[[xyGraph defaultPlotSpace] setAllowsUserInteraction:TRUE];
    //將此hostView疊到self.view上
    [self.view addSubview:hostView];
    //將xyGraph疊到hostView之中
    hostView.hostedGraph = xyGraph;
    
    //在xyGraph畫折線圖
    scatterPlot = [[CPTScatterPlot alloc] initWithFrame:xyGraph.frame];
    //將scatterPlot疊於xuGraph
    scatterPlot.identifier = identify;
    NSLog(@"plot.id=%@",scatterPlot.identifier);
    [xyGraph addPlot:scatterPlot];
    scatterPlot.dataSource = self;
    
    //將plot的指定方法一開始就設計好的圖形＆線屬性
    scatterPlot.plotSymbol = plotSymbol;
    scatterPlot.dataLineStyle = lineStyle;
    
    //放入plot的資料座標
    //宣告plot會出現在graph中的座標範圍：location表示起始位置；length表長度（例如想畫-5~30則長度應該為30+5）
    plotSpace = (CPTXYPlotSpace *) scatterPlot.plotSpace;
    plotSpace.delegate = self;
    
    
    
    //設定x開始原點
    //float xStrat = -1.2 * vitalLineCount;
    float xStrat = -1.2 * oneDay * vitalLineCount;
    
    
    
    
    
    
    
    
    //plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xStrat) length:CPTDecimalFromFloat(6.5+fabs(xStrat))];//fabs(xStart)是取xStart絕對值的意思
    plotSpace.xRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(xStrat) length:CPTDecimalFromFloat(oneDay * 6.5 + fabs(xStrat))];
    
    
    
    NSLog(@"xRange: xStart=%f, length=%f",xStrat, 6.5+fabs(xStrat));
    
    //設定區間
    float interval = (topValue - botValue)/7;
    NSLog(@"interval=%f",interval);
    
    
    
    
    //plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(botValue-interval*2) length:CPTDecimalFromFloat(topValue-botValue+interval*3)];
    plotSpace.yRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromFloat(botValue-interval*10) length:CPTDecimalFromFloat(topValue-botValue+interval*12)];
    NSLog(@"yRange: yStart=%f, length=%f",botValue-interval*2, topValue-botValue+interval*3);
    
    
    
    
    
    //設定此xyGraph的xy軸屬性：如軸的顏色、高度等
    CPTXYAxisSet *axisSet = (CPTXYAxisSet *)xyGraph.axisSet;
    //x軸屬性設定
    CPTXYAxis *x = axisSet.xAxis;
    x.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat:@"%f",botValue]);
    
    
    
    
    
    //x.majorIntervalLength = CPTDecimalFromString(@"1"); //每個刻度的距離
    x.majorIntervalLength = CPTDecimalFromFloat(oneDay);
    
    
    
    
    
    //x.minorTicksPerInterval = 1; //刻度之間的小刻度數量
    x.minorTicksPerInterval = 0; //刻度之間的小刻度數量
    
    
    
    
    
    x.minorTickLineStyle = lineStyle; //小刻度的顏色
    x.labelTextStyle = textStyle; //x軸的字體
    
    
    //////////////
    NSDateFormatter *dateFormatter = [[NSDateFormatter alloc] init];
    dateFormatter.dateStyle = kCFDateFormatterShortStyle;
    CPTTimeFormatter *timeFormatter = [[CPTTimeFormatter alloc] initWithDateFormatter:dateFormatter];
    timeFormatter.referenceDate = refDate;
    x.labelFormatter            = timeFormatter;
    x.labelRotation             = M_PI_4;
    //////////////
    
    
    //x軸可見範圍：location是可見起始點；length是可見長度
    //x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0) length:CPTDecimalFromInteger(6)];
    x.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(0)
                                                  length:CPTDecimalFromInteger(6 * oneDay)];
    
    
    
    
    //y軸屬性設定
    CPTXYAxis *y = axisSet.yAxis;
    
    
    //float yStart=-1.2 * linePosition;
    float yStart= -1.2 * oneDay * linePosition;

    
    
    NSLog(@"yStart2=%f",yStart);
    y.orthogonalCoordinateDecimal = CPTDecimalFromString([NSString stringWithFormat: @"%f",yStart]); //y軸原點:指在x＝？的時候開始畫y軸
    y.majorIntervalLength = CPTDecimalFromString([NSString stringWithFormat: @"%f",interval]); //每個刻度的距離
    y.minorTicksPerInterval = 1; //刻度之間的小刻度數量
    y.minorTickLineStyle = lineStyle; //小刻度的顏色
    y.labelTextStyle = textStyle; //y軸的字體
    //y軸可見範圍：location是可見起始點；length是可見長度
    y.visibleRange = [CPTPlotRange plotRangeWithLocation:CPTDecimalFromInteger(botValue)
                                                length:CPTDecimalFromInteger(topValue-botValue)];
    y.axisLineStyle = lineStyle; //y軸顏色粗細等
    linePosition +=1;
}

//讓key=id value=array放入dictionary
- (void)BuildDataDictLineId:(NSString *)key DataArray:(NSMutableArray *)value{
    [self.dictVitalSignXYData setValue:value forKey:key] ;
}


//取得資料的連線方式設定
-(void)Conn{
    NSURL *url = [NSURL URLWithString:
                  @""];
    NSMutableURLRequest *urlRequest = [NSMutableURLRequest requestWithURL:url];
    NSURLConnection *conn = [[NSURLConnection alloc] initWithRequest:urlRequest delegate:self startImmediately:YES];
    if (conn) {
        webData = [NSMutableData data];
        NSLog(@"Conn");
    }
}

- (void)connection:(NSURLConnection *)connection didReceiveData:(NSData *)data{
    [webData appendData:data];
    NSLog(@"didReceiveData");
    NSString *responseString = [[NSString alloc] initWithData:webData encoding:NSUTF8StringEncoding];
    NSLog(@"viewDidAppear:ConnData=%@",responseString);
}

@end
