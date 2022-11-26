%%%%%%%%%%% LIVER DISEASE DETECTION %%%%%%%%%%%

clc;

clear;

close all;

warning off


%%%%% TRAINING THE DATASET %%%%%
  
matlabroot='C:\Users\HP\Desktop\FYP\Liver Disease'
data1 = fullfile(matlabroot,'TRAINING IMAGES');
Data=imageDatastore(data1,'IncludeSubfolders',true,'LabelSource','foldernames');

augmenter = imageDataAugmenter( ...
    'RandRotation',[0 360], ...
    'RandScale',[0.5 1], ...
    'RandXTranslation', [-5,-5], ...
    'RandYTranslation', [-5,-5]);
imageSize = [227 227 3];
auimds = augmentedImageDatastore(imageSize,Data,'DataAugmentation',augmenter);


validationPath = fullfile(matlabroot,'TESTING IMAGES');
imdsValidation = imageDatastore(validationPath, ...    
'IncludeSubfolders',true,'LabelSource','foldernames');

%%%%%%% CREATING CONVOLUTIONAL NEURAL NETWORK LAYERS %%%%%%


 layers=[imageInputLayer([227 227 3])               
    
    convolution2dLayer(3,8,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,16,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,32,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,64,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)
    
    convolution2dLayer(3,128,'Padding','same')
    batchNormalizationLayer
    reluLayer
    
    maxPooling2dLayer(2,'Stride',2)    
    
    fullyConnectedLayer(2)
    softmaxLayer
    classificationLayer];

options=trainingOptions('sgdm','MaxEpochs',250,'InitialLearnRate',0.01,'Shuffle','every-epoch', ...    
    'ValidationData',imdsValidation, ...        
    'ValidationFrequency',30,...        
    'Verbose',false, ...        
    'Plots','training-progress');

 convnet=trainNetwork(auimds,layers,options);

 save convnet.mat convnet


%%%%% CLASSIFYING VALIDATION IMAGES AND COMPUTING ACCURACY %%%%%

YPred = classify(convnet,imdsValidation);

YValidation = imdsValidation.Labels;

accuracy = sum(YPred == YValidation)/numel(YValidation); 

%%%Recall%%%
sum_of_columns = sum(cmt,1);
recall = diagonal ./ sum_of_columns';
overall_recall = mean(recall);
disp('Recall:');
disp(overall_recall);
 
%%%Precision%%%
cm = confusionmat(YValidation, YPred);
cmt = cm';
diagonal = diag(cmt);
sum_of_rows = sum(cmt,2);
precision = diagonal ./ sum_of_rows;
overall_precision = mean(precision);
disp('Precision:');
disp(overall_precision);
 
%%%F1-Score%%%
% f1_score = ((2*(precision * recall)) / (precision + recall));
% disp('F1 Score:');
% disp(f1_score);
 
%%%Accuracy%%%
% d = diag(cm);
% accuracy = 100*((sum(d)) ./ sum(cm));
% disp('Accuracy:');
% disp(accuracy);

%%%Confusion Matrix%%%
plotconfusion(YValidation,YPred);

% %%%%%%%%%%% READING THE IMAGES FROM THE DATASET %%%%%%%%%%%

 load convnet.mat
[filename,pathname]=uigetfile('*.*'); 
im1=imread([pathname,filename]);
figure,imshow(im1),title('INPUT IMAGE');

  %%%%%% RESIZING THE IMAGES %%%%%%%%%%

im=imresize(im1,[227 227]);
figure,imshow(im),title('Resized image');

  %%%%%%%%%%% CONVERTING THE DATA TYPE INTO UNSIGNED INTEGER %%%%%%%%%%%
  
 re=im2uint8(im);

  %%% CLASSIFYING THE OUTPUT %%%%%%% 

output=classify(convnet,re);
tf1=[];

for ii=1:2
    st=int2str(ii)
    tf=ismember(output,st);
    tf1=[tf1 tf];
end

output1=find(tf1==1);

if output1==1
     
    msgbox('Healthy Liver Detected')
    
elseif output1==2
     
    msgbox('Liver Disease Detected')

    

end

   %%%%% HARDWARE IMPLEMENTATION %%%%%%%%
instrumentObjects=instrfind;  % don't pass it anything - find all of them.
delete(instrumentObjects)
a=serial('COM3','BaudRate',9600);
fopen(a);
    if output1==1
        fprintf(a, '%c', 'A'); 
    elseif output1==2
        fprintf(a, '%c', 'B');   
    end
      fclose(a); 
      



      
      
