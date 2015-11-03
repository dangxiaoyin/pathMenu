//
//  QuadCurveMenu.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenu.h"
#import <QuartzCore/QuartzCore.h>

//最近点的半径
#define NEARRADIUS 100.0f
//最终点的半径
#define ENDRADIUS 120.0f
//最远点的半径
#define FARRADIUS 150.0f

//加号按钮的坐标
#define STARTPOINT CGPointMake(100, 200)
//刷新的时间
#define TIMEOFFSET 0.026f
//按钮平均分布在多大的角度范围内
#define MENUWHOLEANGLE  M_PI_2

@interface QuadCurveMenu ()
- (void)_expand;
- (void)_close;
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p;
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p;
@end

@implementation QuadCurveMenu
@synthesize expanding = _expanding;
@synthesize delegate = _delegate;
@synthesize menusArray = _menusArray;

#pragma mark - initialization & cleaning up
- (id)initWithFrame:(CGRect)frame menus:(NSArray *)aMenusArray
{
    self = [super initWithFrame:frame];
    if (self) 
    {
        self.backgroundColor = [UIColor clearColor];
        
        //下面重写了setMenusArray方法，布局传过来的菜单项
        // layout menus
        self.menusArray = aMenusArray;
        //[self setMenusArray:aMenusArray];

        //创建加号按钮
        // add the "Add" Button.
        _addButton = [[QuadCurveMenuItem alloc] 
        initWithImage:[UIImage imageNamed:@"bg-addbutton.png"]
        highlightedImage:[UIImage imageNamed:@"bg-addbutton-highlighted.png"] 
        ContentImage:[UIImage imageNamed:@"icon-plus.png"] 
        highlightedContentImage:[UIImage imageNamed:@"icon-plus-highlighted.png"]];
        
        _addButton.delegate = self;
        _addButton.center = STARTPOINT;
        [self addSubview:_addButton];
        
     }
    return self;
}

- (void)dealloc
{
    [_addButton release];
    [_menusArray release];
    [super dealloc];
}


//这个方法作用是，判断当前view是否应该接收触摸事件，默认的实现是触摸点在view的范围内才接收事件，                               
#pragma mark - UIView's methods

//默认行为
//- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
//{
//    return CGRectContainsPoint(self.bounds, point);
//}
- (BOOL)pointInside:(CGPoint)point withEvent:(UIEvent *)event
{
NSLog(@"pointInsidepointInsidepointInsidepointInside  %@",NSStringFromCGPoint(point));
    
    //如果按钮的状态是展开状态，不管触摸点在不在自己的范围内，都接收事件，否则只有点到加号按钮，才
    //接收事件
    // if the menu state is expanding, everywhere can be touch
    // otherwise, only the add button are can be touch
    if (_expanding == YES )
    {
        return YES;
    }
    else
    {
        return CGRectContainsPoint(_addButton.frame, point);
    }
    //父类的默认实现
    //return CGRectContainsPoint(self.bounds, point);
    
}

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
    NSLog(@"touchesBegantouchesBegan");
    //触摸开始的时候，更改菜单的展开状态（展开或者关闭），下面重写了setExpanding方法
    self.expanding = !self.isExpanding;
    //[self setExpanding:!self.isExpanding];
}

#pragma mark - QuadCurveMenuItem delegates
//菜单项触摸开始的代理方法  touchesBegan
- (void)quadCurveMenuItemTouchesBegan:(QuadCurveMenuItem *)item
{
    //如果加号按钮被触摸了，更改菜单的展开状态（展开或者关闭）
    if (item == _addButton) 
    {
        self.expanding = !self.isExpanding;
    }
}
//  touchesEnded
- (void)quadCurveMenuItemTouchesEnd:(QuadCurveMenuItem *)item
{
    //如果是加号按钮触摸结束，不作任何处理
    // exclude the "add" button
    if (item == _addButton) 
    {
        return;
    }
    //创建菜单放大，渐隐的动画组
    // blowup the selected menu button
    CAAnimationGroup *blowup = [self _blowupAnimationAtPoint:item.center];
    
    //给层添加动画
    [item.layer addAnimation:blowup forKey:@"blowup"];
    //必须要设置菜单的中心点，因为层动画的作用不会保持，必须更改最终状态
    //动画完成后，把菜单放到加号位置，方便下次展开
    item.center = item.startPoint;
    
    //其他菜单变小，渐隐
    // shrink other menu buttons
    for (int i = 0; i < [_menusArray count]; i ++)
    {
        QuadCurveMenuItem *otherItem = [_menusArray objectAtIndex:i];
        //创建菜单变小，渐隐的动画组
        CAAnimationGroup *shrink = [self _shrinkAnimationAtPoint:otherItem.center];
        //如果是当前正在点击的按钮，不作处理，因为已经做了放大效果的动画
        if (otherItem.tag == item.tag) {
            //挑出本次循环，继续下次循环
            continue;
        }
        [otherItem.layer addAnimation:shrink forKey:@"shrink"];
        //动画完成后，把菜单放到加号位置，方便下次展开
        otherItem.center = otherItem.startPoint;
    }
    //更改是否展开的标志，设置为no(没有展开)
    _expanding = NO;
    
    // rotate "add" button
    //旋转加号按钮
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
     _addButton.transform = CGAffineTransformMakeRotation(angle);
    [UIView commitAnimations];

    //代理方法，按钮被点击
    if ([_delegate respondsToSelector:@selector(quadCurveMenu:didSelectIndex:)])
    {
        [_delegate quadCurveMenu:self didSelectIndex:item.tag - 1000];
    }
}

#pragma mark - instant methods
- (void)setMenusArray:(NSArray *)aMenusArray
{
    //默认的set方法的实现。
    if (aMenusArray != _menusArray)
    {
        [_menusArray release];
        _menusArray = [aMenusArray retain];
    }
    else
    {
        return;
    }
    
    
    //清理屏幕上的菜单按钮
    // clean subviews
    for (UIView *v in self.subviews) 
    {
        if (v.tag >= 1000) 
        {
            [v removeFromSuperview];
        }
    }
    
    
    // add the menu buttons
    int count = [_menusArray count];
    
    for (int i = 0; i < count; i ++)
    {
        //通过数组索引找到按钮
        QuadCurveMenuItem *item = [_menusArray objectAtIndex:i];
        
        item.tag = 1000 + i;
        
        //加号的位置
        item.startPoint = STARTPOINT;
        
        //通过圆的参数方程，STARTPOINT圆心的坐标 ENDRADIUS半径  MENUWHOLEANGLE / count 
        //平均到MENUWHOLEANGLE这个角度范围内，每个按钮的间隔为多少度
        //算出最终点的坐标
        CGPoint endPoint = CGPointMake(STARTPOINT.x + ENDRADIUS * cosf(i * MENUWHOLEANGLE / count), STARTPOINT.y - ENDRADIUS * sinf(i * MENUWHOLEANGLE / count));
        item.endPoint = endPoint;
        //算出最近点的坐标
        CGPoint nearPoint = CGPointMake(STARTPOINT.x + NEARRADIUS * cosf(i * MENUWHOLEANGLE / count), STARTPOINT.y - NEARRADIUS * sinf(i * MENUWHOLEANGLE / count));
        item.nearPoint = nearPoint;
        //算出最远点的坐标
        CGPoint farPoint = CGPointMake(STARTPOINT.x + FARRADIUS * cosf(i * MENUWHOLEANGLE / count), STARTPOINT.y - FARRADIUS * sinf(i * MENUWHOLEANGLE / count));
        item.farPoint = farPoint;  
        
        //起始点的坐标
        item.center = item.startPoint;
        
        item.delegate = self;
        [self addSubview:item];
        
    }
    
}
//_expanding get方法的实现
- (BOOL)isExpanding
{
    return _expanding;
}
//_expanding set方法的实现
- (void)setExpanding:(BOOL)expanding
{
    _expanding = expanding;    
    
    //旋转加号按钮
    // rotate add button
    float angle = self.isExpanding ? -M_PI_4 : 0.0f;
    
    [UIView beginAnimations:nil context:nil];
    [UIView setAnimationDuration:0.2];
    _addButton.transform = CGAffineTransformMakeRotation(angle);
    [UIView commitAnimations];

    
    //如果没有定时器，创建定时器
    // expand or close animation
    if (!_timer) 
    {
        //通过flag判断应该展开，还是关闭
        _flag = self.isExpanding ? 0 : ([_menusArray count] - 1);
                
        //调用定时器，展开，关闭，使用定时器的目的是使按钮依次展开，达到依次飞出来的效果
        SEL selector = self.isExpanding ? @selector(_expand) : @selector(_close);
        
        _timer = [[NSTimer scheduledTimerWithTimeInterval:TIMEOFFSET target:self selector:selector userInfo:nil repeats:YES] retain];
    }
}
//菜单展开
#pragma mark - private methods
- (void)_expand
{
    //如果_flag等于数组的个数，证明所有菜单项都已经飞出来了
    if (_flag == [_menusArray count])
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
    
    QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    //KeyPath 是对哪个属性做动画
    //初始化一个关键帧动画，绕z轴旋转
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    
    //设置每个关键帧应该执行多长时间，此数组的个数应该和values数组的个数相对应，值的范围为［0，1］
    //对此关键帧动画，效果为，开始菜单项旋转180度， 总时间0.2％的时候开始从180度转变到下一个关键点
    //0度，总时间0.5％的时候，结束从180度到0度的动画
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:0.2],
                                [NSNumber numberWithFloat:0.3], nil];
    
    
    //设置一下关键帧动画的中间的关键的几个状态值
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:M_PI],[NSNumber numberWithFloat:0.0f], nil];
    
     
    
    // 初始化一个关键帧动画，移动位置
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    
    //创建路径信息，开始点 － 最远点 － 最近点 － 结束点
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.startPoint.x, item.startPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.nearPoint.x, item.nearPoint.y); 
    CGPathAddLineToPoint(path, NULL, item.endPoint.x, item.endPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    //创建一个动画组，包含了运动和旋转
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    //设置动画事件
    animationgroup.duration = 1;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Expand"];
    //必须要设置菜单项的中心点，因为层动画的作用不会保持，必须更改最终状态
    //设置菜单项的结束点位置
    item.center = item.endPoint;
    
    //_flag++用于判断是不是所有的菜单项都已经飞出
    _flag ++;
}

//关闭动画，和展开动画类似
- (void)_close
{
    if (_flag == -1)
    {
        [_timer invalidate];
        [_timer release];
        _timer = nil;
        return;
    }
    
    int tag = 1000 + _flag;
     QuadCurveMenuItem *item = (QuadCurveMenuItem *)[self viewWithTag:tag];
    
    CAKeyframeAnimation *rotateAnimation = [CAKeyframeAnimation animationWithKeyPath:@"transform.rotation.z"];
    rotateAnimation.values = [NSArray arrayWithObjects:[NSNumber numberWithFloat:0.0f],[NSNumber numberWithFloat:M_PI * 2],[NSNumber numberWithFloat:0.0f], nil];
    //最初状态是0度，从0.0%开始做 0 － M_PI * 2的动画，0.2％的时候开始做 M_PI * 2 － 0的动画，0.5％的时候结束动画
    rotateAnimation.keyTimes = [NSArray arrayWithObjects:
                                [NSNumber numberWithFloat:.0], 
                                [NSNumber numberWithFloat:.2],
                                [NSNumber numberWithFloat:.5], nil]; 
        
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
   
    CGMutablePathRef path = CGPathCreateMutable();
    CGPathMoveToPoint(path, NULL, item.endPoint.x, item.endPoint.y);
    CGPathAddLineToPoint(path, NULL, item.farPoint.x, item.farPoint.y);
    CGPathAddLineToPoint(path, NULL, item.startPoint.x, item.startPoint.y); 
    positionAnimation.path = path;
    CGPathRelease(path);
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, rotateAnimation, nil];
    animationgroup.duration = 0.3f;
    animationgroup.timingFunction = [CAMediaTimingFunction functionWithName:kCAMediaTimingFunctionEaseIn];
    [item.layer addAnimation:animationgroup forKey:@"Close"];
    item.center = item.startPoint;
    _flag --;
}

//创建菜单项被点击时放大，渐隐的动画
- (CAAnimationGroup *)_blowupAnimationAtPoint:(CGPoint)p
{
    //更改位置动画
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    //放大动画
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(3, 3, 1)];
    
    //透明度改变动画
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    

    return animationgroup;
}

//创建菜单项被点击时，其他菜单项变小，渐隐的动画
- (CAAnimationGroup *)_shrinkAnimationAtPoint:(CGPoint)p
{
    CAKeyframeAnimation *positionAnimation = [CAKeyframeAnimation animationWithKeyPath:@"position"];
    positionAnimation.values = [NSArray arrayWithObjects:[NSValue valueWithCGPoint:p], nil];
    positionAnimation.keyTimes = [NSArray arrayWithObjects: [NSNumber numberWithFloat:.3], nil]; 
    
    CABasicAnimation *scaleAnimation = [CABasicAnimation animationWithKeyPath:@"transform"];
    scaleAnimation.toValue = [NSValue valueWithCATransform3D:CATransform3DMakeScale(.01, .01, 1)];
    
    CABasicAnimation *opacityAnimation = [CABasicAnimation animationWithKeyPath:@"opacity"];
    opacityAnimation.toValue  = [NSNumber numberWithFloat:0.0f];
    
    CAAnimationGroup *animationgroup = [CAAnimationGroup animation];
    animationgroup.animations = [NSArray arrayWithObjects:positionAnimation, scaleAnimation, opacityAnimation, nil];
    animationgroup.duration = 0.3f;
    
    
    return animationgroup;
}


@end
