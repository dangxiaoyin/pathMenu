//
//  ZYPathMenuViewController.m
//  ZYPathMenu
//
//  Created by wxg on 13-7-17.
//  Copyright 2013 __MyCompanyName__. All rights reserved.
//

#import "ZYPathMenuViewController.h"

@implementation ZYPathMenuViewController

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
    
    // path  是国外的一个社交软件
    
    
    //设置菜单的背景图片 黑色背景
    UIImage *storyMenuItemImage = [UIImage imageNamed:@"bg-menuitem.png"];
    //设置菜单的高亮背景图片
    UIImage *storyMenuItemImagePressed = [UIImage imageNamed:@"bg-menuitem-highlighted.png"];
    //设置内容图片  星星
    UIImage *starImage = [UIImage imageNamed:@"icon-star.png"];
    
    //创建六个菜单  右边黑色白星星
    QuadCurveMenuItem *starMenuItem1 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed  ContentImage:starImage  highlightedContentImage:nil];
    
    QuadCurveMenuItem *starMenuItem2 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:starImage highlightedContentImage:nil];
    
    QuadCurveMenuItem *starMenuItem3 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:starImage highlightedContentImage:nil];
    
    QuadCurveMenuItem *starMenuItem4 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:starImage highlightedContentImage:nil];
    
    QuadCurveMenuItem *starMenuItem5 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:starImage highlightedContentImage:nil];
    
    QuadCurveMenuItem *starMenuItem6 = [[QuadCurveMenuItem alloc] initWithImage:storyMenuItemImage highlightedImage:storyMenuItemImagePressed ContentImage:starImage highlightedContentImage:nil];
	
    
    NSArray *menus = [NSArray arrayWithObjects:starMenuItem1, starMenuItem2, starMenuItem3, starMenuItem4, starMenuItem5, starMenuItem6, nil];
    [starMenuItem1 release];
    [starMenuItem2 release];
    [starMenuItem3 release];
    [starMenuItem4 release];
    [starMenuItem5 release];
    [starMenuItem6 release];
    
    QuadCurveMenu *menu = [[QuadCurveMenu alloc] initWithFrame:CGRectMake(10, 10, 50, 50) menus:menus];
    menu.delegate = self;
	//menu.clipsToBounds = YES;
    menu.backgroundColor = [UIColor clearColor];
    [self.view addSubview:menu];
    [menu release];
	
}

#pragma mark -

- (void)quadCurveMenu:(QuadCurveMenu *)menu didSelectIndex:(NSInteger)idx
{
    NSLog(@"Select the index : %d",idx);
}


- (void)didReceiveMemoryWarning {
	// Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
	
	// Release any cached data, images, etc that aren't in use.
}

- (void)viewDidUnload {
	// Release any retained subviews of the main view.
	// e.g. self.myOutlet = nil;
}


- (void)dealloc {
    [super dealloc];
}

@end
