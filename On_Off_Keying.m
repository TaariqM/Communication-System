%% Question 2: OOK
clc; clear;
Na = 1000;

Eb = 1;
Nf = 100; %number of transmitted blocks
Nf2 = 90;
SNR_dB = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; %SNR in dB
SNR = 10.^(SNR_dB./10);
bit_errs_theo = zeros([1 11]); %theoretical probability of a bit error
bit_errs_est = ook(Nf, SNR, Eb, Na);
bit_errs_est2 = ook(Nf2, SNR, Eb, Na);

for i = 1:length(SNR)
    bit_errs_theo(i) = 0.5.*erfc(sqrt(0.5.*SNR(i)));
end

figure(1)
semilogy(SNR_dB, bit_errs_theo, 'Linewidth', 1.2);
title('Bit Error Rate vs. SNR for OOK');
xlabel('Eb/No (dB)');
ylabel('BER');
grid on
hold on
semilogy(SNR_dB, bit_errs_est, '-+', 'Linewidth', 1.3);
hold on
semilogy(SNR_dB, bit_errs_est2, 'o', 'Linewidth', 1.3);
legend('Theoritcal Probability of Error', 'Estimated Probability of Error',...
    'Estimated Probability of Error with at least 50 errors', 'Location', 'southwest');

function [BER_est] = ook(N,SNR,E,Na)
    BER_est = zeros([1 11]); %estimated probability of a bit error
    %vn = zeros([1 1000]); %transmitted signal
    an = zeros([1 Na]); %received data bits
    mu = 0;
    signal = 0;
    
    if N == 90
       disp("The Number of Errors for each SNR point: "); 
       signal = 1;
    else
        signal = 0;
    end
    
    for i = 1:length(SNR)
        Petotal = 0; %Probability of error
        count = 0;
        for f = 1:N
            a = randi([0,1], [1, Na]); %generate input data sequence
            Ne = 0; %Number of errors


            unit_var = (0.5.*E./SNR(i))./2; %unit variance
            wt = mu + sqrt(unit_var).*(randn([1 length(a)]) + 1i.*randn([1 length(a)])); %Added White Gaussian Noise
            rt = real(a + wt); %received signal

            %Decision Device: Generate the received data bits
            for k = 1:length(rt)
               if rt(k) > 0.5
                   an(k) = 1; %received data bit
               end
               if rt(k) < 0.5
                   an(k) = 0; %received data bit
               end
            end

            %Check for bit errors
            for j = 1:length(a)
                if (an(j) ~= a(j))
                   Ne = Ne + 1; %increment the number of errors
                end
            end
            
            count = count + Ne;
            Pe = (Ne./Na); %estimated probability of bit error
            Petotal = Petotal + Pe;
            
        end 
        
        if signal == 1
            fprintf('SNR point %d: %d Errors\n', i, count);
        end
        
        BER_est(i) = Petotal./N; %estimated probability of bit error
        
    end  
end