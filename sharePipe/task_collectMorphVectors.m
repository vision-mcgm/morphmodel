function [ok,tFin] = task_collectMorphVectors(c,morphDir,allDir)
	%Warp images
	tStart=tic;

	% Config settings.
	nFrames=c.frames;
	PCs=c.PCs;
	p=3;
	h=c.h;
	w=c.w;
	ok=0;

    
    prec=ceil(log10(nFrames));
    format=['%.' num2str(prec) 'i'];
    
	Data = zeros(h*w*5, nFrames);
	for i=1:nFrames
		morphFile=[morphDir 'morph' num2str(i,format) '.mat'];
		load(morphFile);
		Data(:, i) = [TPx(:)', TPy(:)', Texture(:)']';	
	end
    MorphMean = mean(Data,2);
   
    save([allDir '\MorphMean.mat'],'MorphMean');
    save([allDir '\MorphVectors.mat'],'Data');
    ok=1;
    tFin=toc(tStart);					% Record the task duration.
end
