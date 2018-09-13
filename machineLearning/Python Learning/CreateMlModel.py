#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 17:11:49 2017

@author: dimple
"""

import coremltools
from sklearn import svm
import pandas

data = pandas.read_csv('../allFeatures.csv')

y = []
for emotion in data['emotions']:
    if emotion == 'Neutral':
        y.append(0)
    elif emotion == 'Happiness':
        y.append(1)
    elif emotion == 'Sadness':
        y.append(2)
    elif emotion == 'Anger':
        y.append(3)
    elif emotion == 'Fear':
        y.append(4)
    elif emotion == 'Surprise':
        y.append(5)
    elif emotion == 'Disgust':
        y.append(6)
    elif emotion == 'Contempt':
        y.append(7)
    else:
        y.append(8)
       
print(y)

X = data[['outerBrowRaiser', 'browLowerer', 'upperLidRaiser', 'cheekRaiser', 'lidTightener', 
               'NoseWrinkler', 'lipCornerPuller', 'dimpler', 'lipCornerDeppresser', 'lowerLipDeppresser',
               'lipStretcher','lipTightener', 'jawDrop']].values
          
model = svm.LinearSVC(C = 1.0)
model.fit(X, y)

coreml_model = coremltools.converters.sklearn.convert(model, ['outerBrowRaiser', 'browLowerer', 'upperLidRaiser', 'cheekRaiser', 'lidTightener', 
               'NoseWrinkler', 'lipCornerPuller', 'dimpler', 'lipCornerDeppresser', 'lowerLipDeppresser',
               'lipStretcher','lipTightener', 'jawDrop'], "emotions")

# Set model metadata
coreml_model.author = 'YML'
coreml_model.license = 'BSD'
coreml_model.short_description = 'Predicts facial expressions'

#set the input description 
coreml_model.input_description['outerBrowRaiser'] = 'distance between brow and eyelid'
coreml_model.input_description['browLowerer'] = 'distance between lower brow and eyelid'
coreml_model.input_description['upperLidRaiser'] = 'distance between eyelids'
coreml_model.input_description['cheekRaiser'] = 'distance between lip and eye'
coreml_model.input_description['lidTightener'] = 'distance between eyelid'
coreml_model.input_description['NoseWrinkler'] = 'distance between brow and eyelids'
coreml_model.input_description['lipCornerPuller'] = 'distance between lip croners'
coreml_model.input_description['dimpler'] = 'difference in distance between cheek eyelid'
coreml_model.input_description['lipCornerDeppresser'] = 'distance between lip and jaw'
coreml_model.input_description['lowerLipDeppresser'] = 'distance between lip and jaw'
coreml_model.input_description['lipStretcher'] = 'distance between lip corners'
coreml_model.input_description['lipTightener'] = 'distance between lip corners'
coreml_model.input_description['jawDrop'] = 'distance between lower lip and jaw'


# Set the output descriptions
coreml_model.output_description['emotions'] = 'Predicted emotion'

# Save the model
coreml_model.save('../FacialEmotionsLinearSVM.mlmodel')
print('ml model created')