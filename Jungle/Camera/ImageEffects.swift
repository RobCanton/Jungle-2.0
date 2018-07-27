//
//  ImageEffects.swift
//  MagicVideo
//
//  Created by jaba odishelashvili on 3/16/18.
//  Copyright © 2018 Jabson. All rights reserved.
//

import UIKit


extension CIImage {
    
    
    func applyEffect(_ name:String, _ intensity:Float?) -> CIImage? {
        switch name {
        case "CIColorPosterize":
            return colorPosterize()
        case "CIConvolution3X3":
            return convolution3v3(intensity)
        case "CIConvolution5X5":
            return convolution5v5()
        case "CIConvolution7X7":
            return convolution7v7()
        case "CIConvolution9Horizontal":
            return convolution9Horizontal(intensity)
        case "CIPhotoEffectTransfer":
            return transferEffect()
        case "CIPhotoEffectProcess":
            return processEffect()
        case "CIPhotoEffectChrome":
            return chromeEffect()
        case "CIPhotoEffectFade":
            return fadeEffect()
        case "CIPhotoEffectNoir":
            return noirEffect()
        case "CIKaleidoscope":
            return kaleidoscopeEffect()
        case "CIColorInvert":
            return invertColorEffect()
        case "CIVignetteEffect":
            return vignetteEffect(intensity)
        case "CIPhotoEffectInstant":
            return photoInstantEffect()
        case "CICrystallize":
            return crystallizeEffect()
        case "CIComicEffect":
            return comicEffect()
        case "CIBloom":
            return bloomEffect(intensity)
        case "CIEdges":
            return edgesEffect(intensity)
        case "CIEdgeWork":
            return edgeWorkEffect()
        case "CIGloom":
            return gloomEffect(intensity)
        case "CIHighlightShadowAdjust":
            return highlightShadowAdjust(intensity)
        case "CIPixellate":
            return pixellateEffect(intensity)
        default:
            return nil
        }
    }
    
    func noneEffect() -> CIImage? {
        return self
    }
    
    func invertColorEffect() -> CIImage? {
        guard let colorInvert = CIFilter(name: "CIColorInvert") else {
            return nil
        }
        colorInvert.setValue(self, forKey: kCIInputImageKey)
        return colorInvert.outputImage
    }
    
    
    
    func vignetteEffect(_ intensity:Float?=nil) -> CIImage? {
        guard let vignetteFilter = CIFilter(name: "CIVignetteEffect") else {
            return nil
        }
        let i = intensity ?? 0
        vignetteFilter.setValue(self, forKey: kCIInputImageKey)
        let center = CIVector(x: self.extent.size.width/2, y: self.extent.size.height/2)
        vignetteFilter.setValue(center, forKey: kCIInputCenterKey)
        vignetteFilter.setValue(self.extent.size.height/2, forKey: kCIInputRadiusKey)
        vignetteFilter.setValue(i, forKey: kCIInputIntensityKey)
        return vignetteFilter.outputImage
    }
    
    func photoInstantEffect() -> CIImage? {
        guard let photoEffectInstant = CIFilter(name: "CIPhotoEffectInstant") else {
            return nil
        }
        photoEffectInstant.setValue(self, forKey: kCIInputImageKey)
        return photoEffectInstant.outputImage
    }
    
    func noirEffect() -> CIImage? {
        guard let noirEffect = CIFilter(name: "CIPhotoEffectNoir") else {
            return nil
        }
        noirEffect.setValue(self, forKey: kCIInputImageKey)
        return noirEffect.outputImage
    }
    
    func processEffect() -> CIImage? {
        guard let effect = CIFilter(name: "CIPhotoEffectProcess") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func transferEffect() -> CIImage? {
        guard let effect = CIFilter(name: "CIPhotoEffectTransfer") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func chromeEffect() -> CIImage? {
        guard let effect = CIFilter(name: "CIPhotoEffectChrome") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func fadeEffect() -> CIImage? {
        guard let effect = CIFilter(name: "CIPhotoEffectFade") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func colorPosterize() -> CIImage? {
        guard let effect = CIFilter(name: "CIColorPosterize") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func kaleidoscopeEffect() -> CIImage? {
        guard let effect = CIFilter(name: "CIKaleidoscope") else {
            return nil
        }
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func convolution3v3(_ intensity:Float?=nil) -> CIImage? {
        guard let effect = CIFilter(name: "CIConvolution3X3") else {
            return nil
        }
        let i = intensity ?? 0
        let v = CGFloat(20 * i)
        let floatArr: [CGFloat] = [0,-v,0,-v,v * 4 + 1,-v,0,-v,0]
        let vector = CIVector(values: floatArr, count: floatArr.count)
        effect.setValue(vector, forKey: kCIInputWeightsKey)
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func convolution5v5() -> CIImage? {
        guard let effect = CIFilter(name: "CIConvolution5X5") else {
            return nil
        }
        let floatArr: [CGFloat] = [10,0,0,0,0,
                                   0,0,0,0,0,
                                   0,0,-19,0,0,
                                   0,0,0,0,0,
                                   0,0,0,0,10]
        let vector = CIVector(values: floatArr, count: floatArr.count)
        effect.setValue(vector, forKey: kCIInputWeightsKey)
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func convolution7v7() -> CIImage? {
        guard let effect = CIFilter(name: "CIConvolution7X7") else {
            return nil
        }
        let floatArr: [CGFloat] = [0,0,-1,-1,-1,0,0,
                                   0,-1,-3,-3,-3,-1,0,
                                   -1,-3,0,7,0,-3,-1,
                                   -1,-3,7,25,7,-3,-1,
                                   -1,-3,0,7,0,-3,-1,
                                   0,-1,-3,-3,-3,-1,0,
                                   0,0,-1,-1,-1,0,0]
        let vector = CIVector(values: floatArr, count: floatArr.count)
        effect.setValue(vector, forKey: kCIInputWeightsKey)
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func convolution9Horizontal(_ intensity:Float?=nil) -> CIImage? {
        guard let effect = CIFilter(name: "CIConvolution9Horizontal") else {
            return nil
        }
        let i = intensity ?? 0
        let val = CGFloat(10 * i)
        let floatArr: [CGFloat] = [val,-val,val,0,1, 0, -val, val, -val]
        let vector = CIVector(values: floatArr, count: floatArr.count)
        effect.setValue(vector, forKey: kCIInputWeightsKey)
        effect.setValue(self, forKey: kCIInputImageKey)
        return effect.outputImage
    }
    
    func crystallizeEffect() -> CIImage? {
        guard let crystallize = CIFilter(name: "CICrystallize") else {
            return nil
        }
        crystallize.setValue(self, forKey: kCIInputImageKey)
        let center = CIVector(x: self.extent.size.width/2, y: self.extent.size.height/2)
        crystallize.setValue(center, forKey: kCIInputCenterKey)
        crystallize.setValue(15, forKey: kCIInputRadiusKey)
        
        return crystallize.outputImage
    }
    
    func comicEffect() -> CIImage? {
        guard let comicEffect = CIFilter(name: "CIComicEffect") else {
            return nil
        }
        comicEffect.setValue(self, forKey: kCIInputImageKey)
        return comicEffect.outputImage
    }
    
    func bloomEffect(_ intensity:Float?=nil) -> CIImage? {
        guard let bloom = CIFilter(name: "CIBloom") else {
            return nil
        }
        let i = intensity ?? 0
        bloom.setValue(self, forKey: kCIInputImageKey)
        bloom.setValue(5 + 10 * i, forKey: kCIInputRadiusKey)
        bloom.setValue(i, forKey: kCIInputIntensityKey)
        
        return bloom.outputImage
    }
    
    
    
    func edgesEffect(_ intensity:Float?=nil) -> CIImage? {
        guard let edges = CIFilter(name: "CIEdges") else {
            return nil
        }
        let i = intensity ?? 0
        edges.setValue(self, forKey: kCIInputImageKey)
        edges.setValue(i, forKey: kCIInputIntensityKey)
        
        return edges.outputImage
    }
    
    func edgeWorkEffect() -> CIImage? {
        guard let edgeWork = CIFilter(name: "CIEdgeWork") else {
            return nil
        }
        edgeWork.setValue(self, forKey: kCIInputImageKey)
        edgeWork.setValue(1, forKey: kCIInputRadiusKey)
        
        return edgeWork.outputImage
    }
    
    func gloomEffect(_ intensity:Float?=nil) -> CIImage? {
        guard let gloom = CIFilter(name: "CIGloom") else {
            return nil
        }
        let i = intensity ?? 0
        gloom.setValue(self, forKey: kCIInputImageKey)
        //gloom.setValue(self.extent.size.height/2, forKey: kCIInputRadiusKey)
        gloom.setValue(i, forKey: kCIInputIntensityKey)
        
        return gloom.outputImage
    }
    
    func hexagonalPixellateEffect() -> CIImage? {
        guard let hexagonalPixellate = CIFilter(name: "CIHexagonalPixellate") else {
            return nil
        }
        hexagonalPixellate.setValue(self, forKey: kCIInputImageKey)
        let center = CIVector(x: self.extent.size.width/2, y: self.extent.size.height/2)
        hexagonalPixellate.setValue(center, forKey: kCIInputCenterKey)
        hexagonalPixellate.setValue(8, forKey: kCIInputScaleKey)
        
        return hexagonalPixellate.outputImage
    }
    
    func highlightShadowAdjust(_ intensity:Float?=nil) -> CIImage? {
        guard let highlightShadowAdjust = CIFilter(name: "CIHighlightShadowAdjust") else {
            return nil
        }
        let i = intensity ?? 0
        highlightShadowAdjust.setValue(self, forKey: kCIInputImageKey)
        highlightShadowAdjust.setValue(i, forKey: Constants.CIEffectKeys.InputHighlightAmount)
        highlightShadowAdjust.setValue(i, forKey: Constants.CIEffectKeys.InputShadowAmount)
        
        return highlightShadowAdjust.outputImage
    }
    
    func pixellateEffect(_ intensity:Float?=nil) -> CIImage? {
        guard let pixellate = CIFilter(name: "CIPixellate") else {
            return nil
        }
        let i = intensity ?? 0
        pixellate.setValue(self, forKey: kCIInputImageKey)
        //let center = CIVector(x: self.extent.size.width/2, y: self.extent.size.height/2)
        //pixellate.setValue(center, forKey: kCIInputCenterKey)
        
        let f = Float(Int(50 * i))
        pixellate.setValue(f, forKey: kCIInputScaleKey)
        
        return pixellate.outputImage
    }
    
    func pointillizeEffect() -> CIImage? {
        guard let pointillize = CIFilter(name: "CIPointillize") else {
            return nil
        }
        pointillize.setValue(self, forKey: kCIInputImageKey)
        let center = CIVector(x: self.extent.size.width/2, y: self.extent.size.height/2)
        pointillize.setValue(center, forKey: kCIInputCenterKey)
        pointillize.setValue(10, forKey: kCIInputRadiusKey)
        
        return pointillize.outputImage
    }
}
