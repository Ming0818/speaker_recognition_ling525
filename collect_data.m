recObj = audiorecorder(22050, 8, 1);

name = input('What is your name? (ie: fifi_yeung)', 's');
mkdir(strcat('data/', name))

% Say same sentence 3x
for i=1:3
    input('Please say the sentence: "May the fourth be with you." Hit enter to start')
    recordblocking(recObj, 3);
    disp('End of Recording.')
    y = getaudiodata(recObj);
    audiowrite(strcat('data/',name, '/may',int2str(i), '.wav'), y, recObj.SampleRate);
end

% sing sentence 3x
for i=1:3
    input('Please *sing* the sentence: "May the fourth be with you." Hit enter to start')
    recordblocking(recObj, 5);
    disp('End of Recording.')
    y = getaudiodata(recObj);
    audiowrite(strcat('data/',name, '/singmay',int2str(i), '.wav'), y, recObj.SampleRate);
end

% please speak for 30 s
for i=1:2
    input('Please speak for 30s about anything. Hit enter to start')
    recordblocking(recObj, 30);
    disp('End of Recording.')
    y = getaudiodata(recObj);
    audiowrite(strcat('data/',name, '/speak',int2str(i), '.wav'), y, recObj.SampleRate);
end

%sing for 10s
for i=1:2
    input('Please sing for 10s about anything. Hit enter to start')
    recordblocking(recObj, 10);
    disp('End of Recording.')
    y = getaudiodata(recObj);
    audiowrite(strcat('data/',name, '/sing',int2str(i), '.wav'), y, recObj.SampleRate);
end
    