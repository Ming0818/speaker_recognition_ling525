% In this file, we use a GMM to identify a speaker
% we will run on a subset of the TIMIT data set
TIMIT_DIR = '../timit';

% %% First extract the features
train_dir = strcat(TIMIT_DIR, '/flatten');
speakers = dir(train_dir);


speaker_mfccs = zeros(numel(speakers)-2, 12);
test_mfccs = zeros(numel(speakers)-2, 12);
num_speakers = size(speaker_mfccs,1);

all_speaker_mfccs = zeros((numel(speakers)-2)*9, 12);
count_samples = 1;

NUM_MIXTURES = 20;

mixture_means = zeros(num_speakers, NUM_MIXTURES, 12);
mixture_variances = zeros(num_speakers, NUM_MIXTURES, 12);
mixture_weights = zeros(num_speakers, NUM_MIXTURES);

for i=1:numel(speakers)
    speaker = speakers(i).name;
    if strcmp(speaker, '.') == 1 || strcmp(speaker, '..') == 1
        continue
    end
    samples = dir(strcat(train_dir, '/', speaker));
    mfccs = zeros(numel(samples) - 2, 12);
    all_mfccs = zeros(1, 12);
    for j=1:numel(samples)
        if strcmp(samples(j).name, '.') == 1 || strcmp(samples(j).name, '..') == 1 || ...
            strcmp(samples(j).name, '.DS_Store') == 1
            continue
        end
        % extract the features
        [y, fs] = audioread(strcat(train_dir, '/', speaker, '/', samples(j).name));
        mfccs(j-2,:) = mean(melcepst(y, fs));
        all_mfccs = vertcat(all_mfccs, melcepst(y, fs));
    end
    %speaker_mfccs(i-2,:) = mean(mfccs(1:end-1));
    test_mfccs(i-2,:) = mfccs(end,:);
    % train the GMM
   % [M, V, W] = gaussmix(mfccs(1:end-1,:), [], [], NUM_MIXTURES);
    [M, V, W] = gaussmix(all_mfccs(2:end,:), [], [], NUM_MIXTURES);
    
    mixture_means(i-2,:,:) = M;
    mixture_variances(i-2,:,:) = V;
    mixture_weights(i-2,:) = W;
end
save('gmm_train.mat', 'mixture_means')

%% let's visualize some feats
clf
figure(1)
subplot(2, 2, 1)
hold on
speaker1 = reshape(mixture_means(1,:,:), [NUM_MIXTURES 12]);
speaker2 = reshape(mixture_means(2,:,:), [NUM_MIXTURES 12]);

title('Gaussian along dimensions 1 and 6')
plot(speaker1(:,1), speaker1(:,6), 'ro')
plot(speaker2(:,1), speaker2(:,6), 'bo')

subplot(2, 2, 2)
hold on
title('Gaussian along dimensions 3 and 4')
plot(speaker1(:,3), speaker1(:,4), 'ro')
plot(speaker2(:,3), speaker2(:,4), 'bo')

%% Ok let's get accuracy
correct = 0;
incorrect = 0;

for i=1:num_speakers
    test_sample = test_mfccs(i,:);
    highest_prob = -9000;
    identified_speaker = 0;
    for j=1:num_speakers
        [LP, RP, KH, KP] = gaussmixp(test_sample,...
            reshape(mixture_means(j,:,:), [NUM_MIXTURES, 12]), ...
            reshape(mixture_variances(j,:,:), [NUM_MIXTURES, 12]), ...
            reshape(mixture_weights(j,:), [NUM_MIXTURES, 1]));
        if LP > highest_prob
            identified_speaker = j;
            highest_prob = LP;
        end
    end
    if identified_speaker == i
        correct = correct + 1;
    else
        incorrect = incorrect + 1;
    end
end


