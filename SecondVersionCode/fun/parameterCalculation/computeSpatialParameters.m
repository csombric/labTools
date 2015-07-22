function [out] = computeSpatialParameters(strideEvents,markerData,angleData,s)
%%

timeSHS=strideEvents.tSHS;
timeFTO=strideEvents.tFTO;
timeFHS=strideEvents.tFHS;
timeSTO=strideEvents.tSTO;
timeSHS2=strideEvents.tSHS2;
timeFTO2=strideEvents.tFTO2;
timeFHS2=strideEvents.tFHS2;
timeSTO2=strideEvents.tSTO2;
eventTimes=[timeSHS timeFTO timeFHS timeSTO timeSHS2 timeFTO2 timeFHS2 timeSTO2];
SHS=1; FTO=2; FHS=3; STO=4; SHS2=5; FTO2=6; FHS2=7; STO2=8; %numbers correspond to column of eventTimes matrix
%% Labels and descriptions:
aux={'direction',               '-1 if walking towards window, 1 if walking towards door (implemented for OG bias removal and coordinate rotation)';...
    'hipPos',                   'mid hip position at SHS. NOT: average hip pos of stride (should be nearly constant on treadmill - implemented for OG bias removal) (in mm)';...
    'stepLengthSlow',           'distance between ankle markers at SHS2 (in mm)';...
    'stepLengthFast',           'distance between ankle markers at FHS (in mm)';...
    'takeOffLengthSlow',        'sAnkle position, with respect to fAnkle at STO (in mm)';...
    'takeOffLengthFast',        'fAnkle position with respect to sAnkle at FTO (in mm)';...
    'alphaSlow',                'ankle placement of slow leg at SHS2 (realtive to avg hip marker) (in mm)';...
	'alphaTemp',                'ankle placement of slow leg at SHS (realtive to avg hip marker) (in mm)';...
    'alphaFast',                'ankle placement of fast leg at FHS (in mm)';...
    'alphaAngSlow',             'slow leg angle (hip to ankle with respect to vertical) at SHS2 (in deg)';...
    'alphaAngFast',             'fast leg angle at FHS (in deg)';...
    'betaSlow',                 'ankle placement of slow leg at STO (relative avg hip marker) (in mm)';...
    'betaFast',                 'ankle placement of fast leg at FTO2 (in mm)';...
	'XSlow',                    'ankle postion of the slow leg @FHS (in mm)';...
    'XFast',                    'ankle position of Fast leg @SHS (in mm)';...
	'RFastPos',                 'Ratio of FTO/FHS';...
    'RSloWPos',                 'Ratio of STO/SHS';...
    'RFastPosSHS',              'Ratio of fank@SHS/FHS';...
    'RSlowPosFHS',              'Ratio of sank@FHS/SHS';...
    'betaAngSlow',              'slow leg angle at STO (in deg)';...
    'betaAngFast',              'fast leg angle at FTO (in deg)';...
    'stanceRangeSlow',          'alphaSlow - betaSlow (i.e. total distance covered by slow ankle relative to hip during stance) (in mm)';...
    'stanceRangeFast',          'alphaFast - betaFast (in mm)';...
    'stanceRangeAngSlow',       '|alphaAngSlow| + |betaAngSlow| (i.t total angle swept out by slow leg during stance) (in deg)';...
    'stanceRangeAngFast',       '|alphaAngFast| + |betaAngFast| (in deg)';...
    'swingRangeSlow',           'total distance covered by slow ankle marker realtive to hip from STO to SHS2 (in mm)';...
    'swingRangeFast',           'total distance covered by fast ankle marker realtive to hip from FTO to FHS (in mm)';...
    'omegaSlow',                'angle between legs at SHS2 (in deg)';...
    'omegaFast',                'angle between legs at FHS (in deg)';...
    'alphaRatioSlow',           'alphaSlow/(alphaSlow+alphaFast)';...
    'alphaRatioFast',           'alphaFast/(alphaSlow+alphaFast)';...
    'alphaDeltaSlow',           'slow leg angle at SHS2 - fast leg angle at FHS (in deg)';...
    'alphaDeltaFast',           'fast leg angle at FHS - slow leg angle at SHS (in deg)';...
    'stepLengthDiff',           'stepLengthFast-stepLengthSlow (in mm)';...
    'stepLengthDiff2D',         'two-dimensional version of stepLengthDiff (in mm)';...
    'stepLengthAsym',           'Step length difference (fast-slow), divided by sum';...
    'stepLengthAsym2D',         'two-dimensional step length difference (fast-slow), divided by sum';...
    'angularSpreadDiff',        'omegaFast-omegaSlow (in deg)';...
    'angularSpreadAsym',        'angular spread difference / sum';...
    'Sout',                     'Alpha difference (fast-slow), divided by alpha sum';...
    'Serror',                   'alphaRatioSlow-alphaRatioFast';...
    'SerrorOld',                'alphaRatioFast/alphaRatioSlow';...
    'Sgoal',                    '(stanceRangeAngFast-stanceRangeAngSlow)/stanceRangeAngFast';...
    'angleOfOscillationAsym',   '(alhpaAngFast+betaAngFast)/2-(alphaAngSlow+betaAngSlow)/2';...
    'phaseShift',               'parcent of stride that one angle trace is shifted with respect to the other for max correlation';...
    'phaseShiftPos',            'same as phaseShift, but uses ankle pos trace instead of angles';...
    'spatialContribution',      'Relative position of ankle markers at ipsi-lateral HS (i.e. slow ankle at SHS minus fast ankle at FHS)';...
    'stepTimeContribution',     'Average belt speed times step time difference';...
    'velocityContribution',     'Average step time times belt speed difference';...
    'netContribution',          'Sum of the previous three';...
    'spatialContributionAlt',     'Spatial contribution divided by cadence, to get velocity units instead of length units';...
    'stepTimeContributionAlt',    'Step time contribution divided by cadence, to get velocity units instead of length units';...
    'velocityContributionAlt',    'Velocity contribution divided by cadence, to get velocity units instead of length units';...
    'netContributionAlt',          'Net contribution divided by cadence, to get velocity units instead of length units';...
    'spatialContributionNorm2',    'spatialContribution/(stepLengthFast+stepLengthSlow)';...
    'stepTimeContributionNorm2',    'stepTimeContribution/(stepLengthFast+stepLengthSlow)';...
    'velocityContributionNorm2',    'velContribution/(stepLengthFast+stepLengthSlow)';...
    'netContributionNorm2',    'netContribution/(stepLengthFast+stepLengthSlow). With this normalization, netContributionNorm2 shoudl be IDENTICAL to stepLengthAsym';...
    'stepTimeIdealT',           'Ideal stepTimeContribution value (normalized to sum of step lengths) based on Tgoal parameter';...
    'spatialIdealT',            'Ideal spatialContribution value (normalized to sum of step length) equivalent to -(velocityContributionNorm2+stepTimeIdealT)';...
    'stepTimeErrorT',           'Difference between stepTimeContributionNorm2 and stepTimeIdealT';...
    'spatialErrorT',            'Difference between spatialContributionNorm2 and spatialIdealT';...
    'stepTimeIdealS',           'Ideal stepTimeContribution value (normalized to sum of step lengths) based on Sgoal parameter';...
    'spatialIdealS',            'Ideal spatialContribution value (normalized to sum of step length) equivalent to -(velocityContributionNorm2+stepTimeIdealS)';...
    'stepTimeErrorS',           'Difference between stepTimeContributionNorm2 and stepTimeIdealS';...
    'spatialErrorS',            'Difference between spatialContributionNorm2 and spatialIdealS';...
    'equivalentSpeed',          'Relative speed of hip to feet, ';...
    'singleStanceSpeedSlowAbs',    'Absolute speed of slow ankle during contralateral swing';...
    'singleStanceSpeedFastAbs',    'Absolute speed of fast ankle during contralateral swing';...
    'stepSpeedSlow',           'Ankle relative to hip, from iHS to cHS';...
    'stepSpeedFast',           'Ankle relative to hip, from iHS to cHS';...
    'stanceSpeedSlow',          'Ankle relative to hip, during ipsilateral stance';...
    'stanceSpeedFast',          'Ankle relative to hip, during ipsilateral stance';...
%    'avgRotation',            'Angle that the coordinates were rotated by';...
    }; 

paramLabels=aux(:,1);
description=aux(:,2);

%% Get rotated data
[rotatedMarkerData,sAnkFwd,fAnkFwd,sAnk2D,fAnk2D,sAngle,fAngle,direction,hipPos]=getKinematicData(eventTimes,markerData,angleData,s);

%% Intralimb
if strcmp(s,'L')
    f='R';
elseif strcmp(s,'R')
    f='L';
else
    error();
end 

%step lengths (1D)
stepLengthSlow=sAnkFwd(:,SHS2)-fAnkFwd(:,SHS2); %If sAnkFwd and fAnkFwd are measured with respect to the same reference, this is the same as just subtracting the marker positions
stepLengthFast=fAnkFwd(:,FHS)-sAnkFwd(:,FHS);
takeOffLengthSlow=sAnkFwd(:,STO)-fAnkFwd(:,STO);
takeOffLengthFast=fAnkFwd(:,FTO)-sAnkFwd(:,FTO);
%step length (2D) Express w.r.t the hip -- don't save, for now.
stepLengthSlow2D=sqrt(sum((sAnk2D(:,SHS2,:)-fAnk2D(:,SHS2,:)).^2,3));
stepLengthFast2D=sqrt(sum((fAnk2D(:,FHS,:)-sAnk2D(:,FHS,:)).^2,3));

%Spatial parameters - in millimeters

%alpha (positive portion of interlimb angle at HS)
alphaSlow=sAnkFwd(:,SHS2);
alphaTemp=sAnkFwd(:,SHS);
alphaFast=fAnkFwd(:,FHS);
%beta (negative portion of interlimb angle at TO)
betaSlow=sAnkFwd(:,STO);
betaFast=fAnkFwd(:,FTO2);
%position of the ankle marker at contra lateral at HS
XSlow=sAnkFwd(:,FHS);
XFast=fAnkFwd(:,SHS);
%stance range (subtract since beta is a negative value)
stanceRangeSlow=alphaTemp-betaSlow;
stanceRangeFast=alphaFast-betaFast;
%swing range
swingRangeSlow=sAnkFwd(:,SHS2)-sAnkFwd(:,STO);
swingRangeFast=fAnkFwd(:,FHS)-fAnkFwd(:,FTO);

%Ratio TO./HS
RFastPos=abs(betaFast./alphaFast);
RSloWPos=abs(betaSlow./alphaTemp); 

%Ratio ankle position @HS of contralateral leg./HS
RFastPosSHS=abs(XFast./alphaFast);
RSlowPosFHS=abs(XSlow./alphaTemp);


%Spatial parameters - in degrees

%alpha (positive portion of interlimb angle at HS)
alphaAngSlow=sAngle(:,SHS2);
alphaAngTemp=sAngle(:,SHS);
alphaAngFast=fAngle(:,FHS);
%beta (negative portion of interlimb angle at TO)
betaAngSlow=sAngle(:,STO);
betaAngFast=fAngle(:,FTO2);
%range (alpha+beta)
stanceRangeAngSlow=alphaAngTemp-betaAngSlow;
stanceRangeAngFast=alphaAngFast-betaAngFast;
%interlimb spread at HS
omegaSlow=abs(sAngle(:,SHS2)-fAngle(:,SHS2));
omegaFast=abs(fAngle(:,FHS)-sAngle(:,FHS));
%alpha ratios
alphaRatioSlow=alphaSlow./(alphaSlow+alphaFast);
alphaRatioFast=alphaFast./(alphaSlow+alphaFast);
%delta alphas
alphaDeltaSlow=sAngle(:,SHS2)-fAngle(:,FHS); %same as alphaAngSlow-alphaAngFast
alphaDeltaFast=fAngle(:,FHS)-sAngle(:,SHS);

%% Interlimb

stepLengthDiff=stepLengthFast-stepLengthSlow;
stepLengthAsym=stepLengthDiff./(stepLengthFast+stepLengthSlow);
stepLengthDiff2D=stepLengthFast2D-stepLengthSlow2D;
stepLengthAsym2D=stepLengthDiff2D./(stepLengthFast2D+stepLengthSlow2D);
angularSpreadDiff=omegaFast-omegaSlow;
angularSpreadAsym=angularSpreadDiff./(omegaFast+omegaSlow);
Sout=(alphaFast-alphaSlow)./(alphaFast+alphaSlow);
Serror=alphaRatioSlow-alphaRatioFast;
SerrorOld=alphaRatioFast./alphaRatioSlow;
Sgoal=(stanceRangeFast-stanceRangeSlow)./(stanceRangeFast+stanceRangeSlow);
centerSlow=(alphaAngSlow+betaAngSlow)./2;
centerFast=(alphaAngFast+betaAngFast)./2;
angleOfOscillationAsym=(centerFast-centerSlow);            

%phase shift (using angles)
% slowlimb=sAngle(indSHS:indSHS2);
% fastlimb=fAngle(indSHS:indSHS2);
% slowlimb=slowlimb-mean(slowlimb);
% fastlimb=fastlimb-mean(fastlimb);
% % Circular correlation
% phaseShift=circCorr(slowlimb,fastlimb);
% 
% %phase shift (using marker locations)
% slowlimb=sAnkPos(indSHS:indSHS2);
% fastlimb=fAnkPos(indSHS:indSHS2);
% slowlimb=slowlimb-mean(slowlimb);
% fastlimb=fastlimb-mean(fastlimb);
% % Circular correlation
% phaseShiftPos=circCorr(slowlimb,fastlimb);
T=length(timeSHS);
phaseShift=nan(T,1);
phaseShiftPos=nan(T,1);
for i=1:T
    if ~isnan(timeSHS(i)) && ~isnan(timeSHS2(i))
        if ~isempty(angleData)
            sLimb=angleData.split(timeSHS(i),timeSHS2(i)).getDataAsVector({[s,'Limb']});
            fLimb=angleData.split(timeSHS(i),timeSHS2(i)).getDataAsVector({[f,'Limb']});
            if ~isempty(sLimb) && ~isempty(fLimb)
                phaseShift(i)=circCorr(sLimb,fLimb);
            end
        end
        Pos=rotatedMarkerData.split(timeSHS(i),timeSHS2(i)).getOrientedData({[s,'ANK'],[f,'ANK']});    
        if ~isempty(Pos)
            phaseShiftPos(i)=circCorr(Pos(:,1,2),Pos(:,2,2)); %Using y components only, which is equivalent to sAnkFwd
        end
    end
end


%% Contribution Calculations

% Compute spatial contribution (1D)
spatialFast=fAnkFwd(:,FHS) - sAnkFwd(:,SHS);
spatialSlow=sAnkFwd(:,SHS2) - fAnkFwd(:,FHS);    

% Compute temporal contributions
ts=(timeFHS-timeSHS); 
tf=(timeSHS2-timeFHS); 
difft=ts-tf;

dispSlow=abs(sAnkFwd(:,FHS)-sAnkFwd(:,SHS));
dispFast=abs(fAnkFwd(:,SHS2)-fAnkFwd(:,FHS));

velocitySlow=dispSlow./ts; % Velocity of foot relative to hip, should be close to actual belt speed in TM trials
velocityFast=dispFast./tf;            
avgVel=mean([velocitySlow velocityFast],2);           
avgStepTime=mean([ts tf],2);

spatialContribution=spatialFast-spatialSlow;            
stepTimeContribution=avgVel.*difft;            
velocityContribution=avgStepTime.*(velocitySlow-velocityFast);            
netContribution=spatialContribution+stepTimeContribution+velocityContribution; 

%Alternative and normalized contributions
strideTimeSlow=timeSHS2-timeSHS; %Exactly the same definition as in computeTemporalParameters
spatialContributionAlt=spatialContribution./strideTimeSlow;
stepTimeContributionAlt=stepTimeContribution./strideTimeSlow;
velocityContributionAlt=velocityContribution./strideTimeSlow;
netContributionAlt=netContribution./strideTimeSlow;
%spatialContributionNorm=spatialContributionAlt./equivalentSpeed;
%stepTimeContributionNorm=stepTimeContributionAlt./equivalentSpeed;
%velocityContributionNorm=velocityContributionAlt./equivalentSpeed;
%netContributionNorm=netContributionAlt./equivalentSpeed;
Dist=stepLengthFast+stepLengthSlow;
spatialContributionNorm2=spatialContribution./Dist;
stepTimeContributionNorm2=stepTimeContribution./Dist;
velocityContributionNorm2=velocityContribution./Dist;
netContributionNorm2=netContribution./Dist;

% Contribution error values

%from T goal
stanceTimeSlow=timeSTO-timeSHS;
stanceTimeFast=timeFTO2-timeFHS;
stepTimeIdealT=((velocitySlow+velocityFast)./2).*(stanceTimeSlow-stanceTimeFast)./Dist;
spatialIdealT=-(velocityContributionNorm2+stepTimeIdealT);
stepTimeErrorT=stepTimeIdealT-stepTimeContributionNorm2;
spatialErrorT=spatialIdealT-spatialContributionNorm2;

%From S goal
rangeSlow=alphaSlow-betaSlow;
rangeFast=alphaFast-betaFast;
spatialIdealS=(2*(alphaFast+alphaSlow)./Dist).*((rangeFast-rangeSlow)./(rangeFast+rangeSlow));
stepTimeIdealS=(-velocityContributionNorm2)-spatialIdealS;
spatialErrorS=spatialIdealS-spatialContributionNorm2;
stepTimeErrorS=stepTimeIdealS-stepTimeContributionNorm2;



%% Speed calculations            
equivalentSpeed=(dispSlow+dispFast)./(ts+tf); %= (ts./tf+ts)*dispSlow./ts + (tf./tf+ts)*dispFast./tf = (ts./tf+ts)*vs + (tf./tf+ts)*vf = weighted average of ipsilateral speeds: if subjects spend much more time over one foot than the other, this might not be close to the arithmetic average

% sStanceIdxs=indFTO:indFHS;
% fStanceIdxs=indSTO:indSHS2;
% singleStanceSpeedSlowAbs=prctile(f_events*diff(sToe(sStanceIdxs,2)),70);
% singleStanceSpeedFastAbs=prctile(f_events*diff(fToe(fStanceIdxs,2)),70);
T=length(timeSHS);
singleStanceSpeedSlowAbs=nan(T,1);
singleStanceSpeedFastAbs=nan(T,1);
sToeAbsVel=markerData.getDataAsOTS({[s 'TOE']}).derivate;
fToeAbsVel=markerData.getDataAsOTS({[f 'TOE']}).derivate;
for i=1:T
    if ~isnan(timeFTO(i)) && ~isnan(timeFHS(i)) %Case that the event is missing
        sToePartial=sToeAbsVel.split(timeFTO(i),timeFHS(i)).getOrientedData();
        singleStanceSpeedSlowAbs(i)=prctile(sToePartial(:,1,2),70);
    end
    if ~isnan(timeSTO(i)) && ~isnan(timeSHS2(i))
        fToePartial=fToeAbsVel.split(timeSTO(i),timeSHS2(i)).getOrientedData();
        singleStanceSpeedFastAbs(i)=prctile(fToePartial(:,1,2),70);
    end
end


stanceSpeedSlow=abs(sAnkFwd(:,STO)-sAnkFwd(:,SHS))./(timeSTO-timeSHS); %Ankle relative to hip, during ipsilateral stance
stanceSpeedFast=abs(fAnkFwd(:,FTO2)-fAnkFwd(:,FHS))./(timeFTO2-timeFHS); %Ankle relative to hip, during ipsilateral stance

%stepSpeed - should be the same as velocity calculation for contributions
%above.
stepSpeedSlow=dispSlow./ts; %Ankle relative to hip, from iHS to cHS
stepSpeedFast=dispFast./tf; %Ankle relative to hip, from iHS to cHS


%Rotate coordinates back to original so there are not
%disconinuities within next stride
% rotationMatrix = [cosd(-avgRotation) -sind(-avgRotation) 0; sind(-avgRotation) cosd(-avgRotation) 0; 0 0 1];
% sAnk(indSHS:indFTO2,:) = (rotationMatrix*sAnk(indSHS:indFTO2,:)')';
% fAnk(indSHS:indFTO2,:) = (rotationMatrix*fAnk(indSHS:indFTO2,:)')';
% sHip(indSHS:indFTO2,:) = (rotationMatrix*sHip(indSHS:indFTO2,:)')';
% fHip(indSHS:indFTO2,:) = (rotationMatrix*fHip(indSHS:indFTO2,:)')';
            

%% Assign parameters to data matrix
data=nan(length(timeSHS),length(paramLabels));
for i=1:length(paramLabels)
    eval(['data(:,i)=' paramLabels{i} ';'])
end

%% Create parameterSeries
out=parameterSeries(data,paramLabels,[],description);        

end

