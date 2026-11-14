% calculateBenefits.m
% M370 - Best Age to Collect Social Security

% Estimate how much as individual would receive in monthly
% Social Security retirement benefits

% Based on the Annual Income and Claiming Age

% Output:
%   monthlyBenefit - Estimated monthly retirement benefit ($)

% Assumptions:
%   - Full retirement age is 67
%   - Annual income / 12 approximates AIME
%   - Uses 2026 PIA bend points
%   - No future COLA or earnings adjustments
%   - Retirement worker benefits only

function monthlyBenefit = calculateBenefits(annualIncome, claimingAge)
%% Step 1: Validate Inputs

validateattributes(annualIncome, {'numeric'}, ...
    {'scalar', 'real', 'finite', 'nonnegative'});

validateattributes(claimingAge, {'numeric'}, ...
    {'scalar', 'integer', '>=', 62, '<=', 70});


%% Step 2: Estimate Monthly Earnings

AIME = annualIncome / 12;


%% Step 3: Calculate Primary Insurance Amount

bendPoint1 = 1286;
bendPoint2 = 7749;

if AIME <= bendPoint1

    PIA = 0.90 * AIME;

elseif AIME <= bendPoint2

    PIA = 0.90 * bendPoint1 ...
        + 0.32 * (AIME - bendPoint1);

else

    PIA = 0.90 * bendPoint1 ...
        + 0.32 * (bendPoint2 - bendPoint1) ...
        + 0.15 * (AIME - bendPoint2);

end

% Round PIA down to the nearest dime
PIA = floor(PIA * 10) / 10;


%% Step 4: Calculate Claiming Age Adjustment

FRA = 67;

if claimingAge < FRA

    monthsEarly = (FRA - claimingAge) * 12;

    first36 = min(monthsEarly, 36);
    extraMonths = max(monthsEarly - 36, 0);

    reduction = first36 * (5/9) / 100 ...
        + extraMonths * (5/12) / 100;

    adjustmentFactor = 1 - reduction;

elseif claimingAge == FRA

    adjustmentFactor = 1;

else

    yearsDelayed = claimingAge - FRA;

    adjustmentFactor = 1 + 0.08 * yearsDelayed;

end


%% Step 5: Calculate Monthly Benefit

monthlyBenefit = PIA * adjustmentFactor;

end