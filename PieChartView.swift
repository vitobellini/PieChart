//
//  PieChartView.swift
//
//  Created by Vito Bellini on 03/01/15.
//  Copyright (c) 2015 Vito Bellini. All rights reserved.
//

import UIKit

class PieChartItem {
    var color: UIColor
    var value: Float
    
    init(value: Float = 0, color: UIColor) {
        self.color = color
        self.value = value
    }
}

class PieChartView: UIView {
    var items: [PieChartItem] = [PieChartItem]()
    var sum: Float = 0
    
    var gradientFillColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.4)

    var gradientStart: Float = 0.3
    var gradientEnd: Float = 1

    
    override init(frame: CGRect) {
        super.init(frame: frame)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    required init(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        
        self.backgroundColor = UIColor.clearColor()
    }
    
    func clearItems() {
        items.removeAll(keepCapacity: true)
        sum = 0
    }
    
    func addItem(value: Float, color: UIColor) {
        let item = PieChartItem(value: value, color: color)
        
        items.append(item)
        sum += value
    }

    

    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        
        func createCircleMaskUsingCenterPoint(point: CGPoint, radius: Float) -> UIImage {
            UIGraphicsBeginImageContext( self.bounds.size )
            let ctx2: CGContextRef = UIGraphicsGetCurrentContext()
            CGContextSetRGBFillColor(ctx2, 1.0, 1.0, 1.0, 1.0 )
            CGContextFillRect(ctx2, self.bounds)
            CGContextSetRGBFillColor(ctx2, 0.0, 0.0, 0.0, 1.0 )
            CGContextMoveToPoint(ctx2, point.x, point.y)
            CGContextAddArc(ctx2, point.x, point.y, CGFloat(radius), 0.0, (360.0)*CGFloat(M_PI)/180.0, 0)
            CGContextClosePath(ctx2)
            CGContextFillPath(ctx2)
            let maskImage: UIImage = UIGraphicsGetImageFromCurrentImageContext()
            UIGraphicsPopContext()
            
            return maskImage;
        }
        
        func createGradientImageUsingRect(rect: CGRect) -> UIImage {
            let color = gradientFillColor
            let cgColor = color.CGColor
            
            let numComponents = CGColorGetNumberOfComponents(cgColor)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if (numComponents == 4) {
                let components = CGColorGetComponents(cgColor)
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            }
            
            UIGraphicsBeginImageContext( rect.size );
            let ctx3 = UIGraphicsGetCurrentContext();
            
            let locationsCount: UInt = 2
            let locations: [CGFloat] = [ 1.0-CGFloat(gradientStart), 1.0-CGFloat(gradientEnd) ]
            let components: [CGFloat] = [0, 0, 0, 0, red, green, blue, alpha]
            
            let rgbColorspace = CGColorSpaceCreateDeviceRGB();
            let gradient = CGGradientCreateWithColorComponents(rgbColorspace, components, locations, locationsCount);
            
            let currentBounds = rect;
            let topCenterPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMaxY(currentBounds));
            let bottomCenterPoint = CGPointMake(CGRectGetMidX(currentBounds), CGRectGetMinY(currentBounds));
            CGContextDrawLinearGradient(ctx3, gradient, topCenterPoint, bottomCenterPoint, 0);

            
            let gradientImage: UIImage = UIGraphicsGetImageFromCurrentImageContext();
            UIGraphicsPopContext();
            
            return gradientImage;
        }
        
        func maskImage(image: UIImage, maskImage: UIImage) -> UIImage {
            
            let maskRef: CGImageRef = maskImage.CGImage;
            
            let mask: CGImageRef = CGImageMaskCreate(CGImageGetWidth(maskRef),
                CGImageGetHeight(maskRef),
                CGImageGetBitsPerComponent(maskRef),
                CGImageGetBitsPerPixel(maskRef),
                CGImageGetBytesPerRow(maskRef),
                CGImageGetDataProvider(maskRef), nil, false);
            
            let masked: CGImageRef = CGImageCreateWithMask(image.CGImage, mask)
            
            let ret = UIImage(CGImage: masked)!
            return ret
        }

        
        // Drawing code
        
        var startDeg: Float = 0
        var endDeg: Float = 0
        
        let ctx: CGContextRef = UIGraphicsGetCurrentContext()
        CGContextSetRGBStrokeColor(ctx, 0.0, 0.0, 0.0, 0.4)
        CGContextSetLineWidth(ctx, 1.0)

        var x: CGFloat = self.center.x
        var y: CGFloat = self.center.y
        var r: CGFloat = (self.bounds.size.width > self.bounds.size.height ? self.bounds.size.height : self.bounds.size.width)/2 * 0.8
        
        // Draw a thin line around the circle
        CGContextAddArc(ctx, x, y, r, 0.0, CGFloat(360.0 * M_PI / 180.0), 0)
        CGContextClosePath(ctx)
        CGContextDrawPath(ctx, kCGPathStroke)
        
        // Loop through all the values and draw the graph
        startDeg = 0;
        
        for item in self.items {
            let numComponents = CGColorGetNumberOfComponents(item.color.CGColor)
            
            var red: CGFloat = 0
            var green: CGFloat = 0
            var blue: CGFloat = 0
            var alpha: CGFloat = 0
            
            if (numComponents == 4) {
                let components = CGColorGetComponents(item.color.CGColor)
                red = components[0]
                green = components[1]
                blue = components[2]
                alpha = components[3]
            }
            
            var currentValue: Float = item.value;
            
            var theta: Float = (360.0 * (currentValue/sum));
            
            if(theta > 0.0) {
                endDeg += theta;
                
                if( startDeg != endDeg ) {
                    CGContextSetRGBFillColor(ctx, red, green, blue, alpha );
                    CGContextMoveToPoint(ctx, x, y);
                    let startAngle: CGFloat = (CGFloat(startDeg)-90.0) * CGFloat(M_PI) / 180.0
                    let endAngle: CGFloat = (CGFloat(endDeg)-90.0) * CGFloat(M_PI) / 180.0
                    CGContextAddArc(ctx, x, y, r, startAngle, endAngle, 0)
                    CGContextClosePath(ctx);
                    CGContextFillPath(ctx);
                }
                
            }
            
            startDeg = endDeg;
        }
        
        // Gradient overlay
        let center = CGPointMake(x, y)
        
        let maskImg: UIImage = createCircleMaskUsingCenterPoint(center, Float(r))
        let gradientImage = createGradientImageUsingRect(self.bounds)
        let fadeImage = maskImage(gradientImage, maskImg)

        // Shadows
        self.layer.shadowRadius = 3;
        self.layer.shadowColor = UIColor.blackColor().CGColor
        self.layer.shadowOpacity = 0.6;
        self.layer.shadowOffset = CGSizeMake(5.0, 5.0);

    }

}
