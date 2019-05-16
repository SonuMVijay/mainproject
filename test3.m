clc;
clearvars;
close all;
delayTime = .05;
tic

dir_facebook = '/home/user/Desktop/Sonu_new/TrainDataO/facebook/95';
dir_flickr = '/home/user/Desktop/Sonu_new/TrainDataO/flickr/95';
dir_twitter = '/home/user/Desktop/Sonu_new/TrainDataO/twitter/95';

[features_facebook,label_facebook] = featureExtractor(dir_facebook,'facebook');
[features_flickr,label_flickr] = featureExtractor(dir_flickr,'flickr');
[features_twitter,label_twitter] = featureExtractor(dir_twitter,'twitter');

save features.mat features_facebook features_flickr features_twitter
save labels.mat label_facebook label_flickr label_twitter

toc
