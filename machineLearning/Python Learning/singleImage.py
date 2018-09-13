#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Thu Nov 23 17:11:49 2017

@author: dimple
"""

import numpy as np
import cv2
import dlib
import FeaturesCompute as fc
import plotFeatures as pf

rect = [0,0,0,0]

faceCascade = cv2.CascadeClassifier( 'haarcascade_frontalface_alt.xml')
#predictor = dlib.shape_predictor( '../shape_predictor_68_face_landmarks.dat')

imageFileName = '17.jpg'

img = cv2.imread(imageFileName)
imageName = '17'
print(imageName)
grayImg = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)

    #detct face in image
faces = faceCascade.detectMultiScale(grayImg, 1.3, 5)

for (x,y,w,h) in faces:
    img = cv2.rectangle(img, (x,y), (x+w, y+h), (0, 255, 0), 1)
    rect = [x,y,x+w,y+h]
    roiGray = grayImg[y:y+h, x:x+w]
    roiColor = img[y:y+h, x:x+w]    

    
if len(faces) > 0:
        
    cropImg = img[rect[1]:rect[3], rect[0]:rect[2]] #crop [y:h, x:w]
    cropImgResize = cv2.resize(cropImg, (256,256))

#    dlibRect = dlib.rectangle(int(0), int(0), int(256), int(256))
#    # [x,y,w,h]
#
#    landmarks = np.matrix([[p.x, p.y] for p in predictor(cropImgResize, dlibRect).parts()])
#    featureParams = fc.calculateFeatures(landmarks)
#    print(featureParams)
#    pf.predictEmotions(featureParams)
#    
##detct face in cropped image
##faces = faceCascade.detectMultiScale(cropImgResize, 1.3, 5)
##print('second face', faces)
##
##for (x,y,w,h) in faces:
##     cropImgResize = cv2.rectangle(cropImgResize, (x,y), (x+w, y+h), (255, 0, 0), 2)
##     rect = [x,y,x+w,y+h]
##     roiGray = grayImg[y:y+h, x:x+w]
##     roiColor = img[y:y+h, x:x+w]    
#   
#    for idx, point in enumerate(landmarks):
#     pos = (point[0,0], point[0,1])
#     cv2.putText(cropImgResize, str(idx+1), pos, fontFace = cv2.FONT_HERSHEY_SCRIPT_SIMPLEX, 
#                    fontScale = 0.5, color=(0,0,255))
#     cv2.circle(cropImgResize, pos, 2, color=(0,255,255), thickness=-1)
# 
else:
    print('face not detected')           
cv2.imwrite( 'CroppedImage.jpg', cropImgResize)

##
cv2.imshow('Landmarks', cropImgResize)
cv2.waitKey(3)
cv2.destroyAllWindows()
