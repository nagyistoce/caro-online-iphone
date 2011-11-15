//
//  CaroOnlineViewController.m
//  CaroOnline
//
//  Created by V.Anh Tran on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import "CaroOnlineViewController.h"
#import "DataSource.h"

#define NumColumn 20 
#define NumRow 20 
#define NumWin 5

@implementation CaroOnlineViewController

@synthesize board,gameControl,player,pause;

@synthesize roomName;

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
		
		board=[[CaroBoard alloc]initWithImage:BoardImage Column:NumColumn Row:NumRow Delegate:self];
		gameControl=[[CaroGameLogic alloc]init];
		player=1;
		
		imageX=[imgX retain];
		imageO=[imgO retain];
		
		steps=[[NSMutableArray alloc] initWithObjects: nil];
		entryDict=[[NSMutableDictionary alloc]init];
		
		isSending=false;
		
		//Init time counter
		time=0;
		timeOfLastRequest=0;
		[NSTimer scheduledTimerWithTimeInterval:timeInterval
										 target:self
									   selector:@selector(updateCounter:)
									   userInfo:nil
										repeats:YES];
										
		NSLog(@"ROOM=%@",room);
		roomName=room;
		//Request to get current board of room
		[[ICTchatConnection alloc]initToGetEntriesOfRoom:roomName maximum:1000 delegate:self];
    }
    return self;
}

-(void) dealloc{
	//deallocating here
	
	[super dealloc];	
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


}



// Implement viewDidLoad to do additional setup after loading the view, typically from a nib.
- (void)viewDidLoad
{
    [super viewDidLoad];
	
	
}

-(void)viewDidAppear:(BOOL)animated{
	NSLog(@"viewDidAppear!");
	pause=false;
}

-(void)viewWillDisappear:(BOOL)animated{
	NSLog(@"viewWillDisappear!");
	pause=true;
}

- (void)viewDidUnload
{
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    // e.g. self.myOutlet = nil;
	[board release];
	board=nil;
	[gameControl release];
	gameControl=nil;
	[imageX release];
	imageX=nil;
	[imageO	release];
	imageO=nil;
	[steps release];
	steps=nil;
	[entryDict release];
	entryDict=nil;
	
	if (isSending) {
		[sendingIndicator release];
		sendingIndicator=nil;
	}
	
	NSLog(@"Caro Online Game Unloaded!");
}

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation
{
    // Return YES for supported orientations
    //return (interfaceOrientation == UIInterfaceOrientationPortrait);
	return NO;
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
		
		//add sendingIndicator at column , row of caro board
		CGPoint point= [CaroBoard convertCellLocationAtColumn:column Row:row];
		
		sendingIndicator=[[UIActivityIndicatorView alloc]initWithActivityIndicatorStyle:UIActivityIndicatorViewStyleWhiteLarge];
		[sendingIndicator startAnimating];
		
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
	
	for (Entry * currentStep in entries) {
		//Avoid duplicated
		if ([entryDict objectForKey:currentStep.text]!=nil) {
			continue;
		}
		//Save to entrydict 
		[entryDict setObject:@"1" forKey:currentStep.text];
		
		//Should filter to Steps or Chat messages here (not yet implemented)


		
		//Extract value from text
		//catch tag
		NSString * tag=[DataSource firstDataWithSingleTag:@"tag" InDataString:currentStep.text];
		
		NSLog(@"New Step = %@",currentStep.text);
		//catch column
		int column=[[DataSource firstDataWithSingleTag:@"column" InDataString:currentStep.text] intValue];
		//catch row
		int row=[[DataSource firstDataWithSingleTag:@"row" InDataString:currentStep.text] intValue];
		
		
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
			//Add step to steps and entryDict (only valid message are keep in steps)
			[steps addObject:currentStep];
			
			if (isSending) {
				//end sending
				isSending=false;
				
				//Remove indicator sending
				[sendingIndicator removeFromSuperview];
				[sendingIndicator release];
			}
			
			//this line is to change side of player automaticaly (should be commented when public)
			player=p;
			
		}
	}
	
	//Change player side automaticaly (should be commented when public)
	if (player==1) {
		player=2;
	}else player=1;
	
	
}

/** Handle error when request.
 *	
 */
-(void)connection:(NSURLConnection *)connection failedWithError:(NSError *)error{
	NSLog(@"Request to NSURLConnection has failed!");
	//Handle error here
	
}

@end
