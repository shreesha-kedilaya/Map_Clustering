#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 17:55:56 2017

@author: dimple
"""

import numpy as np
import pandas as pd

featureTypes = ['outerBrowRaiser', 'browLowerer', 'upperLidRaiser', 'cheekRaiser', 'lidTightener', 
               'NoseWrinkler', 'lipCornerPuller', 'dimpler', 'lipCornerDeppresser', 'lowerLipDeppresser',
               'lipStretcher','lipTightener', 'jawDrop']

def calculateFeatures(data):
    outerBrowRaiserValue = outerBrowRaiser([data[17,1], data[36,1], data[18,1], data[36,1]], 
                                           [data[26,1], data[45,1], data[25,1], data[45,1]])
#    print(outerBrowRaiserValue)
    global count 
    
    browLowererValue = browLowerer([data[21,1], data[39,1], data[20,1], data[38,1], data[19,1], data[37,1]], 
                                           [data[22,1], data[42,1], data[23,1], data[43,1], data[24,1], data[44,1]])
    
    
    upperLidRaiserValue = upperLidRaiser([data[37,1], data[41,1], data[38,1], data[40,1]], 
                                    [data[43,1], data[47,1], data[44,1], data[46,1]])
    
        
    cheekRaiserValue = cheekRaiser([data[40,1], data[48,1]], [data[47,1], data[54,1]])
    
    lidTightenerValue = lidTightener([data[37,1], data[41,1], data[38,1], data[40,1]], 
                                     [data[43,1], data[47,1], data[44,1], data[46,1]])
    
    noseWrinklerValue = noseWrinkler([data[39,1], data[31,1]], [data[42,1], data[35,1]])
    
    lipCornerPullerValue = lipCornerPuller(data[48,0], data[54,0])
    
    dimplerValue = dimpler([data[40,1], data[48,1]], [data[47,1], data[54,1]])
    
    lipCornerDeppresserValue = lipCornerDepresser(data[48,1], data[54,1], [data[8,1], data[57,1]])
    
    lowerLipDepresserValue = lowerLipDepresser([data[50,1], data[58,1], data[51,1], data[57,1], data[52,1], data[56,1]])
    
    lipStretcherValue = lipStretcher([data[50,1], data[58,1], data[51,1], data[57,1], data[52,1], data[56,1]])
    
    lipTightener = lipCornerPuller(data[48,0], data[54,0])
    
    jawDropValue = jawDrop([data[33,1], data[8,1]])
    
    params = [round(outerBrowRaiserValue, 2), round(browLowererValue, 2), round(upperLidRaiserValue, 2), round(cheekRaiserValue, 2), 
              round(lidTightenerValue, 2), round(noseWrinklerValue, 2), round(lipCornerPullerValue, 2), round(dimplerValue, 2), 
              round(lipCornerDeppresserValue, 2), round(lowerLipDepresserValue, 2), round(lipStretcherValue, 2),
              round(lipTightener, 2), round(jawDropValue, 2)]
            
    return params

def saveToCsvFile(params, emotionType, index):
    params.append(emotionType)
    data = pd.DataFrame([params], index = [index], columns = ['outerBrowRaiser', 'browLowerer', 'upperLidRaiser', 'cheekRaiser', 'lidTightener', 
               'NoseWrinkler', 'lipCornerPuller', 'dimpler', 'lipCornerDeppresser', 'lowerLipDeppresser',
               'lipStretcher','lipTightener', 'jawDrop', 'emotions'])
    
    if index == 0:
        data.to_csv('../csv/'+ emotionType + 'Features.csv')
    else:    
        with open('../csv/'+ emotionType + 'Features.csv', 'a') as f:
             (data).to_csv(f, header=False)
             
    return

#1
def outerBrowRaiser(rightParam, leftParam):
    right = np.mean([rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]])
    left = np.mean([leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]])
    return np.mean([right, left])

#2
def browLowerer(rightParam, leftParam):
    right = np.mean([rightParam[1] - rightParam[0], rightParam[3] - rightParam[2], rightParam[5] - rightParam[4]])
    left = np.mean([leftParam[1] - leftParam[0], leftParam[3] - leftParam[2], leftParam[5] - leftParam[4]])
    return np.mean([right, left])

#3
def upperLidRaiser(rightParam, leftParam):
    right = np.mean([rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]])
    left = np.mean([leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]])
    return np.mean([right, left])

#4
def cheekRaiser(rightParam, leftParam):
    right = rightParam[1] - rightParam[0]
    left = leftParam[1] - leftParam[0]
    return np.mean([right, left])

#5
def lidTightener(rightParam, leftParam): #height of eye
    #combines with browLowerer value
    right = np.mean([rightParam[1] - rightParam[0], rightParam[3] - rightParam[2]])
    left = np.mean([leftParam[1] - leftParam[0], leftParam[3] - leftParam[2]])
    return np.mean([right, left])

#6
def noseWrinkler(rightParam, leftParam):
    right = rightParam[1] - rightParam[0]
    left = leftParam[1] - leftParam[0]
    return np.mean([right, left])

#7
def lipCornerPuller(rightParam, leftParam):
    return np.abs(rightParam - leftParam)

#8
def dimpler(rightParam, leftParam):
    right = rightParam[1] - rightParam[0]
    left = leftParam[1] - leftParam[0]
    return np.abs(right - left)

#9
def lipCornerDepresser(rightParam, leftParam, middleParam):
    middle = middleParam[1] - middleParam[0]
    right = rightParam - middleParam[0]
    left = leftParam - middleParam[0]
    mean = np.mean([right, left])
    return middle - mean # max for normal

#10
def lowerLipDepresser(param):
    return np.mean([param[1] - param[0], param[3] - param[2], param[5] - param[4]])

#11
def lipStretcher(param):    
    return np.mean([param[1] - param[0], param[3] - param[2], param[5] - param[4]])

#13
def jawDrop(param):    
    return param[1] - param[0]

