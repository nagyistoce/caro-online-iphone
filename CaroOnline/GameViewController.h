//
//  GameViewController.h
//  CaroOnline
//
//  Created by V.Anh Tran on 14/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaroOnlineViewController.h"
#import "ChatViewController.h"

@interface GameViewController : UIViewController <ChatDelegate>{
	UIImage * imageXicon;
	UIImage * imageOicon;
	UIButton *switchSideButton;
	
	CaroOnlineViewController* caroOnline;
	
	
}


@property (nonatomic, readonly, retain) NSString * roomName;

@property (nonatomic, retain)UIToolbar* toolbar;

@property (nonatomic, retain) ChatViewController* chatView;

@property (nonatomic, retain) UIActivityIndicatorView* sendingIndicator;

/** Init to play at a room with name
 *	Note: game to play determine by room name;
 */
- (id)initWithRoomName:(NSString*)room;

/** Reload to play a new  caro game
 *	@param room=name of room to load Request from.
 */
- (void)reloadWithRoomName:(NSString*)room;

@end
