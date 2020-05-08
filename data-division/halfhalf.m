function [output_first_half output_second_half] = halfhalf(input_mat)
    num_row = size(input_mat,1);
    half = ceil(num_row/2);
    output_first_half = input_mat(1:half,:); % - Training
    output_second_half = input_mat(half+1:end,:); % - Testing
end

