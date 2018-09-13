#!/usr/bin/env python3
# -*- coding: utf-8 -*-
"""
Created on Mon Nov 27 18:01:37 2017

@author: dimple
"""

import numpy as np
import pandas as pd
import glob
import matplotlib.pyplot as plot
from matplotlib import style
style.use('ggplot')
from sklearn import svm

myFolderPath = '../csv/'

features = ['outerBrowRaiser', 'browLowerer', 'upperLidRaiser', 'cheekRaiser', 'lidTightener', 
               'NoseWrinkler', 'lipCornerPuller', 'dimpler', 'lipCornerDeppresser', 'lowerLipDeppresser',
               'lipStretcher','lipTightener', 'jawDrop', 'emotions']

csvAllData = []
for folderName in glob.glob(myFolderPath + '*', recursive=True):    
    
    csvData = pd.read_csv(folderName)
    csvAllData.append(csvData[features]) 
    
data = pd.concat(csvAllData)
data.to_csv('../csv/allFeatures.csv')

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

C = 1.0  # SVM regularization parameter
 
# SVC with linear kernel
svc = svm.SVC(kernel = 'linear', C = C).fit(X, y)
# LinearSVC (linear kernel)
lin_svc = svm.LinearSVC(C = C).fit(X, y)
# SVC with RBF kernel
rbf_svc = svm.SVC(kernel = 'rbf', gamma = 0.01, C = C).fit(X, y)
# SVC with polynomial (degree 3) kernel
poly_svc = svm.SVC(kernel = 'poly', degree = 3, C = C).fit(X, y)

#h = .02  # step size in the mesh
# 
## create a mesh to plot in
#xMin, xMax = X[:, 0].min() - 1, X[:, 0].max() + 1
#yMin, yMax = X[:, 0].min() - 1, X[:, 0].max() + 1
#
#xx, yy = np.meshgrid(np.arange(xMin, xMax, h),np.arange(yMin, yMax, h))
#	                    
## title for the plots
#titles = ['SVC with linear kernel',
#	    'LinearSVC (linear kernel)',
#	    'SVC with RBF kernel',
#	    'SVC with poly(deg 5) kernel']
# 
# 
#for i, clf in enumerate((svc, lin_svc, rbf_svc, poly_svc)):
#	 # Plot the decision boundary. For that, we will assign a color to each
#	 # point in the mesh [x_min, x_max]x[y_min, y_max].
#	 plot.subplot(2, 2, i + 1)
#	 plot.subplots_adjust(wspace=0.4, hspace=0.4)
# 
#	 Z = clf.predict(np.c_[xx.ravel(), yy.ravel()])
# 
#	 # Put the result into a color plot
#	 Z = Z.reshape(xx.shape)
#	 plot.contourf(xx, yy, Z, cmap=plot.cm.coolwarm, alpha=0.8)
# 
#	 # Plot also the training points
#	 plot.scatter(X[:, 0], X[:, 1], c=y, cmap=plot.cm.coolwarm)
#	 plot.xlabel('x')
#	 plot.ylabel('y')
#	 plot.xlim(xx.min(), xx.max())
#	 plot.ylim(yy.min(), yy.max())
#	 plot.xticks(())
#	 plot.yticks(())
#	 plot.title(titles[i])
# 
#plot.legend()
#plot.show()

def predictEmotions(data) :
    print('svc  -- ' + f(svc.predict([data])[0]))
    print('linear svc -- ' + f(lin_svc.predict([data])[0]))
    print('rbf svc -- ' + f(rbf_svc.predict([data])[0]))
    print('poly -- ' + f(poly_svc.predict([data])[0]))

def f(x):
    return {
        0 : 'Neutral',
        1 : 'Happy',
        2 : 'Sad',
        3 : 'Anger',
        4 : 'Fear',
        5 : 'Surprise',
        6 : 'Disgust',
        7 : 'Contempt',
    }[x]
    

