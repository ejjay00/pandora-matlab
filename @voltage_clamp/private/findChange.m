function t_change = find_change(data, idx_start, num_mV)
% find starting baseline
  first_ms = 2;
  t_begin = first_ms/dt;
  v_start = mean(data(idx_start:(idx_start + t_begin)));
  %v_start_sd = std(data(idx_start:(idx_start + t_begin)));
  
  % find beginning of step
  t_change = find(abs(data(idx_start:end) - v_start) > num_mV); %5*v_start_sd
  t_change = idx_start - 1 + t_change(1);
end


