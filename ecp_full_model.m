clc; clear;

if 1
    N=512;
    n=N;
    M=64;               % number of rows (so that N*M=4KB = page)
    a=1e8;              % average endurance
    s=.25*a;            % std deviation
    Pages=128;          % Number of pages in the memory
    max_err=6;          % Max FREE-p error (worn-out error?)
    Memsize = Pages*M;
    repmem=0;            %128*Pages/(N/M);   % replacement rows (in the entire memory)
    wstp=1e5;           % I advance the writes by wstp because advancing by 1 would takes weeks.... 
    rstp=1e5;
    runlen=(a*Memsize)/wstp;
    cll=zeros(Memsize,n);    % number of writes in every cell
  

    goodrow=ones(1,Memsize);

    bf = normrnd(a,s,Memsize,n);
    bf(bf<4)=4;

    ni=find(goodrow);

    j=0;k=0;
    while (~isempty(ni))
        
        wri=randi([1 Memsize]);
        wi=ni(wri);
        wL=M*fix((wi-1)/M);        
        cll(wi,:)=cll(wi,:)+wstp*((randi(2,n,1)-1)');      
        
        if length(find(cll(wi,:)>bf(wi,:))) > max_err
            goodrow(wL+1:wL+M)=0;
            ni=find(goodrow);    
            Memsize=length(ni);           
        end

        % This is just a print to track the execution
        if k/rstp==round(k/rstp)
            j=j+1;
            survm(j)=Memsize;
            100*k/runlen
        end
        
        k=k+1;   
    end
    survm(j+1:j+10)=Memsize;
        
    save ec104
else

    load ec104
    
    survmp = 100*survm/(Pages*M);
    xx=(rstp*wstp/Pages)*(1:length(survmp));

    figure(66)
    set(gca, 'FontName', 'Helvetica')
    set(gca,'FontSize',16,'FontUnits','points');
    afFigureBackgroundColor = [1, 1, 1];
    set(gcf, 'color', afFigureBackgroundColor);
    set(gcf, 'InvertHardCopy', 'off');    

    plot(xx,survmp,'r')
%     hold
%     plot(2*M*kk,ESurPages1,'b')
%     hold

    set(findall(gca, 'Type', 'Line'),'LineWidth',3);

    xlabel('Average writes/page (B), \sigma=25%')
    ylabel('Percentage of surviving rows')
%     legend('Rider_3_4_0', 'ECP_6', 'Location','SW')


    s90=xx(find(survmp<90,1));
    s50=xx(find(survmp<50,1));
    
    p90=100*(s90-2.87e9)/2.87e9;
    p50=100*(s50-5.36e9)/5.36e9;
    
    fprintf('90%% mem capacity after %2.2fB writes, 50%% mem capacity after %2.2fB writes\n',...
        s90*1e-9,s50*1e-9) 
    fprintf('%2.2f%% and %2.2f%% above "no replacement" scheme, respectively\n', p90, p50) 
   

end

    
