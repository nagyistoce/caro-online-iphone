//
//  GameViewController.h
//  CaroOnline
//
//  Created by V.Anh Tran on 14/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>
#import "CaroOnlineViewController.h"

@interface GameViewController : UIViewController

@property (nonatomic, retain) UIToolbar* toolbar;
@property (nonatomic, readonly, retain) NSString * roomName;

@property (nonatomic, retain) CaroOnlineViewController* caroOnline;

/** Init to play at a room with name
 *	Note: game to play determine by room name;
 */
- (id)initWithRoomName:(NSString*)room;

@end
