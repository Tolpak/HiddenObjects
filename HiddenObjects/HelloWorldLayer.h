//
//  HelloWorldLayer.h
//  HiddenObjects
//
//  Created by moyo on 20.04.19.
//  Copyright __MyCompanyName__ 2019. All rights reserved.
//


#import <GameKit/GameKit.h>

#import "cocos2d.h"

@interface HelloWorldLayer : CCLayer <CCTargetedTouchDelegate>
{
    CCSprite *background;
}
@property (nonatomic, retain) NSMutableSet *startTouches;
@property (nonatomic, assign) float zoom;
@property (nonatomic, assign) float fitScale;

+(CCScene *) scene;

@end
