clc;
clear;
close all;

Number_symbols=1e6;
Number_bits=4*Number_symbols;
EbN0_range = 0:20;  % Ranges of Eb/N0
gray_map = [-3, -1, 3, 1];
BER = []; 

for EbN0 = EbN0_range
    % Re-generate the bit stream and transmitted signal
    bits = randi([0,1], 1, Number_bits);
    symbols = reshape(bits, [], 4);
    inphase_bits = bi2de(symbols(:, 1:2), 'right-msb');
    Quadrature_bits = bi2de(symbols(:, 3:4), 'right-msb');
    x = gray_map(inphase_bits + 1);
    y = gray_map(Quadrature_bits + 1);
    complex_envelope = x + 1i * y;

    % Add noise based on Eb/N0
    Eavg = mean(abs(complex_envelope).^2);
    Eb_avg = Eavg / 4;
    N0 = Eb_avg / (10^(EbN0 / 10));
    noise_std = sqrt(N0 / 2);
    noise = noise_std * (randn(size(complex_envelope)) + 1i * randn(size(complex_envelope)));
    received_signal = complex_envelope + noise;

    % Separate x and y components
    x_received = real(received_signal);
    y_received = imag(received_signal);

    % apply -2,0,2 vth for real (in-phase) and imag (quadrature)
    x_demod = 3 * (x_received > 2) + 1 * (x_received > 0 & x_received <= 2) -1 * (x_received < 0 & x_received >= -2) - 3 * (x_received < -2);
    y_demod = 3 * (y_received > 2) + 1 * (y_received > 0 & y_received <= 2) -1 * (y_received < 0 & y_received >= -2) - 3 * (y_received < -2);

    % symbols back to bits
    xbits_received = (x_demod == 3)*2 + (x_demod == 1)*3 + (x_demod == -1)*1 + (x_demod == -3)*0;
    ybits_received = (y_demod == 3)*2 + (y_demod == 1)*3 + (y_demod == -1)*1 + (y_demod == -3)*0;
    
    % decimal values to binary bits 
    received_bits = [de2bi(xbits_received, 2, 'right-msb'), de2bi(ybits_received, 2, 'right-msb')];
    received_bits = received_bits(:).';  % Reshape to a single row vector


    % Calculate BER
    errors = sum(bits ~= received_bits);
    BER = [BER errors / Number_bits];
end

% constellation diagram
figure;
scatter(real(received_signal), imag(received_signal), '.');
title('16QAM Constellation Diagram with Noise');
xlabel('In-phase');
ylabel('Quadrature');
grid on;


% Plot BER vs. Eb/N0
figure;
semilogy(EbN0_range, BER, 'linewidth', 2, 'marker', 'o');
xlabel('Eb/N0 (dB)');
ylabel('Bit Error Rate (BER)');
title('BER Curve for 16QAM');
grid on;
hold on;

