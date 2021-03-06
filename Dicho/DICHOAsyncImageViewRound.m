//
//  DICHOAsyncImageView.m
//  Dicho
//
//  Created by Tyler Droll on 5/27/13.
//  Copyright (c) 2013 Locus Engineering LLC. All rights reserved.
//

#import "DICHOAsyncImageViewRound.h"
#import <QuartzCore/QuartzCore.h>

@implementation DICHOAsyncImageViewRound

// This class demonstrates how the URL loading system can be used to make a UIView subclass
// that can download and display an image asynchronously so that the app doesn't block or freeze
// while the image is downloading. It works fine in a UITableView or other cases where there
// are multiple images being downloaded and displayed all at the same time.


- (void)dealloc {
	[connection cancel]; //in case the URL is still downloading
	//[connection release];
	//[data release];
    //[super dealloc];
}


- (void)loadImageFromURL:(NSURL*)url {
	//if (connection!=nil) { [connection release]; } //in case we are downloading a 2nd image
	//if (data!=nil) { [data release]; }
	
	NSURLRequest* request = [NSURLRequest requestWithURL:url cachePolicy:NSURLRequestUseProtocolCachePolicy timeoutInterval:60.0];
	connection = [[NSURLConnection alloc] initWithRequest:request delegate:self]; //notice how delegate set to self object
	//TODO error handling, what if connection is nil?
}


//the URL connection calls this repeatedlNSURLRequest *request = [NSURLRequest requestWithURL:[NSURL URLWithString:@"http://google.com"]];
//y as data arrives
- (void)connection:(NSURLConnection *)theConnection didReceiveData:(NSData *)incrementalData {
	if (data==nil) { data = [[NSMutableData alloc] initWithCapacity:2048]; }
	[data appendData:incrementalData];
}

//the URL connection calls this once all the data has downloaded
- (void)connectionDidFinishLoading:(NSURLConnection*)theConnection {
	//so self data now has the complete image
	//[connection release];
	connection=nil;
	if ([[self subviews] count]>0) {
		//then this must be another image, the old one is still in subviews
		[[[self subviews] objectAtIndex:0] removeFromSuperview]; //so remove it (releases it also)
	}
	
	//make an image view for the image
	UIImageView* imageView = [[UIImageView alloc] initWithImage:[UIImage imageWithData:data]];
	//make sizing choices based on your needs, experiment with these. maybe not all the calls below are needed.
	imageView.contentMode = UIViewContentModeScaleAspectFit;
    imageView.contentMode = UIViewContentModeScaleAspectFill;
	imageView.autoresizingMask = ( UIViewAutoresizingFlexibleWidth || UIViewAutoresizingFlexibleHeight );
	[self addSubview:imageView];
	imageView.frame = self.bounds;
    imageView.clipsToBounds = YES;
    imageView.layer.cornerRadius = 5.0;
	[imageView setNeedsLayout];
	[self setNeedsLayout];
    
	//[data release]; //don't need this any more, its in the UIImageView now
	data=nil;
}

//just in case you want to get the image directly, here it is in subviews
- (UIImage*) image {
	UIImageView* iv = [[self subviews] objectAtIndex:0];
	return [iv image];
}

@end
