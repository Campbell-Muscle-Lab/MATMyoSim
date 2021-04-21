function test

parfor i=1:10
    kens_test(i)
    
    
end
end

function kens_test(i)
   sprintf('kens_test_%f',i)
    pause(0.1*i)
end