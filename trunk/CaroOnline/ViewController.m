//
//  ViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "ViewController.h"
#import "TouchImageView.h"
#import "CaroBoard.h"
#import "DataSource.h"
#import "CaroGameLogic.h"
#import "CaroOfflineViewController.h"
#import "CaroOnlineViewController.h"
#import "GameViewController.h"

@implementation ViewController

@synthesize testGame;

- (void)didReceiveMemoryWarning
{
    [super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

- (void)viewDidLoad
{
    [super viewDidLoad];
	// Do any additional setup after loading the view, typically from a nib.
	
	testGame = [[GameViewController alloc]initWithRoomName:@"testRoomCaro105"];
//	[testGame.view setFrame:self.view.frame ];
//	[self.view addSubview:testGame.view];
//	[self addChildViewController:testGame];

	//[self.navigationController pushViewController:testGame animated:true];
	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
}

- (void)viewWillAppear:(BOOL)animated
{
    [super viewWillAppear:animated];
}

- (void)viewDidAppear:(BOOL)animated
{
    NSLog(@"viewDidAppear!");
	[super viewDidAppear:animated];
		
	[self.navigationController pushViewController:testGame animated:true];
	
}

- (void)viewWillDisappear:(BOOL)animated
{
	[super viewWillDisappear:animated];
}

- (void)viewDidDisappear:(BOOL)animated
{
	[super viewDidDisappear:animated];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
	//return (interfaceOrientation != UIInterfaceOrientationPortraitUpsideDown);
	return YES;
}

@end
