//
//  GameViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 14/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "DataSource.h"


//Private functions

@interface GameViewController()

- (void)createToolbarItems;
- (void)createFrames;

@end

@implementation GameViewController

@synthesize toolbar,caroOnline;
@synthesize roomName;

/** Init to play at a room with name
 *	Note: game to play determine by room name;
 */
- (id)initWithRoomName:(NSString*)room{
	NSLog(@"Init Room %@ ",room);
    roomName=room;
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		self.view.frame =[[UIScreen mainScreen] bounds];
		self.title=room;
		
    }
    return self;
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

/*
// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
}
*/


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	NSLog(@"Load subview in Main View Controller!");

	//Test GUI
	UIImage* boardImage=[DataSource imageFromPath:@"/Users/TVA/Desktop/Board20x20.png"];
	UIImage* imageX=[DataSource imageFromPath:@"/Users/TVA/Desktop/X_Black.png"];
	UIImage* imageO=[DataSource imageFromPath:@"/Users/TVA/Desktop/O_White.png"];
	
	//	CaroOfflineViewController * caroTest = [[CaroOfflineViewController alloc]initWithCaroBoard:boardImage imageX:imageX imageO:imageO];
	//	[self.view addSubview:caroTest.board];
	//	[self addChildViewController:caroTest];
	
	caroOnline = [[CaroOnlineViewController alloc]initWithCaroBoard:boardImage imageX:imageX imageO:imageO roomName:self.roomName];
	[self.view addSubview:caroOnline.board];
	[self addChildViewController:caroOnline];
	
	NSLog(@"Caro board loaded");
	
	// create the UIToolbar at the bottom of the view controller
	toolbar = [[UIToolbar alloc]init];
	//toolbar.barStyle = UIBarStyleBlackOpaque;
	toolbar.barStyle = UIBarStyleDefault;
	//create buttons of toolbar
	[self createToolbarItems];
	[self.view addSubview:toolbar];
	 
	[self createFrames];
	//there is a toolbar frame bug but after rotate it is fixed! This line can fix the bug without rotate
	toolbar.frame = CGRectMake(toolbar.frame.origin.x,toolbar.frame.origin.y-44,toolbar.frame.size.width,toolbar.frame.size.height);
	
	NSLog(@"Toolbar loaded!");
	
	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.toolbar release];
	self.toolbar = nil;
	[self.caroOnline release];
	self.caroOnline = nil;
	NSLog(@"Game Room release!");
}

-(void) viewDidAppear:(BOOL)animated{
	NSLog(@"GameviewDidAppear!");
	[super viewDidAppear:animated];
	caroOnline.pause=false;
}
-(void) viewWillDisappear:(BOOL)animated{
	NSLog(@"GameviewWillDisappear!");
	[super viewWillDisappear:animated];
	caroOnline.pause=true;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
}

- (void)willAnimateRotationToInterfaceOrientation:(UIInterfaceOrientation)toInterfaceOrientation duration:(NSTimeInterval)duration{
	//Fix frame of subviews for current screen
	[self createFrames];
}

//******************************** UI quick made *********************
- (void)createFrames{
	NSLog(@"Fix toolbar & table view frame for current screen!");
	// size up the toolbar and set its frame to fit current screen
	[toolbar sizeToFit];
	CGRect mainViewBounds = self.view.bounds;
	//NSLog(@"%f x %f , %f x %f",mainViewBounds.origin.x,mainViewBounds.origin.y,mainViewBounds.size.width,mainViewBounds.size.height);
	//NSLog(@"%f x %f , %f x %f",toolbar.frame.origin.x,toolbar.frame.origin.y,toolbar.frame.size.width,toolbar.frame.size.height);
	
	[toolbar setFrame:CGRectMake(mainViewBounds.origin.x,
								 mainViewBounds.origin.y + mainViewBounds.size.height - toolbar.frame.size.height,
								 toolbar.frame.size.width,
								 toolbar.frame.size.height)];
	
}

- (void)createToolbarItems{	
	NSLog(@"Create items in Toolbar!");
	// match each of the toolbar item's style match the selection in the "UIBarButtonItemStyle" segmented control
	UIBarButtonItemStyle style = UIBarButtonItemStylePlain;
	
	// flex item used to separate the left groups items and right grouped items
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	// create a special tab bar item with a custom image and title
	UIBarButtonItem *imageItem = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"back.png"]
																  style:style
																 target:self
																 action:@selector(quitGame:)];
	
	UIBarButtonItem *imageItem2 = [[UIBarButtonItem alloc] initWithImage:[UIImage imageNamed:@"chat.png"]
																   style:style
																  target:self
																  action:@selector(toggleChat:)];
	
	
	NSArray *items = [NSArray arrayWithObjects: imageItem, flexItem, imageItem2, nil];
	[self.toolbar setItems:items animated:NO];
	
	[flexItem release];
	[imageItem release];
	[imageItem2 release];
}

//******************************** UI handle *********************
-(void) goBack:(id)sender{
	
}

@end
