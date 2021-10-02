clc; clear;
Na = 1000;

Eb = 1;
Nf = 100; %number of transmitted blocks
Nf2 = 20000;
SNR_dB = [0, 1, 2, 3, 4, 5, 6, 7, 8, 9, 10]; %SNR in dB
SNR = 10.^(SNR_dB./10);
bit_errs_theo = zeros([1 11]); %theoretical probability of a bit error
bit_errs_est = qpsk(Nf, SNR, Eb, Na);
bit_errs_est_2 = qpsk(Nf2, SNR, Eb, Na);

for i = 1:length(SNR)
    bit_errs_theo(i) = 0.5.*erfc(sqrt(SNR(i)));
end

figure(1)
semilogy(SNR_dB, bit_errs_theo, 'Linewidth', 1.2)
title('Bit Error Rate vs. SNR for QPSK');
xlabel('Eb/No (dB)');
ylabel('BER');
grid on
hold on
semilogy(SNR_dB, bit_errs_est, '-+', 'Linewidth', 1.3)
semilogy(SNR_dB, bit_errs_est_2, 'o', 'Linewidth', 1.3)
legend('Theoritcal Probability of Error', 'Estimated Probability of Error',...
    'Estimated Probability of Error with at least 50 errors','Location', 'southwest');


function [BER_est] = qpsk(N,SNR,E,Na)
    BER_est = zeros([1 11]); %estimated probability of a bit error
    mu = 0;
    an_even = zeros([1 Na/2]); %received data bits for even bits
    an_odd = zeros([1 Na/2]); %received data bits for odd bits
    signal = 0;
    
    if N == 20000
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
            inphase = zeros([1 Na/2]);
            quad = zeros([1 Na/2]);
            even = zeros([1 Na/2]);
            odd = zeros([1 Na/2]);

            e_count = 1;
            o_count = 1;

            %Split the generated inputs into even and odd bits
            for m = 1:length(a)
                if ((-1)^(m-1) == 1)
                    even(e_count) = a(m);
                    e_count = e_count + 1;
                else
                    odd(o_count) = a(m);
                    o_count = o_count + 1;
                end
            end

            %Symbol Mapping
            for n = 1:(Na/2)
               if (even(n) == 1 && odd(n) == 1)
                   inphase(n) = sqrt(E).*cosd(45);
                   quad(n) = sqrt(E).*sind(45);
               elseif (even(n) == 1 && odd(n) == 0)
                   inphase(n) = sqrt(E).*cosd(135);
                   quad(n) = sqrt(E).*sind(135);
               elseif (even(n) == 0 && odd(n) == 0)
                   inphase(n) = sqrt(E).*cosd(225);
                   quad(n) = sqrt(E).*sind(225);
               else
                  inphase(n) = sqrt(E).*cosd(315);
                  quad(n) = sqrt(E).*sind(315);
               end
            end

            unit_var = (E./SNR(i))./4; %unit variance
            wt_even = mu + sqrt(unit_var).*(randn([1 length(inphase)]) + 1i.*randn([1 length(inphase)])); %Added White Gaussian Noise to inphase part
            wt_odd = mu + sqrt(unit_var).*(randn([1 length(quad)]) + 1i.*randn([1 length(quad)])); %Added White Gaussian Noise to quadrature part
            rt_inphase = real(inphase + wt_even);
            rt_quad = real(quad + wt_odd);
            rt = mod(atan2d(rt_quad, rt_inphase) + 360, 360);

            e_count2 = 1;
            o_count2 = 1;
            
            %Decision Device: Generate the received data bits
            for k = 1:length(rt)
               if (rt(k) > 0 && rt(k) < 90) % 0 and 90
                   an_even(e_count2) = 1; %received data bit
                   an_odd(o_count2) = 1; %received data bit
                   e_count2 = e_count2 + 1;
                   o_count2 = o_count2 + 1;
               elseif (rt(k) > 90 && rt(k) < 180) 
                   an_even(e_count2) = 1;
                   an_odd(o_count2) = 0;
                   e_count2 = e_count2 + 1;
                   o_count2 = o_count2 + 1;
               elseif (rt(k) > 180 && rt(k) < 270) 
                   an_even(e_count2) = 0;
                   an_odd(o_count2) = 0;
                   e_count2 = e_count2 + 1;
                   o_count2 = o_count2 + 1;
               elseif (rt(k) > 270 && rt(k) < 360) 
                   an_even(e_count2) = 0;
                   an_odd(o_count2) = 1;
                   e_count2 = e_count2 + 1;
                   o_count2 = o_count2 + 1;
               end
            end

            %Combine the the even and the odd bits into one array with all the
            %received bits
            an = zeros([1 Na]);
            an(1:2:end-1) = an_even;
            an(2:2:end) = an_odd;

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

