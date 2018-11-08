clc; clear;

if 1
    N=512;
    n=N;
    M=512;               % number of rows (so that N*M=4KB = page)
    a=1e8;              % average endurance
    s=.25*a;            % std deviation
    subs=1;          % Number of subs in the memory
    Memsize = subs*M;
    repmem=0;   %64*subs;   % replacement rows (in the entire memory)
    wstp=1e5;
    rstp=1e4;
    runlen=(a*Memsize)/wstp;
    cll=zeros(Memsize,n);    % number of writes in every cell
    max_err = 5;

    goodrow=ones(1,Memsize);
    primary=zeros(1,Memsize);
    paired_spare=zeros(1,Memsize);
    prim_flip=0;
    
    bf = normrnd(a,s,Memsize,n);
%     bf(bf<4*wstp)=4*wstp;
    bf(bf<1)=1;

    ni=find(goodrow);

    j=0;k=0;
%     for k=1:1.6*runlen                

    while (~isempty(ni))
        
        wri=randi([1 Memsize]);
        wi=ni(wri);      
        
%         if ~isempty(find(cll(wi,:)>bf(wi,:), 1))       %the address points to a bad block
        if length(find(cll(wi,:)>bf(wi,:))) > max_err 
            if repmem>0             % I never enter this place (no redundant replacement memory)
%                 repmem=repmem-1;
%                 cll(wi,:)=0;
                error('bad code\n');
            else
                if ~primary(wi)     % first time bad row
                    if ~prim_flip   % this will be a spare row
                        last_spare_row_addr = wi;   % remember the address of the new (last) spare row
                        prim_flip=1;                        

                        goodrow(wi)=0;              % remove this spare row from the memory (block it)
                        ni=find(goodrow);    
                        Memsize=length(ni);
                        
                    else            % this will be a primary row
                        primary(wi)=wi;
                        prim_flip=0;                        
                        paired_spare(wi)=last_spare_row_addr;
                    end
                end
                
                if primary(wi)     % this is a primary
                    
                    addr_spare = paired_spare(wi);      % address of the spare paired with this primary
                    bad_pos_in_spare = find(cll(addr_spare,:)>bf(addr_spare,:));
                    
                    cll(addr_spare,:)=cll(addr_spare,:)+wstp*((randi(2,n,1)-1)');   % write to spare
                    tmp1=wstp*((randi(2,n,1)-1)');
%                     cll(wi,bad_pos_in_spare)=cll(wi,bad_pos_in_spare)+wstp*((randi(2,n,1)-1)');  
                    cll(wi,bad_pos_in_spare)=cll(wi,bad_pos_in_spare)+tmp1(bad_pos_in_spare);   

                                                    % write to primary in bad spare positions
                    
                    
                    pp=cll(wi,:)>bf(wi,:);                  % bad bits in primary
                    ss=cll(addr_spare,:)>bf(addr_spare,:);  % bad bits in spare
                    
                    if ~isempty(find(ss&pp, 1))    % both primary and spare have bad bit in the 
                                                   % same position - terminal error
                                                   
                        goodrow(wi)=0;             % remove this primary row from the memory (block it)
                        ni=find(goodrow);    
                        Memsize=length(ni);
                                                   
                    end
                end
                
            end                       
            
        else
            cll(wi,:)=cll(wi,:)+wstp*((randi(2,n,1)-1)');
        end            

%         survm(k)=Memsize;  
        if k/rstp==round(k/rstp)
            j=j+1;
            survm(j)=Memsize;
            100*k/runlen
            Memsize
        end
        
        k=k+1;
        
    end
    survm(j+1:j+3)=Memsize;
        
    save rze10
else

    load rze10
    
    survmp = 100*survm/(subs*M);
    xx=(rstp*wstp/(subs*M/64))*(1:length(survmp));

    figure(16)
    set(gca, 'FontName', 'Helvetica')
    set(gca,'FontSize',16,'FontUnits','points');
    afFigureBackgroundColor = [1, 1, 1];
    set(gcf, 'color', afFigureBackgroundColor);
    set(gcf, 'InvertHardCopy', 'off');    

    plot(xx,survmp,'r')
%     hold
%     plot(2*M*kk,ESursubs1,'b')
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

    
