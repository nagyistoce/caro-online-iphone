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

@interface CaroOnlineViewController : UIViewController <CaroBoardDelegate,ICTchatConnectionDelegate>{
	UIImage* imageX; 
	UIImage* imageO;
	NSMutableArray* steps;
	NSMutableDictionary * entryDict;
	float time;
	Boolean isSending;
	
	
	float timeOfLastRequest;
	
	UIActivityIndicatorView *sendingIndicator;
	
}

/** Init a view that can play a caro game on it
 *	Provide resources by Images.
 *	@param room=name of room to load Request from.
 */
- (id)initWithCaroBoard:(UIImage*)BoardImage imageX:(UIImage*)imgX imageO:(UIImage*)imgO roomName:(NSString*)room;

@property (nonatomic, retain) CaroBoard * board;
@property (nonatomic, retain) CaroGameLogic * gameControl;

/** Side of player 1,2 = x,o
 */
@property (nonatomic) int player;

/** Pause requesting to server!
 */
@property (nonatomic) Boolean pause;

/** Room Name
 */
@property (nonatomic, assign) NSString * roomName;

@end
