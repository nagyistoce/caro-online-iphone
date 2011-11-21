//
//  CaroOnlineViewController.h
//  CaroOnline
//
//  Created by V.Anh Tran on 13/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaroBoard.h"
#import "CaroGameLogic.h"
#import "ICTchatConnection.h"
#import "ChatViewController.h"


@interface CaroOnlineViewController : UIViewController <CaroBoardDelegate,ICTchatConnectionDelegate,UIAlertViewDelegate>{
	UIImage* boardImage;
	UIImage* imageX; 
	UIImage* imageO;
	NSMutableArray* steps;
	NSMutableArray* messages;
	NSMutableDictionary * entryDict;
	float time;
	Boolean isSending;
	
	CaroGameLogic * gameControl;
	
	float timeOfLastRequest;
	
	NSTimer * timer;
	UIActivityIndicatorView *sendingIndicator;
	
	CaroBoard * board; 
	
	NSString * newGameRoomNameAsk;
}

/** Init a view that can play a caro game on it
 *	Provide resources by Images.
 *	@param room=name of room to load Request from.
 */
- (id)initWithCaroBoard:(UIImage*)BoardImage imageX:(UIImage*)imgX imageO:(UIImage*)imgO roomName:(NSString*)room;

/** Reload to play a new  caro game
 *	@param room=name of room to load Request from.
 */
- (void)reloadWithRoomName:(NSString*)room;

/** Side of player 1,2 = x,o
 */
@property (nonatomic) int player;

/** Pause requesting to server!
 */
@property (nonatomic) Boolean pause;

/** Room Name
 */
@property (nonatomic, assign) NSString * roomName;

/** ChatView for push messages;
 */
@property (nonatomic, assign) ChatViewController * chatView;

@end
