//
//  LobbyViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "LobbyViewController.h"
#import "DataSource.h"

@interface LobbyViewController()

- (void)createToolbarItems;
- (void)createFrames;
-(void) loadTables:(id)sender;

@end

@implementation LobbyViewController

@synthesize toolbar,roomPicker,chatView;

static int rangeRandom=100;

- (id)initWithLobbyName:(NSString*)lobby{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		lobbyName=@"testServer";
		self.title=NSLocalizedString(lobbyName, nil);
		
		listRoom=[[NSMutableArray alloc]initWithObjects: nil];
		listIcon=[[NSMutableArray alloc]initWithObjects: nil];
		roomEntries=[[NSMutableArray alloc]initWithObjects: nil];
		
		[self loadTables:nil];
		isSending=false;
		
		//Check for standard user setting
		//Setting for User default
		NSUserDefaults *standardUserDefaults = [NSUserDefaults standardUserDefaults];
		//Check chatName
		NSString* chatName=[standardUserDefaults objectForKey:@"chatName"];
		if (chatName) {
			NSLog(@"Chat name=%@",chatName);
		}else{
			UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Chat_Name", nil)  message:NSLocalizedString(@"No_Chat_Name_Message", nil) delegate:self cancelButtonTitle:nil otherButtonTitles:NSLocalizedString(@"Set_Chat_Name", nil),nil];
			[alert show];
			[standardUserDefaults setObject:[NSString stringWithFormat:@"User%d",rand()%10000] forKey:@"chatName"];
		}
		
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

// Implement loadView to create a view hierarchy programmatically, without using a nib.
- (void)loadView
{
	self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
	CGRect mainViewBounds = self.view.frame;
	NSLog(@"%f x %f , %f x %f",mainViewBounds.origin.x,mainViewBounds.origin.y,mainViewBounds.size.width,mainViewBounds.size.height);

	//Load view here
	NSLog(@"Load subview in Lobby View Controller!");
	
	//Create roomPicker
	roomPicker = [[PickRoomTableViewController alloc] initWithStyle:UITableViewStyleGrouped List:listRoom delegate:self];
	roomPicker.listIcon=listIcon;
	[self.view addSubview:roomPicker.view];
	[self addChildViewController:roomPicker];
	NSLog(@"RoomPicker loaded!");
	
	// create the UIToolbar at the bottom of the view controller
	toolbar = [[UIToolbar alloc]init];
	//toolbar.barStyle = UIBarStyleBlackOpaque;
	toolbar.barStyle = UIBarStyleDefault;
	//create buttons of toolbar
	[self createToolbarItems];
	[self.view addSubview:toolbar];
	NSLog(@"Toolbar loaded!");
	
	//Create chatView
	chatView = [[ChatViewController alloc]initWithRoom:[NSString stringWithFormat: @"(%@)ChatLobby",lobbyName] delegate:nil];
	[self.view addSubview:chatView.view];
	NSLog(@"ChatView loaded!");
	
	[self createFrames];
	//there is a toolbar frame bug but after rotate it is fixed! This line can fix the bug without rotate
	toolbar.frame = CGRectMake(toolbar.frame.origin.x,toolbar.frame.origin.y-44-20,toolbar.frame.size.width,toolbar.frame.size.height);
	
	//Create Indicator at the right of NavigationBar
	sendingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhite];
	[sendingIndicator startAnimating];
	self.navigationItem.rightBarButtonItem=[[UIBarButtonItem alloc]initWithCustomView:sendingIndicator];
	
	
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
//- (void)viewDidLoad
//{
//    [super viewDidLoad];
//
//}


-(void) dealloc{
	//deallocating here
	[listRoom release];
	listRoom = nil;
	[listIcon release];
	listIcon = nil;
	[roomEntries release];
	roomEntries = nil;
	[super dealloc];	
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[self.toolbar release];
	self.toolbar = nil;
	[self.roomPicker release];
	self.roomPicker = nil;
	[self.chatView release];
	self.chatView = nil;
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    return (interfaceOrientation == UIInterfaceOrientationPortrait);
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
	// size up the table and set its frame to fit current screen
	roomPicker.tableView.frame=CGRectMake(mainViewBounds.origin.x, 
										 mainViewBounds.origin.y , 
										 CGRectGetWidth(mainViewBounds), 
										 CGRectGetHeight(mainViewBounds) - CGRectGetHeight(self.toolbar.bounds) );
	//move chat view
	
	[chatView createFrames];
	[chatView.view setFrame:CGRectMake(mainViewBounds.size.width-chatView.view.frame.size.width, 0,chatView.view.frame.size.width,chatView.view.frame.size.height)];
	
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
	
	//Reload button
	image=[UIImage imageNamed:@"reload.png"] ;
	button = [UIButton buttonWithType:UIButtonTypeCustom];
	button.bounds = CGRectMake( 0, 0, image.size.width, image.size.height );    
	[button setImage:image forState:UIControlStateNormal];
	[button addTarget:self action:@selector(loadTables:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemReload = [[UIBarButtonItem alloc] initWithCustomView:button];
	
	//Chat button
	UIImage* imageChat=[UIImage imageNamed:@"chat.png"] ;
	UIButton *chatButton = [UIButton buttonWithType:UIButtonTypeCustom];
	chatButton.bounds = CGRectMake( 0, 0, imageChat.size.width, imageChat.size.height );    
	[chatButton setImage:imageChat forState:UIControlStateNormal];
	[chatButton addTarget:self action:@selector(toggleChat:) forControlEvents:UIControlEventTouchUpInside];    
	
	UIBarButtonItem *imageItemChat = [[UIBarButtonItem alloc] initWithCustomView:chatButton];
	
	
	NSArray *items = [NSArray arrayWithObjects: imageItemSetting,imageItemNewGame,  flexItem, imageItemReload, imageItemChat, nil];
	[self.toolbar setItems:items animated:YES];
	
	[flexItem release];
	[imageItemSetting release];
	[imageItemChat release];
	[imageItemReload release];
	[imageItemNewGame release];
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
	Entry * lastEntry=[roomEntries lastObject];
	NSString * prevID=[DataSource firstDataWithSingleTag:@"roomID" InDataString:lastEntry.text];
	int ID=[prevID intValue]+1+rand()%rangeRandom;
	
	newTable.text=[NSString stringWithFormat:@"<tag=NewGame><type=Caro><roomName=%@><roomID=%d>",chatName,ID];
	[[ICTchatConnection alloc] initToSendEntry:newTable toRoom:[NSString stringWithFormat: @"(%@)GameLobby",lobbyName] delegate:nil];
	//Go to room imediately
	[self pickRoomName:[NSString stringWithFormat:@"(Caro)%@_%d",chatName,ID] ];
	//Add newRoom to current listRoom
	UIImage* caroIcon=[DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"gomoku-icon" ofType:@"png"]];
	[listIcon addObject:caroIcon];
	[listRoom addObject:[NSString stringWithFormat:@"(Caro)%@_%d",chatName,ID]];
	[roomPicker.tableView reloadData];
	[roomPicker.tableView cellForRowAtIndexPath:[NSIndexPath indexPathForRow:0 inSection:0]].selected=true;
	[caroIcon release];
}

-(void) loadTables:(id)sender{
	if (!isSending) {
		NSLog(@"Load table from servers!");
		[[ICTchatConnection alloc] initToGetEntriesOfRoom:[NSString stringWithFormat: @"(%@)GameLobby",lobbyName] maximum:30 delegate:self];
		isSending=true;
		[sendingIndicator startAnimating];
	}else{
		NSLog(@"Loadding table from server!");
	}
	
}
-(void) toggleChat:(id)sender{
	NSLog(@"Toggled chat!");
	if (chatView.view.superview) {
		[chatView.view removeFromSuperview];
	}else{
		[self.view addSubview:chatView.view];
	}
	
}
//******************************** UI Delegate handle *********************
- (void)pickRoomName:(NSString*)room{
	NSLog(@"Room name=%@ has been pick up!",room);
	if(game==nil){
		game=[[GameViewController alloc] initWithRoomName:room];
		
	}else [game reloadWithRoomName:room];
	[self.navigationController pushViewController:game animated:true];
	//Hide chat
	if(chatView.view.superview)[self toggleChat:nil];
	
}
//********************* ICTchatConnetion Delegate ***************************

/** Handle entries data when Connection finished loading.
 *  @param entries, NSArray of type: Entry 
 *	
 */
- (void)connection:(NSURLConnection *)connection completedWithResult:(NSArray *)entries;{
	NSLog(@"Number Entries = %d",[entries count]);
	[listRoom removeAllObjects];
	[listIcon removeAllObjects];
	[roomEntries removeAllObjects];
	
	UIImage* caroIcon=[DataSource imageFromPath:[[NSBundle mainBundle] pathForResource:@"gomoku-icon" ofType:@"png"]];
	for (Entry * entry in entries) {
		[roomEntries addObject:entry];
		
		NSString * tag=[DataSource firstDataWithSingleTag:@"tag" InDataString:entry.text];
		if ([tag isEqualToString:@"NewGame"]) {
			NSString * type=[DataSource firstDataWithSingleTag:@"Type" InDataString:entry.text];
			if ([type isEqualToString:@"Caro"]) {
				[listIcon addObject:caroIcon];
				NSString * name=[DataSource firstDataWithSingleTag:@"roomName" InDataString:entry.text];
				NSString * ID=[DataSource firstDataWithSingleTag:@"roomID" InDataString:entry.text];
				[listRoom addObject:[NSString stringWithFormat:@"(Caro)%@_%@",name,ID]];
			}
		}
		
		
	}
	[caroIcon release];
	[roomPicker.tableView reloadData];
	
	isSending=false;
	[sendingIndicator stopAnimating];
}

/** Handle error when request.
 *	
 */
-(void)connection:(NSURLConnection *)connection failedWithError:(NSError *)error{
	NSLog(@"Request to NSURLConnection has failed!");
	//Handle error here
	isSending=false;
	[sendingIndicator stopAnimating];
}

@end
