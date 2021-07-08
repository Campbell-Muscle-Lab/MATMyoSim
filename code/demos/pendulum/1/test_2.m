function test_2

    m = 1;
    L = 1;
    g = 10;
    eta = 1;
    f = 0;
   
    ic = [0.2, 0.0];
    
    n = 200;
    dt = 0.1;
    
    y = NaN*ones(n, 2);
    y(1,:) = ic;
    
    t = [dt];
    
    for i = 2 : n
        [~,y_calc] = ode45(@(t,y) derivs(t,y,f,m,g,L,eta), [0 dt], y(i-1, :));
        y(i,:) = y_calc(end,:);
        t = [t t(end)+dt];
    end

    y = y
    t = t
   
    figure(11);
    clf
    hold on;
    plot(t,y(:,1),'r-+');
    plot(t,y(:,2),'b-');
end




function dy = derivs(t, yy, f, m, g, L, eta)
    dy = NaN*ones(2,1);
    dy(1)= yy(2);
    dy(2) = (f/m) - (eta*yy(2) / m) - (g * yy(1) / L);
end


