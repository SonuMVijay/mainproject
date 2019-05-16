%%Initialisation
clc;
clearvars;
close all;

tic

load('features.mat')
load('labels.mat')

feat = cat(1,features_facebook,features_flickr,features_twitter);
labels = cat(1,label_facebook,label_flickr,label_twitter);


vals = find(sum(feat));
feat = feat(:,vals);    % removing zeroes
    
rng(1);  % For reproducibility
NumTrees = 10;
Mdl = TreeBagger(NumTrees ,feat,labels,'Method','classification');
save('RF_model.mat','Mdl','vals');

disp('Accuracy(training data): ')
disp(' ')

label = predict(Mdl, features_facebook(:,vals));
accuracy = sum(strcmp(label,label_facebook))/ length(label);
disp(['    Facebook: ',num2str(accuracy)]);

label = predict(Mdl, features_flickr(:,vals));
accuracy = sum(strcmp(label,label_flickr))/ length(label);
disp(['    Flickr: ',num2str(accuracy)]);

label = predict(Mdl, features_twitter(:,vals));
accuracy = sum(strcmp(label,label_twitter))/ length(label);
disp(['    Twitter: ',num2str(accuracy)]);

disp(' ')
toc
