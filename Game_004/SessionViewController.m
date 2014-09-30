//
//  SessionViewController.m
//  Game_002
//
//  Created by 寺内 信夫 on 2014/09/27.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "SessionViewController.h"

#import "AppDelegate.h"

@interface SessionViewController ()
{

	
}

@end

@implementation SessionViewController

- (void)viewDidLoad
{
	
	[super viewDidLoad];


	
	NSUUID *uuid = [NSUUID UUID];
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];

	app.myPeerID = [[MCPeerID alloc] initWithDisplayName: [uuid UUIDString]];
	
	app.session = [[MCSession alloc] initWithPeer: app.myPeerID
								 securityIdentity: nil
							 encryptionPreference: MCEncryptionNone];
	
	app.session.delegate = self;

	self.serviceType = @"p2ptest";
	

	UIDevice *dev = [UIDevice currentDevice];

	self.label_MyModel.text = dev.name;
	self.label_MyName.text  = app.myPeerID.displayName;
	
	NSLog( @"%@", dev.name );
	
	if ( [app.string_ServerClient isEqualToString: @"Server"] ) {
		
		self.switch_ServerClient.on = YES;
		
	} else {
		
		self.switch_ServerClient.on = NO;
		
	}
	
	[self setServerClient];

	[self setDisplayClient];
	
}

- (void)didReceiveMemoryWarning
{

	[super didReceiveMemoryWarning];
	// Dispose of any resources that can be recreated.

}

// サーバーとクライアントを設定
- (void)setServerClient
{

	AppDelegate *app = [[UIApplication sharedApplication] delegate];

	//[app.array_PeerID removeAllObjects];
	
	NSDictionary *discoveryInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
								   self.label_MyModel.text, @"name"        ,
								   self.label_MyName.text , @"display_name",
								   @"000000"              , @"your_tansu"  , nil];
	
	if ( self.switch_ServerClient.on ) {
		
		// サーバー
		self.nearbyServiceBrowser = [[MCNearbyServiceBrowser alloc] initWithPeer: app.myPeerID
																	 serviceType: self.serviceType];
		
		self.nearbyServiceBrowser.delegate = self;
		
		[self.nearbyServiceBrowser startBrowsingForPeers];
		
		self.advertiserAssistant = [[MCAdvertiserAssistant alloc] initWithServiceType: self.serviceType
																		discoveryInfo: discoveryInfo
																			  session: app.session];
		
		self.advertiserAssistant.delegate = self;
		
		[self.advertiserAssistant start];

	} else {
		
		// クライアント
		self.nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer: app.myPeerID
																		 discoveryInfo: discoveryInfo
																		   serviceType: self.serviceType];
		
		self.nearbyServiceAdvertiser.delegate = self;
		
		[self.nearbyServiceAdvertiser startAdvertisingPeer];

	}
	
	[self setDisplayClient];
	
}

//- (void)showAlert: (NSString *)title
//		  message: (NSString *)message
//{
//
//	UIAlertView *alert = [[UIAlertView alloc] initWithTitle: title
//													message: message
//												   delegate: self
//										  cancelButtonTitle: @"OK"
//										  otherButtonTitles: nil];
//	
//	[alert show];
//
//}


# pragma mark - MCNearbyServiceBrowserDelegate

// --------------------
// MCNearbyServiceBrowserDelegate
// --------------------

// Error Handling Delegate Methods

// browser:didNotStartBrowsingForPeers:
// Called when a browser failed to start browsing for peers. (required)

- (void)            browser: (MCNearbyServiceBrowser *)browser
didNotStartBrowsingForPeers: (NSError *)error
{

	if(error){
		NSLog(@"[error localizedDescription] %@", [error localizedDescription]);
	}
	
}

// Peer Discovery Delegate Methods

// browser:foundPeer:withDiscoveryInfo:
// Called when a new peer appears. (required)

// peerを他の端末から受け取る
// array_PeerIDに貯める
- (void)  browser: (MCNearbyServiceBrowser *)browser
	    foundPeer: (MCPeerID *)peerID
withDiscoveryInfo: (NSDictionary *)info
{

	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	for ( NSDictionary *dir in app.array_ClientID ) {
		
		MCPeerID *peer_id = [dir objectForKey: @"peer_id"];
		
		if ( [peerID isEqual: peer_id ] ) return;
		
	}
	
	NSString *name = [info objectForKey: @"name"];
	
	NSMutableDictionary *dir = [NSMutableDictionary dictionaryWithObjectsAndKeys:
								peerID            , @"peer_id"     ,
								peerID.displayName, @"display_name",
								name              , @"name"        ,
								@"000000"         , @"your_tensu"  , nil];
	
	[app.array_ClientID addObject: dir];

	[self setDisplayClient];
	
	//[self showAlert: @"found Peer" message:peerID.displayName];
	
//	if([self isPhone]){
//		labelYourPeerIDIPHONE.text = peerID.displayName;
//	}else{
//		labelYourPeerIDIPAD.text = peerID.displayName;
//	}
	
	[self.nearbyServiceBrowser invitePeer: peerID
								toSession: app.session
							  withContext: [@"Welcome" dataUsingEncoding: NSUTF8StringEncoding]
								  timeout: 10];
	
}

// browser:lostPeer:
// Called when a peer disappears. (required)

// peerを他の端末を喪失
// array_PeerIDを削除する
- (void)browser: (MCNearbyServiceBrowser *)browser
	   lostPeer: (MCPeerID *)peerID
{

	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	for ( NSDictionary *dir in app.array_ClientID ) {
		
		MCPeerID *peer_id = [dir objectForKey: @"peer_id"];
		
		if ( [peer_id isEqual: peerID] ) {
			
			[app.array_ClientID removeObject: dir];

			[self setDisplayClient];
			
			return;
			
		}
		
	}
	
}


# pragma mark - MCNearbyServiceAdvertiserDelegate

// --------------------
// MCNearbyServiceAdvertiserDelegate
// --------------------

// Error Handling Delegate Methods

// advertiser:didNotStartAdvertisingPeer:
// Called when advertisement fails. (required)
- (void)        advertiser: (MCNearbyServiceAdvertiser *)advertiser
didNotStartAdvertisingPeer: (NSError *)error
{

	if(error){
		NSLog(@"%@", [error localizedDescription]);
//		[self showAlert:@"ERROR didNotStartAdvertisingPeer" message:[error localizedDescription]];
	}
	
}

// Invitation Handling Delegate Methods

// advertiser:didReceiveInvitationFromPeer:withContext:invitationHandler:
// Called when a remote peer invites the app to join a session. (required)
- (void)          advertiser: (MCNearbyServiceAdvertiser *)advertiser
didReceiveInvitationFromPeer: (MCPeerID *)peerID
				 withContext: (NSData *)context
		   invitationHandler: (void (^)( BOOL accept, MCSession *session ))invitationHandler
{

	AppDelegate *app = [[UIApplication sharedApplication] delegate];

	invitationHandler(TRUE, app.session);
//	[self showAlert:@"didReceiveInvitationFromPeer" message:@"accept invitation!"];
	
	if ( context ) {
		
		NSLog( @"%@", context );
		
	}
	
}


#pragma mark - MCSessionDelegate

// --------------------
// MCSessionDelegate
// --------------------

// MCSession Delegate Methods

// session:didReceiveData:fromPeer:
// Called when a remote peer sends an NSData object to the local peer. (required)
- (void)session: (MCSession *)session
 didReceiveData: (NSData *)data
	   fromPeer: (MCPeerID *)peerID
{

	NSString *receivedData = [[NSString alloc] initWithData: data
												   encoding: NSUTF8StringEncoding];
//	[self showAlert:@"didReceiveData" message:receivedData];
}

// session:didStartReceivingResourceWithName:fromPeer:withProgress:
// Called when a remote peer begins sending a file-like resource to the local peer. (required)
- (void)session:(MCSession *)session didStartReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID withProgress:(NSProgress *)progress
{

}

// session:didFinishReceivingResourceWithName:fromPeer:atURL:withError:
// Called when a remote peer sends a file-like resource to the local peer. (required)
- (void)session:(MCSession *)session didFinishReceivingResourceWithName:(NSString *)resourceName fromPeer:(MCPeerID *)peerID atURL:(NSURL *)localURL withError:(NSError *)error
{

}

// session:didReceiveStream:withName:fromPeer:
// Called when a remote peer opens a byte stream connection to the local peer. (required)
- (void)session:(MCSession *)session didReceiveStream:(NSInputStream *)stream withName:(NSString *)streamName fromPeer:(MCPeerID *)peerID
{

}

// session:peer:didChangeState:
// Called when the state of a remote peer changes. (required)
- (void)session:(MCSession *)session peer:(MCPeerID *)peerID didChangeState:(MCSessionState)state
{

	NSLog(@"[peerID] %@", peerID);
	NSLog(@"[state] %d", state);
	//[self showAlert:@"didChangeState" message:[NSString stringWithFormat:@"[state] %d", state]];
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];

	if(state == MCSessionStateConnected && app.session){
		
		NSLog(@"session sends data!");
		NSError *error;
		NSString *message = [NSString stringWithFormat:@"message from %@", app.myPeerID.displayName];
		[app.session sendData: [message dataUsingEncoding: NSUTF8StringEncoding]
					  toPeers: [NSArray arrayWithObject: peerID]
					 withMode: MCSessionSendDataReliable
						error: &error];
		
		//[self showAlert:@"Send data" message:@"hello"];
	
	}

}

// session:didReceiveCertificate:fromPeer:certificateHandler:
// Called to authenticate a remote peer when the connection is first established. (required)
- (BOOL)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
{

	certificateHandler(TRUE);
	return TRUE;
}

//
//# pragma mark - Advertising
//
//// -----------------------------
//// Advertising
//// -----------------------------
//
//- (void)startAdvertising
//{
//	
//	NSDictionary *discoveryInfo = [[NSDictionary alloc] initWithObjectsAndKeys:
//								   @"foo", @"bar", @"bar", @"foo", nil];
//	
//	AppDelegate *app = [[UIApplication sharedApplication] delegate];
//
//	self.nearbyServiceAdvertiser = [[MCNearbyServiceAdvertiser alloc] initWithPeer: app.myPeerID
//																	 discoveryInfo: discoveryInfo
//																	   serviceType: self.serviceType];
//	self.nearbyServiceAdvertiser.delegate = self;
//	
//	[self.nearbyServiceAdvertiser startAdvertisingPeer];
//
//}
//
//- (IBAction)btnStartAdvertisingIPHONE:(id)sender
//{
//
//	//[self showAlert:@"iPhone" message:@"startAdvertisingPeer"];
//	[self startAdvertising];
//
//}
//
//- (IBAction)btnStartAdvertisingIPAD:(id)sender
//{
//
//	//[self showAlert:@"iPad" message:@"startAdvertisingPeer"];
//	[self startAdvertising];
//
//}
//
//- (IBAction)btnStopAdvertisingIPHONE:(id)sender
//{
//
//	//[self showAlert:@"iPhone" message:@"stopAdvertisingPeer"];
//	[self.nearbyServiceAdvertiser stopAdvertisingPeer];
//
//}
//
//- (IBAction)btnStopAdvertisingIPAD:(id)sender
//{
//
//	//[self showAlert:@"iPad" message:@"stopAdvertisingPeer"];
//	[self.nearbyServiceAdvertiser stopAdvertisingPeer];
//
//}
//

# pragma mark - Browsing

// -----------------------------
// Browsing
// -----------------------------

- (IBAction)btnStartBrowsingIPHONE:(id)sender
{

	//[self showAlert:@"iPhone" message:@"startBrowsingForPeers"];
	[self.nearbyServiceBrowser startBrowsingForPeers];
	
}

- (IBAction)btnStopBrowsingIPHONE:(id)sender
{

	//[self showAlert:@"iPhone" message:@"stopBrowsingForPeers"];
	[self.nearbyServiceBrowser stopBrowsingForPeers];
	
}

- (IBAction)btnStartBrowsingIPAD:(id)sender
{

	//[self showAlert:@"iPad" message:@"startBrowsingForPeers"];
	[self.nearbyServiceBrowser startBrowsingForPeers];
	
}

- (IBAction)btnStopBrowsingIPAD:(id)sender
{

	//[self showAlert:@"iPad" message:@"stopBrowsingForPeers"];
	[self.nearbyServiceBrowser stopBrowsingForPeers];
	
}

// クライアントのpeerを書く
- (void)setDisplayClient
{

//	self.label_ClientModel_1.hidden = YES;
//	self.label_DisplayName_1.hidden = YES;
//	self.label_ClientModel_2.hidden = YES;
//	self.label_DisplayName_2.hidden = YES;
//	self.label_ClientModel_3.hidden = YES;
//	self.label_DisplayName_3.hidden = YES;
	
	NSInteger i = 0;
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	for ( NSDictionary *dir in app.array_ClientID ) {
		
		switch ( i ) {

			case 0:
    
				self.label_ClientModel_1.hidden = NO;
				self.label_DisplayName_1.hidden = NO;
				
				self.label_ClientModel_1.text = [dir objectForKey: @"name"];
				self.label_DisplayName_1.text = [dir objectForKey: @"display_name"];
			
				break;
				
			case 1:
				
				self.label_ClientModel_2.hidden = NO;
				self.label_DisplayName_2.hidden = NO;
				
				self.label_ClientModel_2.text = [dir objectForKey: @"name"];
				self.label_DisplayName_2.text = [dir objectForKey: @"display_name"];
				
				break;
				
			case 2:
				
				self.label_ClientModel_3.hidden = NO;
				self.label_DisplayName_3.hidden = NO;
				
				self.label_ClientModel_3.text = [dir objectForKey: @"name"];
				self.label_DisplayName_3.text = [dir objectForKey: @"display_name"];
				
				break;
				
			default:
    
				break;
	
		}
	
		i ++;
		
	}
	
}

- (IBAction)button_Action:(id)sender
{

	MCBrowserViewController *browserViewController;
	browserViewController = [[MCBrowserViewController alloc] initWithServiceType: self.serviceType
																		 session: self.advertiserAssistant.session];
	
	browserViewController.delegate = self;
	browserViewController.minimumNumberOfPeers = kMCSessionMinimumNumberOfPeers;
	browserViewController.maximumNumberOfPeers = kMCSessionMaximumNumberOfPeers;
	
	[self presentViewController: browserViewController animated:YES completion:NULL];
	
}

- (IBAction)toPlay_Action:(id)sender
{

}

- (void)browserViewControllerDidFinish: (MCBrowserViewController *)browserViewController
{
	
	[browserViewController dismissViewControllerAnimated: YES
											  completion: nil];
	
}

- (void)browserViewControllerWasCancelled:(MCBrowserViewController *)browserViewController
{
	
	[browserViewController dismissViewControllerAnimated: YES
											  completion: nil];
	
}

@end