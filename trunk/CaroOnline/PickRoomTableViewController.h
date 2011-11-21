//
//  PickRoomTableViewController.h
//  CaroOnline
//
//  Created by V.Anh Tran on 15/11/2011.
//  Copyright (c) 2011 __MyCompanyName__. All rights reserved.
//

#import <UIKit/UIKit.h>

@protocol PickRoomDelegate <NSObject>

/** Event pick a room.
 *	
 */
- (void)pickRoomName:(NSString*)room;

@end

@interface PickRoomTableViewController : UITableViewController{
	
}

@property (nonatomic,assign) NSArray* listRoom;
@property (nonatomic,assign) NSArray* listIcon;
@property (nonatomic) Boolean reverse;
@property (nonatomic,assign)id delegate;

/** Init a table to pick room name
 * @param List = Array of room name
 */
- (id)initWithStyle:(UITableViewStyle)style List:(NSArray*)alist delegate:(id)Delegate;

@end
