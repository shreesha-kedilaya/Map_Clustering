# -*- coding: utf-8 -*-
"""
Spyder Editor

This is a temporary script file.
"""

import numpy as np
import cv2
import dlib
import glob

import FeaturesCompute as fc

myFolderPath = '../dataset/'

faceCascade = cv2.CascadeClassifier('../haarcascade_frontalface_alt.xml')
predictor = dlib.shape_predictor('../shape_predictor_68_face_landmarks.dat')
        
for folderName in glob.glob(myFolderPath + '*', recursive=True):
    
    emotionType = folderName.split(myFolderPath)[1]
    print(emotionType)
    
    for index, imageFileName in enumerate(glob.glob(folderName + '/*.JPG', recursive=True)):
        imageName = imageFileName.split(folderName + '/')[1]
        print(imageName)

        rect = [0,0,0,0]
        img = cv2.imread(imageFileName)
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

            dlibRect = dlib.rectangle(int(0), int(0), int(256), int(256))
            # [x,y,w,h]

            landmarks = np.matrix([[p.x, p.y] for p in predictor(cropImgResize, dlibRect).parts()])
        
            featureParams = fc.calculateFeatures(landmarks)
            fc.saveToCsvFile(featureParams, emotionType, index)
            
            for idx, point in enumerate(landmarks):
                pos = (point[0,0], point[0,1])
                cv2.putText(cropImgResize, str(idx+1), pos, fontFace = cv2.FONT_HERSHEY_SCRIPT_SIMPLEX, 
                    fontScale = 0.5, color=(0,0,255))
                cv2.circle(cropImgResize, pos, 2, color=(0,255,255), thickness=-1)
        
#            cv2.imwrite(folderName + '/croppedImages/crop_' + str(imageName), cropImgResize)
        
        else:
            print('face not detected')   


    
cv2.waitKey(3)
cv2.destroyAllWindows()