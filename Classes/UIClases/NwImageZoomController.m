/**
 *  Copyright 2012 Neurowork Consulting S.L.
 *
 *  This file is part of eMobc.
 *
 *  eMobcViewController.m
 *  eMobc IOS Framework
 *
 *  eMobc is free software: you can redistribute it and/or modify
 *  it under the terms of the Affero GNU General Public License as published by
 *  the Free Software Foundation, either version 3 of the License, or
 *  (at your option) any later version.
 *
 *  eMobc is distributed in the hope that it will be useful,
 *  but WITHOUT ANY WARRANTY; without even the implied warranty of
 *  MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
 *  GNU General Public License for more details.
 *
 *  You should have received a copy of the Affero GNU General Public License
 *  along with eMobc.  If not, see <http://www.gnu.org/licenses/>.
 *
 */

#import "NwImageZoomController.h"
#import "eMobcViewController.h"
#import "NwUtil.h"


@implementation NwImageZoomController

@synthesize data;
@synthesize imageView;
@synthesize scrollView; 
@synthesize varStyles;
@synthesize varFormats;
@synthesize background;

@synthesize sizeTop;
@synthesize sizeBottom;
@synthesize sizeHeaderText;

/**
 * Called after the controller’s view is loaded into memory.
 */
-(void)viewDidLoad {
    [super viewDidLoad];
	
	sizeTop = 0;
	sizeBottom = 0;
	sizeHeaderText = 25;
	
	sizeTop = [mainController ifMenuAndAdsTop:sizeTop];
	sizeBottom = [mainController ifMenuAndAdsBottom:sizeBottom];
	
	loadContent = FALSE;
		
	[self loadPhoto];
}

/**
 * Load HD photo
 */
-(void) loadPhoto {
	UIImageView *tempImageView = nil;
	if (data == nil) {
		tempImageView = [[UIImageView alloc] initWithImage:[UIImage imageNamed:@"plano.jpg"]];
	}else {
		tempImageView = [[UIImageView alloc] initWithImage:[data.image imageContent]];
	}
	
	varStyles = [mainController.theStyle.stylesMap objectForKey:data.levelId];
	
	if (varStyles == nil) {
		varStyles = [mainController.theStyle.stylesMap objectForKey:@"IMAGE_ZOOM_ACTIVITY"];
	}else if(varStyles == nil){
		varStyles = [mainController.theStyle.stylesMap objectForKey:@"DEFAULT"];
	}
	
	if(varStyles != nil) {
		[self loadThemes];
	}	
	
	self.imageView = tempImageView;
	[tempImageView release];
	
	[self createScrollView];
}

-(void) createScrollView{
	if([eMobcViewController isIPad]){
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 1024, 768 - sizeTop - sizeBottom - sizeHeaderText)];	
		}else{
			scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 786, 1024 - sizeTop - sizeBottom - sizeHeaderText)];
		}
	}else{
		if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
			scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 480, 320 - sizeTop - sizeBottom - sizeHeaderText)];	
		}else{
			scrollView = [[UIScrollView alloc] initWithFrame:CGRectMake(0, sizeTop + sizeHeaderText, 320, 480 - sizeTop - sizeBottom - sizeHeaderText)];
		}
	}
	
	scrollView.contentSize = CGSizeMake(imageView.frame.size.width, imageView.frame.size.height);
	scrollView.maximumZoomScale = 4.0;
	scrollView.minimumZoomScale = 0.75;
	scrollView.clipsToBounds = YES;
	scrollView.delegate = self;
	
	[self.view addSubview:scrollView];
	[scrollView addSubview:imageView];
}

/**
 * Load themes from xml to components
 */
-(void)loadThemesComponents {
	
	for(int x = 0; x < varStyles.listComponents.count; x++){
		NSString *var = [varStyles.listComponents objectAtIndex:x];
		
		NSString *type = [varStyles.mapFormatComponents objectForKey:var];
		
		varFormats = [mainController.theFormat.formatsMap objectForKey:type];
		UILabel *myLabel;
		
		if([var isEqualToString:@"header"]){
			if([eMobcViewController isIPad]){
				if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 1024, 20)];	
				}else{
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 768, 20)];
				}				
			}else {
				if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 480, 20)];	
				}else{
					myLabel = [[UILabel alloc] initWithFrame:CGRectMake(0, sizeTop, 320, 20)];
				}				
			}
			
			myLabel.text = data.headerText;
			
			int varSize = [varFormats.textSize intValue];
			
			myLabel.font = [UIFont fontWithName:varFormats.typeFace size:varSize];
			myLabel.backgroundColor = [UIColor clearColor];
			
			//Hay que convertirlo a hexadecimal.
			//	varFormats.textColor
			myLabel.textColor = [UIColor blackColor];
			myLabel.textAlignment = UITextAlignmentCenter;
			
			[self.view addSubview:myLabel];
			[myLabel release];
		}
	}
}


/**
 Carga los temas
 */
-(void) loadThemes {
	if(![varStyles.backgroundFileName isEqualToString:@""]) {
		
		if([eMobcViewController isIPad]){
			if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 1024, 768)];
			}else{
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 768, 1024)];
			}				
		}else {
			if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 480, 320)];
			}else{
				background = [[UIImageView alloc] initWithFrame:CGRectMake(0, 0, 320, 480)];
			}				
		}
		
		NSString *k = [eMobcViewController whatDevice:k];
		
		NSString *imagePath = [[NSBundle mainBundle] pathForResource:varStyles.backgroundFileName ofType:nil inDirectory:k];
		
		background.image = [UIImage imageWithContentsOfFile:imagePath];
		
		[self.view addSubview:background];
		[self.view sendSubviewToBack:background];
		[background release];
	}else{
		self.view.backgroundColor = [UIColor whiteColor];
	}
	
	if(![varStyles.components isEqualToString:@""]) {
		NSArray *separarComponents = [varStyles.components componentsSeparatedByString:@";"];
		NSArray *assignment;
		NSString *component;
		
		for(int i = 0; i < separarComponents.count - 1; i++){
			assignment = [[separarComponents objectAtIndex:i] componentsSeparatedByString:@"="];
			
			component = [assignment objectAtIndex:0];
			NSString *format = [assignment objectAtIndex:1];
			
			[varStyles.mapFormatComponents setObject:format forKey:component];
			
			if(![component isEqual:@"selection_list"]){
				[varStyles.listComponents addObject:component];
			}else{
				varStyles.selectionList = format;
			}
		}
		[self loadThemesComponents];
	}
}



-(void) orientationChanged:(NSNotification *)object{
	UIDeviceOrientation orientation = [[UIDevice currentDevice] orientation];
	
	if(orientation == UIDeviceOrientationFaceUp || orientation == UIDeviceOrientationFaceDown || orientation == UIDeviceOrientationUnknown || currentOrientation == orientation ){
		return;
	}
	
	[NSObject cancelPreviousPerformRequestsWithTarget:self selector:@selector(relayoutLayers) object: nil];
	
	currentOrientation = orientation;
	
	[self performSelector:@selector(orientationChangedMethod) withObject: nil afterDelay: 0];
}

-(void) orientationChangedMethod{
	
	if([[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeLeft || [[UIDevice currentDevice]orientation] == UIInterfaceOrientationLandscapeRight){
		self.view = self.landscapeView;
	}else{
		self.view = self.portraitView;
	}
	
	
	if(loadContent == FALSE){
		loadContent = TRUE;
		
		if(![mainController.appData.backgroundMenu isEqualToString:@""]){
			[self loadBackgroundMenu];
		}
		
		if(![mainController.appData.topMenu isEqualToString:@""]){
			[self callTopMenu];
		}
		if(![mainController.appData.bottomMenu isEqualToString:@""]){
			[self callBottomMenu];
		}
		
		//publicity
		if([mainController.appData.banner isEqualToString:@"admob"]){
			[self createAdmobBanner];
		}else if([mainController.appData.banner isEqualToString:@"yoc"]){
			[self createYocBanner];
		}
		
		[self loadPhoto];
	}	
}

/**
 * Returns a Boolean value indicating whether the view controller supports the specified orientation.
 *
 * @param interfaceOrientation The orientation of the application’s user interface after the rotation. 
 * The possible values are described in UIInterfaceOrientation.
 *
 * @return YES if the view controller supports the specified orientation or NO if it does not
 */
-(BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {	
    return YES;
}

#pragma mark -
#pragma mark UIScrollViewDelegate Protocol Reference


/**
 * Ask to delegate about view with zoom photo when user use scroll
 *
 * @param scrollView
 *
 * @return Retrun zoom image
 */
-(UIView *)viewForZoomingInScrollView:(UIScrollView *)scrollView {
	return imageView;
}

/**
 * Sent to the view controller when the application receives a memory warning
 */
-(void)didReceiveMemoryWarning {
    // Releases the view if it doesn't have a superview.
    [super didReceiveMemoryWarning];
    
    // Release any cached data, images, etc that aren't in use.
}

/**
 * Called when the controller’s view is released from memory.
 */
-(void)viewDidUnload {
    [super viewDidUnload];
    // Release any retained subviews of the main view.
    self.scrollView = nil;
}


-(void)dealloc {
	[imageView release];
	[scrollView release];
	[varStyles release];
	[varFormats release];
	
    [super dealloc];
}

@end