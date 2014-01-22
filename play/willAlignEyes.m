%Transforms a folder full of images onto a common faceframe, aligning by
%the eyes. Requires a .mat of eye coords to already be in the folder.

%Parameters

f='W:\Fintan\Data\willAlign\photos with keypoints';
mat='savedKeypoints.mat';

eyeDistance=20;
base=[50-eyeDistance 50; 50+eyeDistance 50];
sizeX=100;
sizeY=120;

%Code

f=checkSlash(f);
outDir=[f 'out'];
outDir=checkSlash(outDir);
checkDir(outDir);
%matrix=load([f mat]);

n=size(matrix.names,2);

for i=1:n
    i
    input=matrix.coords{i};
    trans=cp2tform(input,base,'Nonreflective similarity');
    [pathstr, name, ext] = fileparts(matrix.names{i});
    im=imread([f name ext]);
    im=imtransform(im,trans,'XData',[1 sizeX],'YData',[1 sizeY],'UData',[1 sizeX],'VData',[1 sizeY]);
    imwrite(im,[outDir name '.bmp'],'bmp');
end
    


