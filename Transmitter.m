% Initialization
clc; 
clear all;
close all;


% System Parameters
Number_symbols = 1e6;         % transmitted symbols
Number_bits = 4 * Number_symbols;
Carrier_frequency = 1e6;      % 1 MHz
Sampling_frequency = 3 * Carrier_frequency;
Symbol_rate = 1e5;            % Symbol rate
EbN0 = 10;                    % Eb/N0 in dB for constellation plot
BER = [];                     % Initialize BER array

% bit stream
bits = randi([0,1], 1, Number_bits);

% Serial to Parallel Converter
symbols = reshape(bits, [], 4);

% Gray Coding and 4ASK Mapping
% Mapping table: 00 -> -3, 01 -> -1, 11 -> +1, 10 -> +3
gray_map = [-3, -1, 3, 1];
inphase_bits = bi2de(symbols(:, 1:2), 'right-msb');
Quadrature_bits = bi2de(symbols(:, 3:4), 'right-msb');
x = gray_map(inphase_bits + 1);     % in_phase component
y = gray_map(Quadrature_bits + 1);  % quadrature component 

% complex envelope
complex_envelope = x + 1i * y;

% AWGN and Constellation Diagram
% average symbol energy
Eavg = mean(abs(complex_envelope).^2);
Eb_avg = Eavg / 4;
N0 = Eb_avg / (10^(EbN0 / 10));  % N0 = Eb/N0/N0;
noise_std = sqrt(N0 / 2);
noise = noise_std * (randn(size(complex_envelope)) + 1i * randn(size(complex_envelope)));

% Transmit signal with AWGN
transmitted_signal = complex_envelope + noise;

% constellation diagram
figure;
scatter(real(transmitted_signal), imag(transmitted_signal), '.');
title('16QAM Constellation Diagram with Noise');
xlabel('In-phase');
ylabel('Quadrature');
grid on;

% Power Spectral Density (PSD)
[pxx, f] = periodogram(transmitted_signal, [], [], Sampling_frequency, 'centered');
figure;
plot(f, 10*log10(pxx));
title('PSD of 16QAM Signal');
xlabel('(Hz)');
ylabel('(dB/Hz)');
grid on;
