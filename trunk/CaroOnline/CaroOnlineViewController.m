//
//  CaroOnlineViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CaroOnlineViewController.h"
#import "DataSource.h"
#import "GameViewController.h"

#define NumColumn 20 
#define NumRow 20 
#define NumWin 5

@implementation CaroOnlineViewController

@synthesize player,pause,roomName,chatView;

//Time step
static float timeInterval=0.1f;
//auto request each requestInterval (s), must be devide for timeInterval
static float requestInterval=5;

/** Init a view that can play a caro game on it
 *	Provide resources by Images.
 */
- (id)initWithCaroBoard:(UIImage*)BoardImage imageX:(UIImage*)imgX imageO:(UIImage*)imgO roomName:(NSString*)room
{
    self = [super initWithNibName:nil bundle:nil];
    if (self) {
        // Custom initialization
		
		
		gameControl=[[CaroGameLogic alloc]init];
		player=1;
		
		
		boardImage=[BoardImage retain];
		imageX=[imgX retain];
		imageO=[imgO retain];
		
		steps=[[NSMutableArray alloc] initWithObjects: nil];
		messages=[[NSMutableArray alloc] initWithObjects: nil];
		entryDict=[[NSMutableDictionary alloc]init];
		

		isSending=false;
		
		//Init time counter
		time=0;
		timeOfLastRequest=0;
										
		NSLog(@"ROOM=%@",room);
		roomName=room;
		newGameRoomNameAsk=nil;
		//Request to get current board of room
		[[ICTchatConnection alloc]initToGetEntriesOfRoom:roomName maximum:200 delegate:self];
		[[(GameViewController*)self.parentViewController sendingIndicator] startAnimating];
    }
    return self;
}

/** Reload to play a new  caro game
 *	@param room=name of room to load Request from.
 */
- (void)reloadWithRoomName:(NSString*)room{
	
	if(![room isEqualToString:roomName]){
		[gameControl newGame];
		[steps removeAllObjects];
		[messages removeAllObjects];
		[entryDict removeAllObjects];
		isSending=false;	
		//Init time counter
		time=0;
		timeOfLastRequest=0;
		NSLog(@"ROOM=%@",room);

		roomName=room;
		self.parentViewController.title=roomName;
		
		self.parentViewController.navigationController.title=roomName;
		
		//Recreate board view.
		[board removeFromSuperview];
		[board release];
		board=nil;
		board=[[CaroBoard alloc]initWithImage:boardImage Column:NumColumn Row:NumRow Delegate:self];
		[self.view insertSubview:board atIndex:0];
		
	}
	
	//Request to get current board of room
	[[ICTchatConnection alloc]initToGetEntriesOfRoom:roomName maximum:200 delegate:self];
	
}

-(void) dealloc{
	//deallocating here

	[boardImage release];
	boardImage=nil;
	
	[imageX release];
	imageX=nil;
	[imageO	release];
	imageO=nil;
	[steps release];
	steps=nil;
	[entryDict release];
	entryDict=nil;
	
	[gameControl release];
	gameControl=nil;
	[sendingIndicator release];
	sendingIndicator=nil;

	//NSLog(@"board retainCount=%d",[board retainCount]);
	[board release];
	//[board release];
	//[board release];
	board=nil;
	
	[super dealloc];
	NSLog(@"CaroOnlineView dealloc");	
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
	//NSLog(@"CaroOnlineView loadView!");
	self.view=[[UIView alloc]initWithFrame:[[UIScreen mainScreen] bounds]];
	board=[[CaroBoard alloc]initWithImage:boardImage Column:NumColumn Row:NumRow Delegate:self];
	[self.view addSubview:board];
	
	sendingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
	[sendingIndicator startAnimating];
}


// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
}

-(void)viewDidAppear:(BOOL)animated{
	NSLog(@"CaroOnlineViewDidAppear!");
	pause=false;
	timer=[NSTimer scheduledTimerWithTimeInterval:timeInterval
										   target:self
										 selector:@selector(updateCounter:)
										 userInfo:nil
										  repeats:YES];
}

-(void)viewWillDisappear:(BOOL)animated{
	NSLog(@"CaroOnlineViewWillDisappear!");
	pause=true;
	[timer invalidate];
	timer=nil;
}

- (void)viewDidUnload
{
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	NSLog(@"Caro Online Game Unloaded!");
	
	
	
	[super viewDidUnload];
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return NO;
}
//****************************** Alert Delegate ******************************
- (void)alertView:(UIAlertView *)alertView clickedButtonAtIndex:(NSInteger)buttonIndex {
	if (buttonIndex==1) {
		if (newGameRoomNameAsk!=nil) {
			[self reloadWithRoomName:newGameRoomNameAsk];
			newGameRoomNameAsk=nil;
		}
	}
}

//****************************** Time Event Handle ******************************

- (void)updateCounter:(NSTimer *)theTimer {
	//Count time;
	time += timeInterval;
	//Dont do anything if paused
	if (pause) {
		return;
	}
	//NSLog(@"Count time=%f",time);
	
	if (time>=timeOfLastRequest+requestInterval && !isSending) {
		//NSLog(@"Send request!");
		[[ICTchatConnection alloc] initToGetEntriesOfRoom:roomName maximum:20 delegate:self];
		timeOfLastRequest=time;
		[[(GameViewController*)self.parentViewController sendingIndicator] startAnimating];
	}
}

//****************************** CaroBoard Delegate ******************************

- (void)clickAtColumn:(int)column Row:(int)row{
	//Check if there is a sending step, user have to wait.
	if (isSending) {
		NSLog(@"There is a commiting step!");
		return;
	}
	//Check for correct move by listen response
	int response=[gameControl checkPlayer:player willMakeStepAtColumn:column Row:row];
	if (response<0) {
		NSLog(@"Say: Wrong move at %d %d",column,row);
	}else{
		
		//generate entry
		Entry* step= [[Entry alloc]init];
		NSString * tag;
		if (player==1) {
			tag=@"Xplay";
		}else tag=@"Oplay";
		
		step.text=[NSString stringWithFormat:@"<tag=%@><column=%d><row=%d><id=%d>",tag,column,row,[steps count]];
		//Init request with entry
		isSending=true;
		[[ICTchatConnection alloc] initToSendEntry:step toRoom:roomName delegate:self];
		[step release];
		
		//add sendingIndicator at column , row of caro board
		CGPoint point= [CaroBoard convertCellLocationAtColumn:column Row:row];
		

		
		[sendingIndicator setFrame:CGRectMake(point.x, point.y, [CaroBoard CellSize], [CaroBoard CellSize])];
		[board addSubview:sendingIndicator];//Not use addSubViewAtColumn:Row so we dont need to keep Column and Row value;

	}
}

//********************* ICTchatConnetion Delegate ***************************

/** Handle entries data when Connection finished loading.
 *  @param entries, NSArray of type: Entry 
 *	
 */
- (void)connection:(NSURLConnection *)connection completedWithResult:(NSArray *)entries;{
	NSLog(@"Number Entries = %d",[entries count]);
	int countMessages=[messages count];
	int countSteps=[steps count];
	for (Entry * entry in entries) {
		//Avoid duplicated
		if ([entryDict objectForKey:entry.text]!=nil) {
			continue;
		}
		//Save to entrydict 
		[entryDict setObject:@"1" forKey:entry.text];
		//Extract value from text

		NSString * tag=[DataSource firstDataWithSingleTag:@"tag" InDataString:entry.text];
		
		//*********catch tag=Xplay or Oplay (a step of player)
		if ([tag isEqualToString:@"Xplay"] || [tag isEqualToString:@"Oplay"] ) {
			//NSLog(@"New Step = %@",entry.text);
			//catch column
			int column=[[DataSource firstDataWithSingleTag:@"column" InDataString:entry.text] intValue];
			//catch row
			int row=[[DataSource firstDataWithSingleTag:@"row" InDataString:entry.text] intValue];
			
			
			int p;
			if ([tag isEqualToString:@"Xplay"]) {
				p=1;
			}else if ([tag isEqualToString:@"Oplay"]) {
				p=2;
			}
			
			
			int response=[gameControl player:p makeStepAtColumn:column Row:row];
			if (response<0) {
				NSLog(@"Request has a wrong step at %d %d",column,row);
			}else{
				//Create imageView
				UIImageView * cell;
				if(p==1) cell= [[UIImageView alloc]initWithImage:imageX];
				else cell=[[UIImageView alloc]initWithImage:imageO];
				//add cell
				[board addSubView:cell AtColumn:column Row:row];
				[cell release];
				//Add entry to steps (only valid step are keep in steps)
				[steps addObject:entry];
				
				if (isSending) {
					//end sending
					isSending=false;
					
					//Remove indicator sending
					[sendingIndicator removeFromSuperview];
				}
				
				//Checking winning
				if (response>0) {
					NSLog(@"Game end=%d",response);
					if (countSteps==0) {
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Game_End", nil)  message:NSLocalizedString(@"Find_Other_Game", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss_", nil) otherButtonTitles:nil];
						[alert show];
						[alert release];
					}else if(response==player){
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Game_End", nil)  message:NSLocalizedString(@"You_Won", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss_", nil) otherButtonTitles:nil];
						[alert show];
						[alert release];
					}else{
						UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Game_End", nil)  message:NSLocalizedString(@"You_Lost", nil) delegate:nil cancelButtonTitle:NSLocalizedString(@"Dismiss_", nil) otherButtonTitles:nil];
						[alert show];
						[alert release];
					}
					
				}
				
			}
		}
		//***********Catch Chat message
		if (chatView!=nil && [tag isEqualToString:@"Chat"]){
			NSString * name=[DataSource firstDataWithSingleTag:@"name" InDataString:entry.text];
			NSString * text=[DataSource firstNonTagDataAfterSingleTag:@"name" InDataString:entry.text];
			if(name && text)[chatView pushMessage: [NSString stringWithFormat:@"%@: %@",name,text] ];
			else if(text)[chatView pushMessage:text];
			//Add entry to messages (only valid message are keep in messages)
			[messages addObject:entry];
		}
		//**********Catch NewGame ask
		if ([tag isEqualToString:@"NewGame"]) {
			NSString * type=[DataSource firstDataWithSingleTag:@"Type" InDataString:entry.text];
			if ([type isEqualToString:@"Caro"]) {
				NSString * name=[DataSource firstDataWithSingleTag:@"roomName" InDataString:entry.text];
				NSString * ID=[DataSource firstDataWithSingleTag:@"roomID" InDataString:entry.text];
				newGameRoomNameAsk=[[NSString alloc]initWithFormat:@"(Caro)%@_%@",name,ID];
				NSLog(@"NewGameRoomNameAsk=%@",newGameRoomNameAsk);
				UIAlertView *alert = [[UIAlertView alloc] initWithTitle:NSLocalizedString(@"Notify_", nil)  
																message:NSLocalizedString(@"New_Game_Ask", nil) 
																delegate:self 
																cancelButtonTitle:NSLocalizedString(@"Dismiss_", nil) 
																otherButtonTitles:NSLocalizedString(@"OK_", nil), nil];
				
				[alert show];
				[alert release];
				
			}
		}
	
	}//End for
	
	if ([messages count]>countMessages) {
		NSLog(@"Receive %d new message:",[messages count]-countMessages);
		[chatView reloadMessagesTable];
	}
	//stop parent sendingIndicator
	[[(GameViewController*)self.parentViewController sendingIndicator] stopAnimating];
}

/** Handle error when request.
 *	
 */
-(void)connection:(NSURLConnection *)connection failedWithError:(NSError *)error{
	NSLog(@"Request to NSURLConnection has failed!");
	//Handle error here
	isSending=false;
	[[(GameViewController*)self.parentViewController sendingIndicator] stopAnimating];
}

@end
