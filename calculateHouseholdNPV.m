
function [NPV, breakdown] = calculateHouseholdNPV( ...
    userData, claimAge1, claimAge2)
% calculateHouseholdNPV
% MATH 370 - Social Security Retirement Optimizer
%
% Calculates the Net Present Value of household
% Social Security payments.
%
% Inputs:
%   userData  - Household information
%   claimAge1 - First person's claiming age
%   claimAge2 - Spouse's claiming age (NaN if single)
%
% Outputs:
%   NPV       - Total household Net Present Value
%   breakdown - Present value by benefit category
%
% Assumptions:
%   - Fixed annual COLA rate
%   - Fixed annual discount rate
%   - Payments valued from the current date
%   - Uses simplified household benefit rules


%% Step 1: Calculate Household Payments

payments = calculateHouseholdBenefits( ...
    userData, claimAge1, claimAge2);


%% Step 2: Retrieve Financial Assumptions

discountRate = userData.discountRate;
colaRate = userData.colaRate;

validateattributes(discountRate, {'numeric'}, ...
    {'scalar', 'real', 'finite', '>=', 0});

validateattributes(colaRate, {'numeric'}, ...
    {'scalar', 'real', 'finite', '>=', 0});


%% Step 3: Create Monthly Timeline

months = payments.Month;

years = months / 12;


%% Step 4: Calculate COLA Adjustment

colaFactor = (1 + colaRate).^years;


%% Step 5: Calculate Discount Factor

discountFactor = (1 + discountRate).^years;


%% Step 6: Calculate Present Value Factor

presentValueFactor = colaFactor ./ discountFactor;


%% Step 7: Discount Household Payments

discountedPayments = ...
    payments.Total .* presentValueFactor;


%% Step 8: Calculate Household NPV

NPV = sum(discountedPayments);


%% Step 9: Calculate Benefit Breakdown

breakdown.worker1 = sum( ...
    payments.Worker1 .* presentValueFactor);

breakdown.worker2 = sum( ...
    payments.Worker2 .* presentValueFactor);

breakdown.spousal = sum( ...
    payments.Spousal .* presentValueFactor);

breakdown.children = sum( ...
    payments.Children .* presentValueFactor);

breakdown.total = NPV;

end
