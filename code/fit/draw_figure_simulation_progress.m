function draw_figure_simulation_progress(opt_structure, all_e_values)

figure(opt_structure.figure_simulation_progress);
clf
if (numel(all_e_values)==1)
    plot(log10(all_e_values),'bo');
else
    plot(log10(all_e_values),'b-');
end
ylabel('log fit error');
xlabel('Iteration');
drawnow;
