function hist= dip_histogram(img,nbins)

hist = zeros(1,nbins);
n = 0:1/(nbins-1):1;
for  i= 0:nbins-1      %%Iterate over each grey value %%
   hist(i+1)=    sum(sum(sum((img>=((i-0.5)/(nbins-1))) & (img<((i+0.5)/(nbins-1)))))); %% Take into the sum only grey levels with the corresponding 
                                                                                        %%% values.The Distribution criteria was chosen to be similar 
                                                                                        %%% to the Matlab function "imhist"
end  

end
