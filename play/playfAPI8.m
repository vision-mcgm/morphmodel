%8: align all the images onto the Reference Faceframe

checkDir(outFolder);
% clear all
% 
% root = 'C:\Users\PaLS\Desktop\fintan\VisualStudio\TestAppConsole C++_copy(working)\';
% files = 'data\a_out.txt';
% coords = 'data\a_coords_mask.txt';
% outFolder='C:\Users\PaLS\Desktop\fintan\VisualStudio\TestAppConsole C++_copy(working)\processed\'
clear all

playfAPI5

checkDir(outFolder);

limit=1000;  %Set to more than the image count to make sure we do all the images
% root=root.l; %Do it locally
cd(root)

F = importdata([root files],',');
C = importdata([root coords]);
M = importdata([root mask]);

[Fr Fc]=size(F);
[Cr Cc]=size(C);
[Mr Mc]=size(M);

nPoints=38;
nGPoints=6;
maskPoints=26;

refFrameX=[30 70 50]';
refFrameY=[40 40 80]';
%Pack into format for cp2tform
refFrame=[refFrameX refFrameY];
refFrame=2*refFrame; %For double size

%Set size
h=240;
w=200;

kp=1; %Insert keypoints in image
mask_kp=1; %Insert mask keypoints

clear fNames
for i=1:Fr
    [tok,rem]=strtok(F{i},' ');
    [tok2,rem2]=strtok(rem,' ');
    fNames{i,1}=tok;
    fNames{i,2}=rem(2:end);
end


for i=1:Cr
    
    idx=round(C(i,1));
    Cadj(idx,:)=C(i,2:end); %Cadj holds coordinates
end

%Put mask coords in a matrix

for i=1:Mr
    
    idx=round(M(i,1));
    Madj(idx,:)=M(i,2:end); %Cadj holds coordinates
     %Convert mask points into a matrix
        for mp=1:maskPoints
        maskX(i,mp)=Madj(i,2*mp);
        maskY(i,mp)=Madj(i,2*mp-1);
        end
end

validCoords=size(Cadj,1); %Cos faceAPI doesn't process the final few images

getPoints=0;
pointsGot=1;

if pointsGot 
%    load('points.mat');
end

firstIt=1;


im=imread([root fNames{1,2}]); %This is a uint8
    [ih iw ic]=size(im);

imSeq=zeros(ih,iw,3,min(validCoords,limit));

for i=1:min(validCoords,limit)
    fprintf('%i %i \n',i,Cadj(i,1));
    im=imread([root fNames{i,2}]); %This is a uint8
    %We only enter this loop if there are coords for the frame.
    if Cadj(i,1)~=0
        'worra'
        for j=1:nPoints
            %Add keypoints in red
           if kp
               im(round(Cadj(i,2*j)),round(Cadj(i,2*j-1)),1)=255;
           end
          
            
            thisX(j)=Cadj(i,2*j-1);
            thisY(j)=Cadj(i,2*j);
            
            noseX=round(Cadj(i,57));
            noseY=round(Cadj(i,58));
            
        end
        
       
        
        %Write mask points
         if mask_kp
               for mp=1:maskPoints
                   if Madj(i,1*mp) ~= 0
                   im(round(Madj(i,2*mp)),round(Madj(i,2*mp-1)),1)=255;
                   end
               end
         end
          % imshow(im);
        
        if getPoints
         imshow(im);
            [gx gy]=ginput(nGPoints);
            save('points.mat','gx','gy');
        end
        getPoints=0;
        pointsGot=1;
        
        %im(round(Cadj(i,58)),round(Cadj(i,57)),1)=255;
        
        this_points(:,1)=thisX;
        this_points(:,2)=thisY;
        
        if firstIt
            [sizeY sizeX c]=size(im);
            centreY=sizeY/2;
            centreX=sizeX/2;
            firstValidIm=i; %Remember first image with valid coords
            refX=thisX;
            refY=thisY;
            base_points(:,1)=refX;
            base_points(:,2)=refY;
            
          %  nX=gx;
          %  nY=gy;
            
            noseRefX=round(Cadj(i,57));
            noseRefY=round(Cadj(i,58));
            
            maskRefX=squeeze(maskX(i,:)'); %Rotate here to a colvec for the masking code
            maskRefY=squeeze(maskY(i,:)');
            
            maskTransX=maskRefX;
            maskTransY=maskRefY; %First it: load up the transform variables 
        end
        
        
        if ~firstIt
            % t=cp2tform(this_points,base_points,'AFFINE');
            t=cp2tform(this_points,base_points,'nonreflective similarity');
            %[nX nY]=tforminv(t,gx,gy);
            
            [maskTransX,maskTransY]=tforminv(t,maskRefX,maskRefY); %Use inverse because it seemed to work last time, 
            %probably because you messed up point order
            
        end
        
        
        if pointsGot
            for j=1:nGPoints
                % im(round(gy(j)),round(gx(j)),:)=255;
               % im(round(nY(j)),round(nX(j)),:)=255; %Add mask points in
                %white
            end
        end
        
        
         
     %   I=fadeOutFrame(im,nX,nY);
        %Get greatest extent of mask polygon
        
%         if firstIt
%             xExtent=max(nX)-min(nX);
%             yExtent=max(nY)-min(nY);
%             
%             xMin=min(nX)
%             xMax=max(nX);
%             yMin=min(nY);
%             yMax=max(nY);
%         end
        
%         xMin=min(xMin,min(nX));
%         xMax=max(xMax,max(nX));
%         yMin=min(yMin,min(nY));
%         yMax=max(yMax,max(nY));
%         
%         %Make sure new extents are the largest extents we have so far
%         xExtent=max(xExtent,max(nX)-min(nX));
%             yExtent=max(yExtent,max(nY)-min(nY));
          
            
        
        
        
        %Get eye and mouth points
        %Remember we use PERSON-centric coords.
        
        REyeOuterX=Cadj(i,1);
        REyeOuterY=Cadj(i,2);
        
        REyeInnerX=Cadj(i,3);
        REyeInnerY=Cadj(i,4);
        
        REyeX=mean([REyeInnerX,REyeOuterX]);
        REyeY=mean([REyeInnerY,REyeOuterY]);
        
        LEyeOuterX=Cadj(i,7);
        LEyeOuterY=Cadj(i,8);
        
        LEyeInnerX=Cadj(i,5);
        LEyeInnerY=Cadj(i,6);
        
        LEyeX=mean([LEyeInnerX,LEyeOuterX]);
        LEyeY=mean([LEyeInnerY,LEyeOuterY]);
        
        RMouthX=Cadj(i,9);
        RMouthY=Cadj(i,10);
        
        LMouthX=Cadj(i,11);
        LMouthY=Cadj(i,12);
        
        MouthX=mean([RMouthX,LMouthX]);
        MouthY=mean([RMouthY,LMouthY]);
        
        faceCentreX=mean([MouthX,LEyeX,REyeX]);
        faceCentreY=mean([MouthY,LEyeY,REyeY]);
        
        if firstIt
            faceCentreRefX=faceCentreX;
            faceCentreRefY=faceCentreY;
        end
        
        thisFrameX=[REyeX LEyeX MouthX]';
        thisFrameY=[REyeY LEyeY MouthY]';
        %Pack for cp2tform
        thisFrame=[thisFrameX thisFrameY];
        
        thisTransform=cp2tform(thisFrame,refFrame,'nonreflective similarity');
        
        frameTransformed=imtransform(im,thisTransform,'XData',[1 sizeX],'YData',[1 sizeY],'UData',[1 sizeX],'VData',[1 sizeY]);
        %Input and output spaces the same size
        
        %Transform this set of keypoints:
        
        [thisXtrans thisYtrans]=tformfwd(thisTransform,thisX,thisY);
        
        alignedKPsX(i,:)=thisXtrans;
        alignedKPsY(i,:)=thisYtrans; %Stores the mask points, aligned according to the proper transform. BUT NO! We
        
        im=zeros(ih,iw,3);
        
        for kp=1:nPoints
        im(round(thisYtrans(kp)),round(thisXtrans(kp)),1)=255;
        end
        
         imshow(im);
       imSeq(:,:,:,i)=im;
        
        %im=imCross(im,round(faceCentreX),round(faceCentreY));
       % imshow(im,'InitialMagnification',200);
        
        %Calc displacement of FACE CENTRE from image centre
        %tx=noseRefX-noseX;
        %ty=noseRefY-noseY;
%         tx=faceCentreRefX-faceCentreX;
%        ty=faceCentreRefY-faceCentreY;
 tx=centreX-faceCentreX;
       ty=centreY-faceCentreY;
        %Make TRANSLATION for nose, not really affine transform
        t = maketform('affine',[1 0 ; 0 1; tx ty]);
        
        %Mask the image
        %im=fadeOutFrame(im,squeeze(maskY(i,:)'),squeeze(maskX(i,:))');
        
        %Mask the image according to the transformed original mask
       % im=fadeOutFrame(im,maskTransY,maskTransX);
        
        
        %Set input and output spaces to the same space (size of image)
     
      %  J = imtransform(im,t,'XData',[1 sizeX],'YData',[1 sizeY],'UData',[1 sizeX],'VData',[1 sizeY]);
        
    %    cropped=frameTransformed(1:240,1:200,:);
      %   imwrite(cropped,[outFolder 'frame' num2str(i,'%03d') '.bmp'],'bmp');
    %    imStack{i}=J;
    %    figure(1);
        %imshow(J,'InitialMagnification',200);
     %   imshow(im);
        
        
        
        %pause(0.1);
        
        %End-of-loop cleanup
        firstIt=0;
    end
end

% %Work out details to embed in a 120*100 frame
% 
% %
% 
% %hExtent=round(h/2);
% %wExtent=round(w/2);
% 
% h=sizeY;
% w=sizeX;
% if h>w
%     bigDirection = 1; %More rows than columns (MONOLITH)
%   
% else
%     bigDirection = 2; %More columns than rows (SLAB)
%  
% end
% 
% 
% 
% % if h>w
% %     bigDirection = 1; %More rows than columns (MONOLITH)
% %     newH=h;
% %     newW=h/1.2;
% %     
% %     xCentre=(xMin+xMax)/2;
% % xOffset=newW/2;
% % xNewMin=xCentre-xOffset;
% % xNewMax=xCentre+xOffset;
% % 
% % yNewMin=yMin;
% % yNewMax=yMax;
% % else
% %     bigDirection = 2; %More columns than rows (SLAB)
% %     newW=w;
% %     newH=w*1.2;
% %     
% %     yCentre=(yMin+yMax)+2;
% %     yOffset=newW/2;
% %     yNewMin=yCentre-yOffset;
% %     yNewMax=yCentre+yOffset;
% %     
% %     xNewMin=xMin;
% %     xNewMax=xMax;
% % end
% 
% 
% %Dump images
% 
% [sizeY sizeX c]=size(imStack{firstValidIm});
% 
% cX=round(sizeX/2);
% cY=round(sizeY/2);
% 
% yExtent=170;
% xExtent=140;
% 
% for i=firstValidIm:min(validCoords,limit)
%     thisIm=imStack{i};
%     %cropped=thisIm(yNewMin:yNewMax,xNewMin:xNewMax,:);
%     %cropped=thisIm(yMin:yMax,xMin:xMax,:);
%     cropped=thisIm(round(cY-yExtent):round(cY+yExtent),round(cX-xExtent):round(cX+xExtent),:);
%     resized=imresize(cropped, [240 200]);
%     %resized=thisIm;
%     imwrite(thisIm,[outFolder 'frame' num2str(i,'%03d') '.bmp'],'bmp');
% end