data_dir = './data_clean';

%% Generate Data Features

speakers = dir(data_dir);
num_speakers = numel(speakers)-2;
NUM_CENTROIDS = 16;

vq_val = zeros(num_speakers, 12,NUM_CENTROIDS);
for i=1:numel(speakers)
    speaker = speakers(i).name;
    if strcmp(speaker, '.') == 1 || strcmp(speaker, '..') == 1
        continue
    end
    [y, fs] = audioread(strcat(data_dir, '/', speaker, '/may1.wav'));
    mfcc = melcepst(y, fs);
     % VQ stuff
    [M, P, DH] = vqsplit(mfcc', NUM_CENTROIDS);
    vq_val(i-2,:,:) = M;
end

%% extract feats for singing
vq_val_sing = zeros(num_speakers, 12,NUM_CENTROIDS);
for i=1:numel(speakers)
    speaker = speakers(i).name;
    if strcmp(speaker, '.') == 1 || strcmp(speaker, '..') == 1
        continue
    end
    [y, fs] = audioread(strcat(data_dir, '/', speaker, '/singmay1.wav'));
    mfcc = melcepst(y, fs);
     % VQ stuff
    [M, P, DH] = vqsplit(mfcc', NUM_CENTROIDS);
    vq_val_sing(i-2,:,:) = M;
end

%% Visualize feats
clf
figure(1)
subplot(2, 2, 1)
hold on
title('Speaing VQ along dimensions 1 and 6')
speaker1 = reshape(vq_val(1,:,:), [NUM_CENTROIDS, 12]); 
speaker2 = reshape(vq_val(2,:,:), [NUM_CENTROIDS, 12]); 
plot(speaker1(:,1), speaker1(:,6), 'ro')
plot(speaker2(:,1), speaker2(:,6), 'bo')

subplot(2,2,2)
hold on
title('Speaking VQ along dimensions 4 and 5')
plot(speaker1(:,3), speaker1(:,4), 'ro')
plot(speaker2(:,3), speaker2(:,4), 'bo')

subplot(2,2,3)
hold on
title('Singing VQ along dimensions 1 and 6')
singer1 = reshape(vq_val_sing(1,:,:), [NUM_CENTROIDS, 12]); 
singer2 = reshape(vq_val_sing(2,:,:), [NUM_CENTROIDS, 12]); 
plot(singer1(:,1), singer1(:,6), 'ro')
plot(singer2(:,1), singer2(:,6), 'bo')

subplot(2,2,4)
hold on
title('Singing VQ along dimensions 4 and 5')
plot(singer1(:,4), singer1(:,5), 'ro')
plot(singer2(:,4), singer2(:,5), 'bo')

figure(2)
subplot(2,1,1)
hold on
title('Singing along dimensions 1 and 6')
plot(singer1(:,1), singer1(:,6), 'r+')
plot(speaker1(:,1), speaker1(:,6), 'ro')
plot(singer2(:,1), singer2(:,6), 'b+')
plot(speaker2(:,1), speaker2(:,6), 'bo')

subplot(2,1,2)
hold on
title('Singing along dimensions 4 and 5')
plot(singer1(:,5), singer1(:,9), 'r+')
plot(speaker1(:,5), speaker1(:,9), 'ro')
plot(singer2(:,5), singer2(:,9), 'b+')
plot(speaker2(:,5), speaker2(:,9), 'bo')


