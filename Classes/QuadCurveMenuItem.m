//
//  QuadCurveMenuItem.m
//  AwesomeMenu
//
//  Created by Levey on 11/30/11.
//  Copyright (c) 2011 lunaapp.com. All rights reserved.
//

#import "QuadCurveMenuItem.h"

//c语言方法 放大矩形，中心点不变。
CGRect ScaleRect(CGRect rect, float n)
{
    return CGRectMake((rect.size.width - rect.size.width * n)/ 2, (rect.size.height - rect.size.height * n) / 2, rect.size.width * n, rect.size.height * n);
}


@implementation QuadCurveMenuItem

@synthesize startPoint = _startPoint;
@synthesize endPoint = _endPoint;
@synthesize nearPoint = _nearPoint;
@synthesize farPoint = _farPoint;
@synthesize delegate  = _delegate;

#pragma mark - initialization & cleaning up
- (id)initWithImage:(UIImage *)img 
   highlightedImage:(UIImage *)himg
       ContentImage:(UIImage *)cimg
highlightedContentImage:(UIImage *)hcimg;
{
    if (self = [super init]) 
    {
        //img   底板图片
        //himg  底板高亮图片
        //cimg  星星图片
        //hcimg 星星高亮图片
        self.image = img;
        self.highlightedImage = himg;
        //uiimageview默认不可交互
        self.userInteractionEnabled = YES;

        //创建内容视图，用于放星星
        _contentImageView = [[UIImageView alloc] initWithImage:cimg];
        _contentImageView.highlightedImage = hcimg;
        [self addSubview:_contentImageView];
    }
    return self;
}

- (void)dealloc
{
    [_contentImageView release];
    [super dealloc];
}
#pragma mark - UIView's methods
- (void)layoutSubviews
{
    [super layoutSubviews];
    
    //根据图片的大小设置本身imageview的大小。
    self.bounds = CGRectMake(0, 0, self.image.size.width, self.image.size.height);
    
    
    NSLog(@"self.image.size.width%f",self.image.size.width);
    
    NSLog(@"self.image.size.height%f",self.image.size.height);
    
    //获得星星图片的大小
    float width = _contentImageView.image.size.width;
    float height = _contentImageView.image.size.height;
    
    //根据星星图片的大小，设置_contentImageView的大小。坐标中心点和本身的中心点重合。
    
    NSLog(@"self.bounds.size.width%f",self.bounds.size.width);
    
    NSLog(@"self.bounds.size.height%f",self.bounds.size.height);

    _contentImageView.frame = CGRectMake(self.bounds.size.width/2 - width/2, self.bounds.size.height/2 - height/2, width, height);
}

#pragma mark - 
#pragma mark Touch Methods

- (void)touchesBegan:(NSSet *)touches withEvent:(UIEvent *)event
{
   // setHighlighted 设置高亮状态，会自动显示之前设置的高亮图片。
    //self.highlightedImage = himg;
    //设置高亮，注意，本类重写了setHighlighted方法。
    self.highlighted = YES;
   // [self setHighlighted:YES];
    
    if ([_delegate respondsToSelector:@selector(quadCurveMenuItemTouchesBegan:)])
    {
       [_delegate quadCurveMenuItemTouchesBegan:self];
    }
    
}
- (void)touchesMoved:(NSSet *)touches withEvent:(UIEvent *)event
{
    
    
    // if move out of 2x rect, cancel highlighted.
    CGPoint location = [[touches anyObject] locationInView:self];
    
    //CGRectIntersectsRect(CGRect rect1, CGRect rect2) ／／ 判断两个矩形是否相交
    //CGRectContainsPoint(CGRect rect, CGPoint point) 判断点是否在矩形内。
    //如果手指移出两倍本身大小的范围，取消高亮
    if ( ! CGRectContainsPoint( ScaleRect(self.bounds, 2.0f), location ) )
    {
        //取消高亮
        self.highlighted = NO;
    }
    
}
- (void)touchesEnded:(NSSet *)touches withEvent:(UIEvent *)event
{
    //取消高亮
    self.highlighted = NO;
    // if stop in the area of 2x rect, response to the touches event.
    CGPoint location = [[touches anyObject] locationInView:self];
    
    //如果手指抬起时，还在两倍本身大小的范围内，视为有效的触摸
    if (CGRectContainsPoint(ScaleRect(self.bounds,2.0f), location))
    {
        if ([_delegate respondsToSelector:@selector(quadCurveMenuItemTouchesEnd:)])
        {
            [_delegate quadCurveMenuItemTouchesEnd:self];
        }
    }
}
//中断事件发生时，会调用此方法，（比如来电话，短信）
- (void)touchesCancelled:(NSSet *)touches withEvent:(UIEvent *)event
{
    self.highlighted = NO;
}

//重写了set方法
#pragma mark - instant methods
- (void)setHighlighted:(BOOL)highlighted
{
    //继续让父类完成设置本身图片高亮的操作。
    [super setHighlighted:highlighted];
    
    [_contentImageView setHighlighted:highlighted];
}


//get方法
//- (BOOL)highlighted
//{
//    return _highlighted;
//}


@end
