//
//  GKMatchmakerViewController+LandscapeOnly.m
//  BeatMole
//
//  Created by xuzepei on 8/12/13.
//
//

#import "GKMatchmakerViewController+LandscapeOnly.h"

@implementation GKMatchmakerViewController (LandscapeOnly)

- (BOOL)shouldAutorotateToInterfaceOrientation:(UIInterfaceOrientation)interfaceOrientation {
    return (UIInterfaceOrientationIsLandscape(interfaceOrientation));
}

@end
