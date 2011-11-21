//
//  GameViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 14/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "GameViewController.h"
#import "DataSource.h"
#import "ImageProcessor.h"

//Private functions

@interface GameViewController()

- (void)createToolbarItems;
- (void)createFrames;
-(void) changeImageIconToPlayer:(int)p;

@end

@implementation GameViewController

@synthesize toolbar,roomName,chatView,sendingIndicator;

static float chatViewHeightScale=0.66f;
static int rangeRandom=10;

/** Init to play at a room with name
 *	Note: game to play determine by room name;
 */
- (id)initWithRoomName:(NSString*)room{
	NSLog(@"Init Room %@ ",room);
    roomName=room;
	self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		
		self.title=room;

    }
	
    return self;
}

/** Reload to play a new  caro game
 *	@param room=name of room to load Request from.
 */
- (void)reloadWithRoomName:(NSString*)room{
	self.title=room;
	[caroOnline reloadWithRoomName:room];
	if (![room isEqualToString:roomName]) {
		roomName=room;
		[chatView clearMessages];
		[chatView.view removeFromSuperview];
		[chatView reloadMessagesTable];
	}
	
}

- (void)didReceiveMemoryWarning
{
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

#pragma mark - View lifecycle

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
	CGRect mainViewBounds = self.view.frame;
	NSLog(@"%f x %f , %f x %f",mainViewBounds.origin.x,mainViewBounds.origin.y,mainViewBounds.size.width,mainViewBounds.size.height);

	//Load view here
	NSLog(@"Load subview in Game View Controller!");
	
	//Load image
	UIImage* boardImage=[DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"Board20x20" ofType:@"png"]];
	UIImage* imageX=[DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"black-copy" ofType:@"png"]];
	UIImage* imageO=[DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"white-copy" ofType:@"png"]];
	
	//Load caro online
	caroOnline = [[CaroOnlineViewController alloc]initWithCaroBoard:boardImage imageX:imageX imageO:imageO roomName:roomName];
	//set default player
	caroOnline.player=1;
	[self.view addSubview:caroOnline.view];
	[self addChildViewController:caroOnline];

	[boardImage release];
	[imageX release];
	[imageO release];
	NSLog(@"Caro game online loaded");
	
	//Load image for toolbar Button
	imageXicon = [DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"black-copy 20x20" ofType:@"png"]];
	imageOicon = [DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"white-copy 20x20" ofType:@"png"]];
	
	// create the UIToolbar at the bottom of the view controller
	toolbar = [[UIToolbar alloc]init];
	//toolbar.barStyle = UIBarStyleBlackOpaque;
	
	//create buttons of toolbar
	[self createToolbarItems];
	[self.view addSubview:toolbar];
	
	chatView = [[ChatViewController alloc]initWithRoom:roomName delegate:self];
	caroOnline.chatView=chatView;
	//[self.view addSubview:chatView.view];
	
	NSLog(@"ChatView loaded!");
	
	[self createFrames];
	//there is a toolbar frame bug but after rotate it is fixed! This line can fix the bug without rotate
	toolbar.frame = CGRectMake(toolbar.frame.origin.x,toolbar.frame.origin.y-44-20,toolbar.frame.size.width,toolbar.frame.size.height);
	
	NSLog(@"Toolbar loaded!");
	
	//Create Indicator at the right of NavigationBar
	sendingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[sendingIndicator startAnimating];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:sendingIndicator];
}



//// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//		
//
//}

-(void) dealloc{
	//deallocating here
	[imageXicon release];
	imageXicon=nil;
	[imageOicon release];
	imageOicon=nil;
	[switchSideButton release];
	switchSideButton=nil;
	[roomName release];
	roomName=nil;
	[caroOnline release];
	caroOnline = nil;
	
	[toolbar release];
	toolbar=nil;
	
	[chatView release];
	chatView=nil;
	
	[super dealloc];
	NSLog(@"GameView dealloc!");	
}


- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	
	NSLog(@"GameView unload!");
}

-(void) viewDidAppear:(BOOL)animated{
	
	[super viewDidAppear:animated];
	NSLog(@"GameviewDidAppear!");
}
-(void) viewWillDisappear:(BOOL)animated{
	
	[super viewWillDisappear:animated];
	NSLog(@"GameviewWillDisappear!");
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
	[chatView createFrames];
	[chatView.view setFrame:CGRectMake(mainViewBounds.size.width-chatView.view.frame.size.width, 0,chatView.view.frame.size.width,chatView.view.frame.size.height*chatViewHeightScale*480/mainViewBounds.size.height)];
	
	
}

- (void)createToolbarItems{	
	NSLog(@"Create items in Toolbar!");
	// match each of the toolbar item's style match the selection in the "UIBarButtonItemStyle" segmented control
	//UIBarButtonItemStyle style = UIBarButtonItemStylePlain;
	
	// flex item used to separate the left groups items and right grouped items
	UIBarButtonItem *flexItem = [[UIBarButtonItem alloc] initWithBarButtonSystemItem:UIBarButtonSystemItemFlexibleSpace
																			  target:nil
																			  action:nil];
	
	// create a special tab bar item with a custom image and title
	
	//Setting button
	UIImage* image=[UIImage imageNamed:@"setting.png"] ;
	UIButton *button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(goToSetting:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemSetting = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	//NewTable button
	image=[UIImage imageNamed:@"gomoku_icon+.png"] ;
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(newGame:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemNewGame = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	//NewTable button
	image=[UIImage imageNamed:@"refresh.png"] ;
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(refreshGame:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemRefresh = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	//Chat button
	UIImage* imageChat=[UIImage imageNamed:@"chat.png"] ;
	UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
	chatButton.bounds = CGRectMake( 0, 0, imageChat.size.width, imageChat.size.height );    
	[chatButton setImage:imageChat forState:UIControlStateNormal];
	[chatButton addTarget:self action:@selector(toggleChat:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemChat = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
	
	
	
	switchSideButton = [UIButton buttonWithType:UIButtonTypeCustom];
	switchSideButton.bounds = CGRectMake( 0, 0, imageOicon.size.width, imageOicon.size.height );    
	[switchSideButton setImage:imageOicon forState:UIControlStateNormal];
	[switchSideButton addTarget:self action:@selector(changePlayer:) forControlEvents:UIControlEventTouchUpInside]; 
	
	[self changeImageIconToPlayer:caroOnline.player];
	
	UIBarButtonItem *imageItemSwitchSide = [[UIBarButtonItem alloc] initWithCustomView:switchSideButton];
	
	
	NSArray *items = [NSArray arrayWithObjects: imageItemSetting, imageItemNewGame, flexItem, imageItemRefresh, imageItemSwitchSide, imageItemChat, nil];
	[toolbar setItems:items animated:NO];
	
	[flexItem release];
	[imageItemSetting release];
	[imageItemChat release];
	[imageItemSwitchSide release];
	[imageItemNewGame release];
	[imageItemRefresh release];
}

-(void) changeImageIconToPlayer:(int)p{
	if (p == 1)[switchSideButton setImage:imageXicon forState:UIControlStateNormal];
	else if (p == 2)[switchSideButton setImage:imageOicon forState:UIControlStateNormal];
}
//******************************** UI handle *********************
-(void) goToSetting:(id)sender{
	NSLog(@"Go To Setting!");
	
}

-(void) newGame:(id)sender{
	NSLog(@"Create a new table!");
	NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
	NSString* chatName=[standardUserDefaults objectForKey:@"chatName"];
	Entry * newTable = [[Entry alloc]init];
	//Need more code here
	//Catch ID in roomName
	NSError * error=nil;
	NSString * pattern=@"_(.+?)\\z";
	NSRegularExpression * regex = [NSRegularExpression regularExpressionWithPattern:pattern options:NSRegularExpressionCaseInsensitive error:&error];
	NSTextCheckingResult * match =[regex firstMatchInString:roomName options:0 range:NSMakeRange(0, [roomName length])];
	NSString * prevID=@"1";
	if(match)prevID= [roomName substringWithRange:[match rangeAtIndex:1]];
	int ID=[prevID intValue]+1+rand()%rangeRandom;
	
	newTable.text=[NSString stringWithFormat:@"<tag=NewGame><type=Caro><roomName=%@><roomID=%d>",chatName,ID];
	[[ICTchatConnection alloc] initToSendEntry:newTable toRoom:roomName delegate:nil];
	//Go to room imediately
	[self reloadWithRoomName:[NSString stringWithFormat:@"(Caro)%@_%d",chatName,ID]];
	
}

-(void) refreshGame:(id)sender{
	NSLog(@"Refresh game to get player!");
	
}

-(void) changePlayer:(id)sender{
	caroOnline.player++;
	if(caroOnline.player>2)caroOnline.player=1;
	[self changeImageIconToPlayer:caroOnline.player];
	NSLog(@"Player change to %d",caroOnline.player);
}
-(void) toggleChat:(id)sender{
	NSLog(@"Toggled chat!");
	if (chatView.view.superview) {
		[chatView.view removeFromSuperview];
	}else{
		[self.view addSubview:chatView.view];
	}
	
}

//********************* Chat Delegate ***************************
- (void)submitMessage:(NSString*)message{
	NSLog(@"User has submit a message %@",message);
	Entry * messageEntry = [[Entry alloc] init];
	messageEntry.text=[NSString stringWithFormat:@"<tag=Chat><name=%@>%@",chatView.chatName,message];
	//Init request with entry
	[[ICTchatConnection alloc] initToSendEntry:messageEntry toRoom:roomName delegate:caroOnline];
	[messageEntry release];
}


@end
