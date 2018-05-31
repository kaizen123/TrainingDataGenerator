function calculate_ranks_hist(ranks,params)

siz = size(ranks);
N = siz(1)*siz(2)*siz(3);
idx = 0;
for i = 1:siz(1)
    for j = 1:siz(2)
        for k = 1:siz(3)
            if ~isempty(ranks{i,j,k})
                idx = idx+1;
                x(idx) = ranks{i,j,k}.dice_all*100;
            end
        end
    end
end

histogram(x,100);
title(sprintf('Data set : %s',params.local_dir_name)) 


end
