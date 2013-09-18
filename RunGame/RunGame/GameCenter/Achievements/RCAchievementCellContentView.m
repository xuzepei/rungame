//
//  RCAchievementCellContentView.m
//  BeatMole
//
//  Created by xuzepei on 8/14/13.
//
//

#import "RCAchievementCellContentView.h"

#define TITLE_COLOR [UIColor colorWithRed:164/255.0 green:82/255.0 blue:36/255.0 alpha:1.00]
#define DESC_COLOR [UIColor colorWithRed:138/255.0 green:102/255.0 blue:90/255.0 alpha:1.00]

@implementation RCAchievementCellContentView

- (id)initWithFrame:(CGRect)frame
{
    self = [super initWithFrame:frame];
    if (self) {
        self.backgroundColor = [UIColor clearColor];
    }
    return self;
}

- (void)dealloc
{
    self.item = nil;
    self.imageUrl = nil;
    self.image = nil;
    self.delegate = nil;
    self.selected = NO;
    
    [super dealloc];
}

- (void)drawRectBorder:(CGRect)rect
{
    CGContextRef context = UIGraphicsGetCurrentContext();
    CGContextSaveGState(context);
    
    CGContextSetRGBStrokeColor(context, 140/255.0, 18/255.0, 111/255.0, 1.0);
    CGContextSetLineWidth(context, 2.0);
    CGContextAddRect(context, CGRectMake(rect.origin.x - 1, rect.origin.y - 1, rect.size.width + 2.0, rect.size.height + 2.0));
    CGContextStrokePath(context);
    
    CGContextRestoreGState(context);
}



// Only override drawRect: if you perform custom drawing.
// An empty implementation adversely affects performance during animation.
- (void)drawRect:(CGRect)rect
{
    if(nil == _item)
        return;
    
    CGFloat offset_x = 10.0;
    CGFloat offset_y = 10.0;
    
    CGRect temp = CGRectMake(66, offset_y + 10, 300, self.bounds.size.height - 22);
    [[UIColor blackColor] set];
    UIRectFill(temp);
    
    [self drawRectBorder:temp];
    
    offset_y += 12.0;
    UIImage* image = [UIImage imageNamed:@"frame"];
    if(image)
        [image drawInRect:CGRectMake(6, offset_y - 5, image.size.width/2.0, image.size.height/2.0)];
    
    NSString* imageName = [NSString stringWithFormat:@"achievement_%@.png",_item.id];
    image = [UIImage imageNamed:imageName];
    [image drawInRect:CGRectMake(12.5, offset_y + 1.5, image.size.width/2.0, image.size.height/2.0)];
    
    NSString* title = _item.name;
    if([title length])
    {
        [TITLE_COLOR set];
        
        CGSize size = [title drawInRect:CGRectMake(offset_x + 60, offset_y, 300, CGFLOAT_MAX) withFont:[UIFont boldSystemFontOfSize:16]
                          lineBreakMode:NSLineBreakByCharWrapping
                              alignment:NSTextAlignmentLeft];
        
        offset_y += size.height + 2;
    }
    
    NSString* desc = _item.desc;
    if([desc length])
    {
        [DESC_COLOR set];
        
        [desc drawInRect:CGRectMake(offset_x + 60, offset_y, 300, CGFLOAT_MAX) withFont:[UIFont systemFontOfSize:14]
                            lineBreakMode:NSLineBreakByTruncatingTail
                                alignment:NSTextAlignmentLeft];
    }
}


- (void)updateContent:(id)item isLast:(BOOL)isLast
{
    self.isLast = isLast;
    self.item = (Achievement*)item;
    
    [self setNeedsDisplay];
    
}

#pragma mark - RCImageLoaderDelegate

- (void)succeedLoad:(id)result token:(id)token
{
    
}

@end
