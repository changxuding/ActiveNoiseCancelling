%% This script is used to run experiemnts and save them:
%  Signals needed to estimate S1(z) and S2(z): 
%    1) x[n]: reference signal (white noise) -> Generate white noise from 
%       speaker of the headphones
%    2) d1[n]:recorded signal at the reference mic (For S1(z)) -> Record
%       signal at reference mic
%    3) d2[n]: recorded signal at the error Mic  (For S2(z)) -> Record
%       signal at error Mic
% 
% Signals needed to estimate P(z):
%       Generate signal (white noise) at the 'Noise' loudspeacker    
%   1)  xPrime[n]: recorded signal at the reference mic : Record signal at the
%       reference mic
%   2)  dPrime[n]: recorded signal at the error mic: record signal at the error
%       microphone
% 

close all 
clear all

h = firpm(1000, [0 0.001 0.005 1], [0 0 1 1]);


experimentName = 'experiment100(8khz).mat';
%% Initialization of the device and the signals: Generate and Save signals for estimation of S1(z) and S2(z)


InitializePsychSound

%search for audio playback and recording devices
   devices = PsychPortAudio('GetDevices' );
   
   
 
%select the connected device (M-Audio)
   dev =   3;

%set the sampling rate to be used
   fs  =   8000;
   
   
   
%set the length of the played signal
    endTime = 8 ;
   
% Generate the white noise signal   
   noise=0.1*randn(endTime*fs,1) ;
   t = 0:1/fs:endTime-1/fs ;
   y = chirp(t,15,endTime,20000);
   noise = noise';
   
 % Create the buffer with the white noise  
 silence = zeros(1,length(noise));

 buffer = PsychPortAudio('CreateBuffer', [], [noise;silence;silence]);
  

 
 % set the buffer size for the recordings
   bufferSize = 1 ;
   
 % Set the ize of the frame of the recording in seconds
   frameSizeSeconds = 0.5 ;

 
 % Open and start the device
 pahandle    =   PsychPortAudio('Open', dev, 3,3,fs,[3 2],[],[],[],1);
 PsychPortAudio('FillBuffer', pahandle, buffer);
 PsychPortAudio('GetAudioData', pahandle ,bufferSize);
 PsychPortAudio('Start', pahandle, 0, [], 1);
 
% Set the level and threshold  
   level = 0 ;
   voicetrigger = 10^-2; 
   
    while level < voicetrigger
        % Fetch current audiodata:
        [audiodata, ~ ,~ ,~] = PsychPortAudio('GetAudioData', pahandle);

        % Compute maximum signal amplitude in this chunk of data:
        if ~isempty(audiodata)
            level = max(abs(audiodata(1,:)));
        else
            level = 0;
        end
        
        % Below trigger-threshold?
        if level < voicetrigger
            % Wait for a millisecond before next scan:
            WaitSecs(0.001);
        end
    end

    % Ok, last fetched chunk was above threshold!
    % Find exact location of first above threshold sample.
    idx = min(find(abs(audiodata(1,:)) >= voicetrigger)); %#ok<MXFND>
        
    % Initialize our recordedaudio vector with captured data starting from
    % triggersample:
     offset = 0 ;
    if(idx > 10)
     offset = 10;
    end
%     offset = 0 ;
offset

    recordedaudio = audiodata(:, idx-offset:end);
    
   completeSignal = recordedaudio ;
   counter = length(recordedaudio);
   
   while(counter< length(noise))
       
       d =   PsychPortAudio('GetAudioData', pahandle ,[],frameSizeSeconds,frameSizeSeconds,[]);
       completeSignal = [completeSignal,d];
       counter = counter + frameSizeSeconds*fs ; 
     
   end

    PsychPortAudio('Close');

    
   
%% Save the recordings d1[n] and d2[n] and the refrecence signal x[n]
referenceMic = completeSignal(2,:);
errorMic = completeSignal(1,:);
% errorMic = filter(h,1,errorMic);

% Remove the dealy introduced by the filter 
% errorMic = errorMic(floor(length(h)/2 + 1):end); 
 %% Plots
    figure  ;
    plot(noise);
    hold on ;
    plot(errorMic);
    hold on 
    plot(referenceMic);
    
    

WaitSecs(1);

%% Initialization of the device and the signals: Generate ans Save signals for estimation of P(z)
 InitializePsychSound
 pahandle    =   PsychPortAudio('Open', dev, 3,3,fs,[4 2],[],[],[],1);
 
 silence = zeros(1,length(noise));
 buffer = PsychPortAudio('CreateBuffer', [], [silence;silence;silence;noise]);
 
 
 PsychPortAudio('FillBuffer', pahandle, buffer);
 PsychPortAudio('GetAudioData', pahandle ,bufferSize);
 PsychPortAudio('Start', pahandle, 0, [], 1);
 
 
 % Set the level and threshold  
   level = 0 ;
   voicetrigger = 10^-1; 
   
    while level < voicetrigger
        % Fetch current audiodata:
        [audiodata, ~ ,~ ,~] = PsychPortAudio('GetAudioData', pahandle);

        % Compute maximum signal amplitude in this chunk of data:
        if ~isempty(audiodata)
            level = max(abs(audiodata(2,:)));
        else
            level = 0;
        end
        
        % Below trigger-threshold?
        if level < voicetrigger
            % Wait for a millisecond before next scan:
            WaitSecs(0.001);
        end
    end

    % Ok, last fetched chunk was above threshold!
    % Find exact location of first above threshold sample.
    idx = min(find(abs(audiodata(2,:)) >= voicetrigger)); %#ok<MXFND>
        
    % Initialize our recordedaudio vector with captured data starting from
    % triggersample:
    offset = 0 ;
%     if(idx > 10)
%      offset = 10;
%     end
  
   offset
    recordedaudio = audiodata(:, idx-offset:end);
    
   completeSignal = recordedaudio ;
   counter = length(recordedaudio);
   tic
   while(counter< length(noise))
       
       d =   PsychPortAudio('GetAudioData', pahandle ,[],frameSizeSeconds,frameSizeSeconds,[]);
       completeSignal = [completeSignal,d];
       counter = counter + frameSizeSeconds*fs ; 
       
   end

    PsychPortAudio('Close');
%% Plots 
    figure  ;
    plot(noise);
    hold on ;
    plot(completeSignal(2,:));
    hold on 
    plot(completeSignal(1,:));
 
%% Save all the experiments     
referenceMicPrime = completeSignal(2,:);
errorMicPrime = completeSignal(1,:);

% errorMicPrime = filter(h,1,errorMicPrime);

%Remove the delay introduces by the filter 
% errorMicPrime = errorMicPrime(floor(length(h)/2 + 1) :end);
save(experimentName,'noise','referenceMic','errorMic','referenceMicPrime','errorMicPrime');


