% In this file, we use a distance metric to identify a speaker
% we will run on a subset of the TIMIT data set
TIMIT_DIR = '../timit';

% %% First extract the features
train_dir = strcat(TIMIT_DIR, '/flatten');
speakers = dir(train_dir);

NUM_CENTROIDS = 4;

speaker_mfccs = zeros(numel(speakers)-2, 12);
test_mfccs = zeros(numel(speakers)-2, 12);
num_speakers = size(speaker_mfccs,1);
vq_val = zeros(num_speakers, 12,NUM_CENTROIDS);

all_speaker_mfccs = zeros((numel(speakers)-2)*9, 12);
count_samples = 1;
for i=1:numel(speakers)
    speaker = speakers(i).name;
    if strcmp(speaker, '.') == 1 || strcmp(speaker, '..') == 1
        continue
    end
    samples = dir(strcat(train_dir, '/', speaker));
    mfccs = zeros(numel(samples) - 2, 12);
    total_mfccs = zeros(1, 12);
    for j=1:numel(samples)
        if strcmp(samples(j).name, '.') == 1 || strcmp(samples(j).name, '..') == 1
            continue
        end
        % now we extract the features
        [y, fs] = audioread(strcat(train_dir, '/', speaker, '/', samples(j).name));
        mfccs(j-2,:) = mean(melcepst(y, fs));
        all_speaker_mfccs(count_samples,:) = mean(melcepst(y, fs));
        count_samples = count_samples + 1;
    end
    speaker_mfccs(i-2,:) = mean(mfccs(1:end-1));
    test_mfccs(i-2,:) = mfccs(end,:);
    
    % VQ stuff
    [M P DH] = kmeanlbg(mfccs(1:end-1,:), NUM_CENTROIDS);
    vq_val(i-2,:,:) = M';
end

save('mfccs.mat', 'speaker_mfccs');
save('test_mfccs.mat', 'test_mfccs');
save('vq.mat', 'vq_val');


%% Evaluate closest neighbor
correct = 0;
incorrect = 0;
distance_measure = zeros(num_speakers, num_speakers);

false_positives = 0;
cutoff = 0.043;
% Do a simple nearest neighbor 
for i=1:num_speakers
    test_sample = test_mfccs(i,:);
    
    % look for the closest neighbor
    test_sample = repmat(test_sample, size(speaker_mfccs,1), 1);
    diff = test_sample - speaker_mfccs;
    diff = sum(diff.^2, 2);
    diff = diff./norm(diff,2);
    distance_measure(:,i) = diff;
    [best_match, best_speaker] = min(diff) ;
    false_positives = false_positives + length(diff(diff<cutoff));
    if diff(i) < cutoff
        correct = correct + 1;
    else
        incorrect = incorrect + 1;
    end
end

%% Vector quantization nearest neighbor

correct_vq = 0;
incorrect_vq = 0;
num_speakers = size(speaker_mfccs,1);
distance_measure = zeros(num_speakers, num_speakers);

% Do a simple nearest neighbor 
for i=1:num_speakers
    test_sample = test_mfccs(i,:);
    min_dist = 9000; % some arbitrarily high number
    identified_speaker = 1;
    % look for the closest neighbor
    for j=1:num_speakers
        rep = repmat(test_sample, NUM_CENTROIDS, 1);
        vq_j = reshape(vq_val(j,:,:), [12 NUM_CENTROIDS])';
        diff = (rep - vq_j).^2;
        diff = sum(diff, 2);
        if min(diff) < min_dist
            min_dist = min(diff);
            identified_speaker = j;
        end
    end
    if identified_speaker == i
        correct_vq = correct_vq + 1;
    else
        incorrect_vq = incorrect_vq + 1;
    end
end
% accuracy is 6/9

%% Nearest neighbor doesn't work well, so we'll do average over closest
% centroids

correct_vq_avg = 0;
incorrect_vq_avg = 0;

% Do a simple nearest neighbor 
for i=1:num_speakers
    test_sample = test_mfccs(i,:);
    min_dist = 9000; % some arbitrarily high number
    identified_speaker = 1;
    % look for the closest neighbor
    for j=1:num_speakers
        rep = repmat(test_sample, NUM_CENTROIDS, 1);
        vq_j = reshape(vq_val(j,:,:), [12 NUM_CENTROIDS])';
        diff = (rep - vq_j).^2;
        diff = sum(diff, 2);
        if mean(diff) < min_dist
            min_dist = mean(diff);
            identified_speaker = j;
        end
    end
    if identified_speaker == i
        correct_vq_avg = correct_vq_avg + 1;
    else
        incorrect_vq_avg = incorrect_vq_avg + 1;
    end
end

%% we can also do K nearest neighbors for vq