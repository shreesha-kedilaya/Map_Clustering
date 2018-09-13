import numpy as np
import matplotlib.pyplot as plt
import pandas as pd
import cv2
import glob
import os

#detct face in image

trainFolderPath = 'dataset/train/'
testFolderPath = 'dataset/test/'

faceCascade = cv2.CascadeClassifier( 'haarcascade_frontalface_alt.xml')
        
for folderName in glob.glob(trainFolderPath + '*', recursive=True):
    
    emotionType = folderName.split(trainFolderPath)[1]
    
    print(emotionType)
    for index, imageFileName in enumerate(glob.glob(folderName + '/*.JPG', recursive=True)):
        imageName = imageFileName.split(folderName + '/')[1]

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
            
            dirname = 'imagesTrain/' + emotionType
            if not os.path.exists(dirname):
                os.mkdir(dirname)
                
            cv2.imwrite('imagesTrain/' + emotionType + '/' + imageName + '.jpg', cropImgResize)
                        
        else : 
            
            dirname = 'imagesTrain/' + emotionType
            if not os.path.exists(dirname):
                os.mkdir(dirname)
                
            cv2.imwrite('imagesTrain/' + emotionType + '/' + imageName + '.jpg', grayImg)
            print('faces not detected')
            
            
            
#Test
            
for folderName in glob.glob(testFolderPath + '*', recursive=True):
    
    emotionType = folderName.split(testFolderPath)[1]
    
    print(emotionType)
    for index, imageFileName in enumerate(glob.glob(folderName + '/*.JPG', recursive=True)):
        imageName = imageFileName.split(folderName + '/')[1]

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
            
            dirname = 'imagesTest/' + emotionType
            if not os.path.exists(dirname):
                os.mkdir(dirname)
                
            print(emotionType)
                
            cv2.imwrite('imagesTest/' + emotionType + '/' + imageName + '.jpg', cropImgResize)
                        
        else : 
            
            dirname = 'imagesTest/' + emotionType
            if not os.path.exists(dirname):
                os.mkdir(dirname)
                
            cv2.imwrite('imagesTest/' + emotionType + '/' + imageName + '.jpg', grayImg)
            print('faces not detected')
            
            
from keras.models import Sequential
from keras.layers import Conv2D
from keras.layers import MaxPooling2D
from keras.layers import Flatten
from keras.layers import Dense
from keras.callbacks import TensorBoard
from keras.preprocessing import image

#Initializing the CNN.

classifier = Sequential()

# Step - 1 - Convolution

classifier.add(Conv2D(32, (3, 3), input_shape = (100,100,3), activation = "relu"))

# Step - 2 Pooling

classifier.add(MaxPooling2D(pool_size = (2,2)))

# Step - 3 Flattening
classifier.add(Flatten())

# Full Connection - ANN
classifier.add(Dense(units = 128, activation = 'relu'))
classifier.add(Dense(units= 8, activation = 'softmax'))

#Compiling

classifier.compile(optimizer = 'adam', loss = 'categorical_crossentropy', metrics = ['accuracy'])


#Image preprocessing
from keras.preprocessing.image import ImageDataGenerator

train_datagen = ImageDataGenerator(rescale = 1./255,
                                   shear_range = 0.4,
                                   zoom_range = 0.6,
                                   rotation_range = 1,
                                   horizontal_flip = True)

test_datagen = ImageDataGenerator(rescale = 1./255)

training_set = train_datagen.flow_from_directory('imagesTrain',
                                                 target_size = (100, 100),
                                                 batch_size = 32,
                                                 class_mode = 'categorical')


test_set = test_datagen.flow_from_directory('imagesTest',
                                            target_size = (100, 100),
                                            batch_size = 32,
                                            class_mode = 'categorical')

logger = TensorBoard(
    log_dir='logs',
    write_graph=True,
)


history = classifier.fit_generator(training_set,
                        steps_per_epoch = 40,
                         epochs = 40,
                         validation_data = test_set,
                         validation_steps = 10, 
                         callbacks = [logger])

classifier.save('classifier_softmax.h5')

classifier.evaluate()

#from keras.utils import plot_model
#
import matplotlib.pyplot as plt


plt.plot(history.history['acc'])
plt.plot(history.history['val_acc'])
plt.title('model accuracy')
plt.ylabel('accuracy')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()
# summarize history for loss
plt.plot(history.history['loss'])
plt.plot(history.history['val_loss'])
plt.title('model loss')
plt.ylabel('loss')
plt.xlabel('epoch')
plt.legend(['train', 'test'], loc='upper left')
plt.show()



#img_path = 'cat1.jpg'
#img = image.load_img(img_path, target_size=(, 64))
#x = image.img_to_array(img)
#x = np.expand_dims(x, axis=0)
#prediction = classifier.predict(x)
#print('prediction: {}'.format(prediction))