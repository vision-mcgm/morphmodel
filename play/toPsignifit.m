function [ im ] = toPsignifit( load )
%Converts from fallacious correct formulation to Psignifit's correct
%formulation. Accepts a .mat with trialLevels and corrects.

n=length(load.corrects);

levels=-2:.5:2;

im(:,1)=levels';
im(:,3)=10;

topResponses=zeros(9,1);

for i=1:n
    SD=load.trialLevels(1,i);
    
    if      load.corrects(i) == 0 && SD < 0
        resp=1;
    elseif load.corrects(i) == 0 && SD >= 0
        resp=0;
    elseif load.corrects(i) == 1 && SD < 0
        resp=0;
    elseif load.corrects(i) == 1 && SD >= 0
        resp=1;
    end
    
    switch SD
        case -2
            index=1;
        case -1.5
            index=2;
        case -1
            index=3;
        case -0.5
            index=4;
        case 0
            index=5;
        case 0.5
            index=6;
        case 1
            index=7;
        case 1.5
            index=8;
        case 2
            index=9;
    end
    topResponses(index)=topResponses(index)+resp;
    
end


im(:,2)=topResponses;

end
