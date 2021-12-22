function [start,amplitude,rate,r_squared,y_fit]=fit_single_exponential(x,y);
% Fit exponential

% Deduce whether it is building or declining
poly_values=polyfit(x,y,1);
if (poly_values(1)>0)
    % Building
    build_mode=1;
else
    % Declining
    build_mode=-1;
end
    
% Now deduce initial guesses
sorted_y=sort(y);
min_y=min(y);
max_y=max(y);

if (build_mode==1)
    guess_half_index=find(sorted_y>(min_y+(0.5*(max_y-min_y))),1,'first');
    p(1)=max_y;
    p(2)=min_y-max_y;
else
    guess_half_index=find(sorted_y<(min_y+(0.5*(max_y-min_y))),1,'last');
    p(1)=min_y;
    p(2)=max_y-min_y;
end
% Error checking
if (isempty(guess_half_index))
    guess_half_index=1;
end
p(3)=-log(0.5)/(x(guess_half_index)-x(1));

p=fminsearch(@single_exponential_fit,p,[],x,y);

start=p(1);
amplitude=p(2);
rate=p(3);

y_fit=start+amplitude*exp(-abs(rate*(x-x(1))));
r_squared=calculate_r_squared(y,y_fit);


function error = single_exponential_fit(p,x,y)

fit=p(1)+p(2)*exp(-abs(p(3))*(x-x(1)));
error=sum((fit-y).^2);

