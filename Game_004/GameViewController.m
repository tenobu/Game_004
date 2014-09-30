//
//  GameViewController.m
//  Game_002
//
//  Created by 寺内 信夫 on 2014/09/26.
//  Copyright (c) 2014年 寺内 信夫. All rights reserved.
//

#import "GameViewController.h"

#import "AppDelegate.h"

@implementation GameViewController
{

@private
	
	NSInteger integer_MyTensu;
	
	NSMutableArray *array_OthersTensu;
	
}

- (void)viewDidLoad
{
	
    [super viewDidLoad];

	AppDelegate *app = [[UIApplication sharedApplication] delegate];

	app.session.delegate = self;
	
	
	array_OthersTensu = [[NSMutableArray alloc] init];
	
	
    // create a new scene
    SCNScene *scene = [SCNScene sceneNamed:@"art.scnassets/ship.dae"];

    // create and add a camera to the scene
    SCNNode *cameraNode = [SCNNode node];
    cameraNode.camera = [SCNCamera camera];
    [scene.rootNode addChildNode:cameraNode];
    
    // place the camera
    cameraNode.position = SCNVector3Make(0, 0, 15);
    
    // create and add a light to the scene
    SCNNode *lightNode = [SCNNode node];
    lightNode.light = [SCNLight light];
    lightNode.light.type = SCNLightTypeOmni;
    lightNode.position = SCNVector3Make(0, 10, 10);
    [scene.rootNode addChildNode:lightNode];
    
    // create and add an ambient light to the scene
    SCNNode *ambientLightNode = [SCNNode node];
    ambientLightNode.light = [SCNLight light];
    ambientLightNode.light.type = SCNLightTypeAmbient;
    ambientLightNode.light.color = [UIColor darkGrayColor];
    [scene.rootNode addChildNode:ambientLightNode];
    
    // retrieve the ship node
    SCNNode *ship = [scene.rootNode childNodeWithName: @"ship"
										  recursively: YES];
    
    // animate the 3d object
    [ship runAction: [SCNAction repeatActionForever: [SCNAction rotateByX:0 y:2 z:0 duration:1]]];
    
    // retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // set the scene to the view
    scnView.scene = scene;
    
    // allows the user to manipulate the camera
    scnView.allowsCameraControl = YES;
        
    // show statistics such as fps and timing information
    scnView.showsStatistics = YES;

    // configure the view
    scnView.backgroundColor = [UIColor blackColor];
    
    // add a tap gesture recognizer
    UITapGestureRecognizer *tapGesture = [[UITapGestureRecognizer alloc] initWithTarget: self
																				 action: @selector( handleTap: )];
	
    NSMutableArray *gestureRecognizers = [NSMutableArray array];
    [gestureRecognizers addObject:tapGesture];
    [gestureRecognizers addObjectsFromArray:scnView.gestureRecognizers];
    scnView.gestureRecognizers = gestureRecognizers;
		
	[self setDisplayClient];
	
}

- (void)handleTap: (UIGestureRecognizer*)gestureRecognize
{

	// retrieve the SCNView
    SCNView *scnView = (SCNView *)self.view;
    
    // check what nodes are tapped
    CGPoint p = [gestureRecognize locationInView: scnView];
	
    NSArray *hitResults = [scnView hitTest: p
								   options: nil];
    
    // check that we clicked on at least one object
    if([hitResults count] > 0){
        // retrieved the first clicked object
        SCNHitTestResult *result = [hitResults objectAtIndex:0];
        
        // get its material
        SCNMaterial *material = result.node.geometry.firstMaterial;
        
        // highlight it
        [SCNTransaction begin];
        [SCNTransaction setAnimationDuration:0.5];
        
        // on completion - unhighlight
        [SCNTransaction setCompletionBlock:^{
            [SCNTransaction begin];
            [SCNTransaction setAnimationDuration:0.5];
            
            material.emission.contents = [UIColor blackColor];
            
            [SCNTransaction commit];
        }];
        
        material.emission.contents = [UIColor redColor];
        
        [SCNTransaction commit];
		
		integer_MyTensu += 10;
		
		self.label_MyTensu.text = [NSString stringWithFormat: @"%06ld", integer_MyTensu];
		
		NSError *error = nil;

		NSString *str = self.label_MyTensu.text;
		NSData *data = [str dataUsingEncoding: NSUTF8StringEncoding];
		
		AppDelegate *app = [[UIApplication sharedApplication] delegate];

		NSArray *peerIDs = app.session.connectedPeers;
		
		[app.session sendData: data
					  toPeers: peerIDs
					 withMode: MCSessionSendDataReliable
						error: &error];

	}

	[self setDisplayClient];
	
}


- (BOOL)shouldAutorotate
{
	
	return YES;

}

- (NSUInteger)supportedInterfaceOrientations
{

	if ([[UIDevice currentDevice] userInterfaceIdiom] == UIUserInterfaceIdiomPhone) {
		
		return UIInterfaceOrientationMaskAllButUpsideDown;
		
	} else {
		
		return UIInterfaceOrientationMaskAll;
		
	}

}

- (void)didReceiveMemoryWarning
{

	[super didReceiveMemoryWarning];
    // Release any cached data, images, etc that aren't in use.

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
	
	NSString *your_tensu = [[NSString alloc] initWithData: data
												   encoding: NSUTF8StringEncoding];
	
	NSLog( @"your_tensu = %@", your_tensu );
	//	[self showAlert:@"didReceiveData" message:receivedData];
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	for ( NSMutableDictionary *dic in app.array_PeerID ) {
		
		MCPeerID *peer_id = [dic objectForKey: @"peer_id"];
		
		if ( [peer_id isEqual: peerID] ) {
			
			[dic setObject: your_tensu forKey: @"your_tensu"];
						
			[self setDisplayClient];
			
			return;
			
		}
		
	}

}

// session:didStartReceivingResourceWithName:fromPeer:withProgress:
// Called when a remote peer begins sending a file-like resource to the local peer. (required)
- (void)                  session: (MCSession *)session
didStartReceivingResourceWithName: (NSString *)resourceName
	                     fromPeer: (MCPeerID *)peerID
					 withProgress: (NSProgress *)progress
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
- (void)session: (MCSession *)session
		   peer: (MCPeerID *)peerID
 didChangeState: (MCSessionState)state
{
	
//	NSLog(@"[peerID] %@", peerID);
//	NSLog(@"[state] %d", state);
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
//- (BOOL)session:(MCSession *)session didReceiveCertificate:(NSArray *)certificate fromPeer:(MCPeerID *)peerID certificateHandler:(void (^)(BOOL accept))certificateHandler
//{
//	
//	certificateHandler(TRUE);
//	return TRUE;
//}

// クライアントの点数を書く
- (void)setDisplayClient
{
	
	self.label_Other_1.hidden       = YES;
	self.label_OthersTensu_1.hidden = YES;
	self.label_Other_2.hidden       = YES;
	self.label_OthersTensu_2.hidden = YES;
	self.label_Other_3.hidden       = YES;
	self.label_OthersTensu_3.hidden = YES;
	self.label_Other_4.hidden       = YES;
	self.label_OthersTensu_4.hidden = YES;
	self.label_Other_5.hidden       = YES;
	self.label_OthersTensu_5.hidden = YES;
	self.label_Other_6.hidden       = YES;
	self.label_OthersTensu_6.hidden = YES;
	self.label_Other_7.hidden       = YES;
	self.label_OthersTensu_7.hidden = YES;
	
	NSInteger i = 0;
	
	AppDelegate *app = [[UIApplication sharedApplication] delegate];
	
	for ( NSDictionary *dir in app.array_PeerID ) {
		
		switch ( i ) {
				
			case 0:
    
				self.label_Other_1.hidden       = NO;
				self.label_OthersTensu_1.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_1.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 1:
				
				self.label_Other_2.hidden       = NO;
				self.label_OthersTensu_2.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_2.text = your_tensu;

				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 2:
				
				self.label_Other_3.hidden       = NO;
				self.label_OthersTensu_3.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_3.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 3:
				
				self.label_Other_4.hidden       = NO;
				self.label_OthersTensu_4.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_4.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 4:
				
				self.label_Other_5.hidden       = NO;
				self.label_OthersTensu_5.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_5.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 5:
				
				self.label_Other_6.hidden       = NO;
				self.label_OthersTensu_6.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_6.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			case 6:
				
				self.label_Other_7.hidden       = NO;
				self.label_OthersTensu_7.hidden = NO;
				
			{
				NSString *your_tensu = [dir objectForKey: @"your_tensu"];
				self.label_OthersTensu_7.text = your_tensu;
				
				NSLog( @"tensu = %@", your_tensu );
			}
				
				break;
				
			default:
    
				break;
				
		}
		
		i ++;
		
	}
	
}

@end
