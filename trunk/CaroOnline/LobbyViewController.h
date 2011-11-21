//
//  LobbyViewController.h
//  CaroOnline
//
//  Created by V.Anh Tran on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "PickRoomTableViewController.h"
#import "GameViewController.h"
#import "ChatViewController.h"

@interface LobbyViewController : UIViewController <PickRoomDelegate>{
	NSMutableArray * listRoom;
	NSMutableArray * listIcon;
	NSMutableArray * roomEntries;
	
	NSString * lobbyName;
	GameViewController* game;
	
	Boolean	isSending;
	
	UIActivityIndicatorView* sendingIndicator;
}

@property (nonatomic, retain) UIToolbar* toolbar;
@property (nonatomic, retain) PickRoomTableViewController* roomPicker;
@property (nonatomic, retain) ChatViewController* chatView;

/** Init a lobby to pick table game and chat
 * @param ServerName
 */
- (id)initWithLobbyName:(NSString*)lobby;

@end
