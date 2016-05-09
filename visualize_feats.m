%all_speaker_mfccs;

speaker1 = '../timit/flatten/faem0';
speaker2 = '../timit/flatten/fajw0';

speaker1_samples = dir(speaker1);
speaker2_samples = dir(speaker2);

speaker1_mfccs = zeros(10, 12);
speaker2_mfccs = zeros(10, 12);

speaker1_vq = zeros(10, 8);
speaker2_vq = zeros(10, 4);

for i=1:numel(speaker1_samples)
     if strcmp(speaker1_samples(i).name, '.') == 1 || strcmp(speaker1_samples(i).name, '..') == 1
            continue
     end
    [y, fs] = audioread(strcat(speaker1,'/', speaker1_samples(i).name));
    ceps = mean(melcepst(y, fs));
    speaker1_mfccs(i-2,:) = ceps;
end
[M1 P1 DH1] =  vqsplit(speaker1_mfccs', 4);

for i=1:numel(speaker2_samples)
     if strcmp(speaker2_samples(i).name, '.') == 1 || strcmp(speaker2_samples(i).name, '..') == 1
            continue
     end
    [y, fs] = audioread(strcat(speaker2,'/', speaker2_samples(i).name));
    speaker2_mfccs(i-2,:) = mean(melcepst(y, fs));
end
[M2 P2 DH2] =  vqsplit(speaker2_mfccs', 4);

% we do see reasonable separation here, so vq should do well
clf
figure(1)
subplot(2, 2, 1)
hold on
title('MFCC along dimensions 1 and 6')
plot(speaker1_mfccs(:,1), speaker1_mfccs(:,6), 'ro')
plot(speaker2_mfccs(:,1), speaker2_mfccs(:,6), 'bo')

% let's see what VQ looks like along some dimensions
subplot(2, 2, 2)
hold on
title('VQ centroids along dimensions 1 and 6')
plot(M1(1,:), M1(6,:), 'ro')
plot(M2(1,:), M2(6,:), 'bo')

subplot(2, 2, 3)
hold on
title('MFCC along dimensions 3 and 4')
plot(speaker1_mfccs(:,3), speaker1_mfccs(:,4), 'ro')
plot(speaker2_mfccs(:,3), speaker2_mfccs(:,4), 'bo')

% let's see what VQ looks like along some dimensions
subplot(2, 2, 4)
hold on
title('VQ centroids along dimensions 3 and 4')
plot(M1(3,:), M1(4,:), 'ro')
plot(M2(3,:), M2(4,:), 'bo')

% It seems like in both cases we have improved separation by using VQ. This
% definitely points to VQ improving the simple nearest neighbor approach

