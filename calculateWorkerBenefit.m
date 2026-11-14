
% calculateWorkerBenefit.m
% M370 - Best Age to Collect Social Security Benefit
%
% Calculates monthly worker retirement benefits
% based on PIA and claiming age.
%
% Inputs:
%   PIA         - Monthly benefit at full retirement age
%   claimingAge - Age benefits begin (62-70)
%
% Output:
%   monthlyBenefit - Monthly retirement benefit
%
% Assumptions:
%   - Full retirement age is 67
%   - Claiming ages are whole years
%   - No COLA included in this function
%   - No earnings-test withholding


function monthlyBenefit = calculateWorkerBenefit(PIA, claimingAge)
%% Step 1: Validate Inputs

validateattributes(PIA, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'nonnegative'});

validateattributes(claimingAge, {'numeric'}, ...
    {'scalar', 'integer', '>=', 62, '<=', 70});


%% Step 2: Set Full Retirement Age

FRA = 67;


%% Step 3: Determine Claiming Age Adjustment

if claimingAge < FRA

    % Number of months claimed before FRA
    monthsEarly = (FRA - claimingAge) * 12;

    % First 36 months
    first36 = min(monthsEarly, 36);

    % Additional months beyond 36
    extraMonths = max(monthsEarly - 36, 0);

    % SSA-style early retirement reduction
    reduction = first36 * (5/9) / 100 ...
        + extraMonths * (5/12) / 100;

    adjustmentFactor = 1 - reduction;

elseif claimingAge == FRA

    adjustmentFactor = 1;

else

    % Delayed retirement credits
    monthsDelayed = (claimingAge - FRA) * 12;

    adjustmentFactor = 1 ...
        + monthsDelayed * (8/12) / 100;

end


%% Step 4: Calculate Monthly Benefit

monthlyBenefit = PIA * adjustmentFactor;

end
