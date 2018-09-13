//
//  FacialFeatures.swift
//  MLApp
//
//  Created by DImple on 01/12/17.
//  Copyright © 2017 DImple. All rights reserved.
//

import UIKit

class FacialFeatures: NSObject {

    class func calculateFacialFeatures(data: NSMutableArray) -> [Double] {
       
      let outerBrowRaiserValue = outerBrowRaiser(right: [data.getY(index: 17), data.getY(index: 36), data.getY(index: 18), data.getY(index: 36)],
                                                 left: [data.getY(index: 26), data.getY(index: 45), data.getY(index: 25), data.getY(index: 45)])
       
        let browLowererValue = browLowerer(right: [data.getY(index: 21), data.getY(index: 39), data.getY(index: 20), data.getY(index: 38), data.getY(index: 19), data.getY(index: 37)],
                                           left: [data.getY(index: 22), data.getY(index: 42), data.getY(index: 23), data.getY(index: 43), data.getY(index: 24), data.getY(index: 44)])
        
        let upperLidRaiserValue = upperLidRaiser(right: [data.getY(index: 37), data.getY(index: 41), data.getY(index: 38), data.getY(index: 40)],
                                                 left: [data.getY(index: 43), data.getY(index: 47), data.getY(index: 44), data.getY(index: 46)])
        
        let cheekRaiserValue = cheekRaiser(right: [data.getY(index: 40), data.getY(index: 48)],
                                                 left: [data.getY(index: 47), data.getY(index: 54)])
        
        let lidTightenerValue = lidTightener(right: [data.getY(index: 37), data.getY(index: 41), data.getY(index: 38), data.getY(index: 40)],
                                                 left: [data.getY(index: 43), data.getY(index: 47), data.getY(index: 44), data.getY(index: 46)])
        
        let noseWrinklerValue = noseWrinkler(right: [data.getY(index: 39), data.getY(index: 31)],
                                           left: [data.getY(index: 42), data.getY(index: 35)])
        
        let lipCornerPullerValue = lipCornerPuller(right: data.getX(index: 48), left: data.getX(index: 54))
        
        let dimplerValue = dimpler(right: [data.getY(index: 40), data.getY(index: 48)],
                                             left: [data.getY(index: 47), data.getY(index: 54)])
        
        let lipCornerDepresserValue = lipCornerDepresser(right: data.getY(index: 48), left: data.getY(index: 54), middle: [data.getY(index: 8), data.getY(index: 57)])
        
        let lowerLipDepresserValue = lowerLipDepresser(param: [data.getY(index: 50), data.getY(index: 58), data.getY(index: 51), data.getY(index: 57), data.getY(index: 52), data.getY(index: 56)])
        
        let lipStretcherValue = lipStretcher(param: [data.getY(index: 50), data.getY(index: 58), data.getY(index: 51), data.getY(index: 57), data.getY(index: 52), data.getY(index: 56)])
        
        let lipTightenerValue = lipCornerPullerValue
        
        let jawDropValue = jawDrop(param: [data.getY(index: 33), data.getY(index: 8)])
        
        let features = [outerBrowRaiserValue, browLowererValue, upperLidRaiserValue, cheekRaiserValue, lidTightenerValue, noseWrinklerValue, lipCornerPullerValue, dimplerValue, lipCornerDepresserValue, lowerLipDepresserValue, lipStretcherValue, lipTightenerValue, jawDropValue]
        
        return features
    }
    
    private class func outerBrowRaiser(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = [rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]].average
        let left = [leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]].average
        return [right, left].average
    }
    
    private class func browLowerer(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = [rightParam[1] - rightParam[0], rightParam[3] - rightParam[2], rightParam[5] - rightParam[4]].average
        let left = [leftParam[1] - leftParam[0], leftParam[3] - leftParam[2], leftParam[5] - leftParam[4]].average
        return [right, left].average
    }
    
    private class func upperLidRaiser(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = [rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]].average
        let left = [leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]].average
        return [right, left].average
    }
    
    private class func cheekRaiser(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = rightParam[1] - rightParam[0]
        let left = leftParam[1] - leftParam[0]
        return [right, left].average
    }
    
    private class func lidTightener(right rightParam: [Double], left leftParam: [Double]) -> Double {
//        combines with browLowerer value
        let right = [rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]].average
        let left = [leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]].average
        return [right, left].average
    }

    private class func noseWrinkler(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = rightParam[1] - rightParam[0]
        let left = leftParam[1] - leftParam[0]
        return [right, left].average
    }

    private class func lipCornerPuller(right rightParam: Double, left leftParam: Double) -> Double {
        return abs(rightParam - leftParam)
    }

    private class func dimpler(right rightParam: [Double], left leftParam: [Double]) -> Double {
        let right = rightParam[1] - rightParam[0]
        let left = leftParam[1] - leftParam[0]
        return abs(right - left)
    }
    
    private class func lipCornerDepresser(right rightParam: Double, left leftParam: Double, middle middleParam: [Double]) -> Double {
        let right = rightParam - middleParam[0]
        let left = leftParam - middleParam[0]
        let middle = middleParam[1] - middleParam[0]
        let avg = [right, left].average
        return middle - avg // max for normal
    }

    private class func lowerLipDepresser(param: [Double]) -> Double {
        return [param[1] - param[0], param[3] - param[2], param[5] - param[4]].average
    }
    
    private class func lipStretcher(param: [Double]) -> Double {
        return [param[1] - param[0], param[3] - param[2], param[5] - param[4]].average
    }

    private class func jawDrop(param: [Double]) -> Double {
        return param[1] - param[0]
    }
}


extension Array where Element: FloatingPoint {
    
    var total: Element { return reduce(0, +) }
    
    var average: Element {
        return isEmpty ? 0 : total / Element(count)
    }
}

extension NSMutableArray {
    func getX(index: Int) -> Double {
        return Double((self[index] as! CGPoint).x)
    }
    
    func getY(index: Int) -> Double {
        return Double((self[index] as! CGPoint).y)
    }
}


